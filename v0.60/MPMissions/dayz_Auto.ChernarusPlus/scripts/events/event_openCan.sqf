/*
	This script can be used for opening can items with 3 kinds of actions:
	
	1. hands (cans that can be easily opened, no tool required, no food loss)
	2. can opener (no food loss on opening)
	3. sharp tools (food loss is calculated by few factors)

*/

private["_player", "_opener","_item","_quantity","_damageType", "_sharpness", "_heaviness", "_power", "_leftover", "_range", "_newDmg"];

_player = _this select 0;

//opener
_opener = _this select 1;
_no_opener = false;
if ( isNull _opener ) then { _no_opener = true; };
//opener name
_openerName = "";
if !( _no_opener ) then { _openerName = typeOf (_this select 1); };

//opened item
_item = _this select 2;
_itemName = typeOf (_this select 2);

diag_log format ["****************** %1 ",_itemName];

//no loss?
_no_loss = _this select 3;
if ( isNil "_no_loss" ) then { _no_loss = false; };


//--- CHECK DAMAGE ON OPENER
if ( !_no_opener && damage _opener >= 1 ) exitWith
{ 
	_newDmg = damage _item;
	_newItem = [_itemName,_player] call player_addInventory;
	_newItem setDamage _newDmg;
	[_player,format["I can not use %1, it's completely damaged.",displayName _opener],'colorAction'] call fnc_playerMessage;
};

//--- CHECK DAMAGE ON CAN
if ( damage _item >= 1 ) exitWith
{
	_newItem = [_itemName,_player] call player_addInventory;
	_newItem setDamage 1;
	[_player,format["I can not open %1, it's completely damaged.",displayName _item],'colorAction'] call fnc_playerMessage;
};

//--- CALCULATE DMG ON OPENER
_newDmg = 0;  //defaul value (if no opener is used)

//calculate dmg on opener with zero loss
if ( _no_loss ) then
{
	if !( _no_opener) then
	{
		_newDmg = (damage _opener) + 0.05; 
	};
}
//calculate dmg on opener based on its sharpness, damageType, etc.
else
{
	_damageType = getText ( configFile >> "CfgVehicles" >> _openerName >> "Melee" >> "ammo");
	//counting hit cap as 10
	_power = getNumber ( configFile >> "CfgAmmo" >> _damageType >> "hit");
	_sharpness = getNumber ( configFile >> "CfgAmmo" >> _damageType >> "bleedChance");
	_heaviness =  getNumber ( configFile >> "CfgAmmo" >> _damageType >> "hitShock");
	_toolHP =  getNumber ( configFile >> "CfgVehicles" >> _openerName >> "armor");

	//if ( _sharpness < 0.1 ) then {exitWith { statusChat ["It Can Not Be Opened By This Item",""]};};

	//set numbers into right range
	_heaviness = _heaviness * 0.01;
	_power = _power * 0.1;

	//-----
	_maxRange = _sharpness;
	_minRange = _sharpness - _heaviness;

	//diag_log format ["max range %1-%2=%3, min range %4",_sharpness,_heaviness, _maxRange, _power];

	if ( _maxRange < 0.2 ) then
	{
		_maxRange = 0.2;
	};

	if ( _minRange >= _maxRange ) then
	{
		_minRange = _maxRange - _minRange;
		//_maxRange = 1 - _maxRange;
	};

	if ( _maxRange > 1 ) then { _maxRange = 1;};

	_quantity = (random ( _maxRange - _minRange )) + _minRange;
	_range = _maxRange - _minRange;

	//_debugText = format ["%3 range %1-%2",_minRange,_maxRange, _damageType];
	//diag_log _debugText;
	//hint _debugText;

	//-----
	if ( _quantity > 1 ) then { _quantity = 1 };

	//-----
	_leftover = random ( 0.1 * _range);
	if ( _leftover < 0.05 ) then
	{
		_leftover =  random (5);
		_leftover = _leftover * 0.01;
	};

	_rand = (round random 10) * 0.001;
	_newDmg = ((damage _opener) + (_rand * _heaviness) - (_rand * _sharpness * 0.5) + 0.02);
};

//--- SET DAMAGE ON OPENER
if ( _newDmg > 0 ) then 
{
	_opener setDamage _newDmg;
};

//--- CALCULATE QUANTITY OF OPENED ITEM
if ( _no_loss || _no_opener ) then   //no loss on opening
{
	_quantity = 1;   
}
else   //calculate loss by used tool
{
	_rand = random (_range);
	if ( _rand >= 0.5) then
	{
		_quantity = _quantity - _leftover;
	}
	else
	{
		_quantity = _quantity + _leftover;
	};

	if ( _quantity < 0 ) then { _quantity = _leftover; };
	if ( _quantity >= 1 ) then { _quantity = 1; };
};

//--- CREATE NEW ITEM
_openedItem = _itemName + "_Open";
_dmg = damage _item;

_newItem = _player replaceItemWithNew [_item, _openedItem];
if (isNil "_newItem") then
{
	_newItem = [_openedItem,_player] call player_addInventory;
};
_newItem setQuantity _quantity;
_newItem setDamage _dmg;

//transfer temperature
_oldItemTemp = _item getVariable 'temperature';
if !(isNil "_oldItemTemp") then
{
	_newItem setVariable ['temperature', _oldItemTemp];
};

//--- MESSAGE PLAYER
if ( _quantity >= 1 ) then
{
	[_owner,format['I have opened the %1.', displayName _item],'colorAction'] call fnc_playerMessage; 
}
else
{
	[_owner,format['I have opened the %1 but I have dropped some when I was opening it.', displayName _item],'colorAction'] call fnc_playerMessage;
};

