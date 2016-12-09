private ["_state","_player","_params"];

/*
	Manage cooking actions.
	
	Usage:
	[_state, _player, _params] call cooking_manageActions
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

//transfer modifiers from source object to target object
_transfer_modifiers = 
{
	_source = _this select 0;
	_target = _this select 1;
	_modifiers = _source getVariable ['modifiers', []];
	
	{
		[0, _target, _x] call event_modifier;
	} foreach _modifiers;
};

//fill cooking equipment with liquid
/*
_fill_with_liquid = 
{
	private["_source","_cooking_equipment","_source_fill_amount","_cooking_equipment_amount","_fill_amount"];
	_cooking_equipment = _this select 0;
	_source = _this select 1;
	_source_fill_amount = _this select 2;
	_cooking_equipment_amount = quantity _cooking_equipment;
	
	_liquid_max_volume = GetNumber (configFile >> "CfgVehicles" >> typeof _cooking_equipment >> "stackedMax");
	
	//check source quantity
	if ( quantity _source == 0) exitWith
	{
		//player message
		[_player, format["%1 is empty.", displayName _source], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//check fullness
	if ( _cooking_equipment_amount == _liquid_max_volume) exitWith
	{
		//player message
		[_player, format["%1 is already full.", displayName _cooking_equipment], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//add liquid
	//source available quantity
	if (quantity _source < _source_fill_amount) then
	{
		_source_fill_amount = quantity _source; //not enough liquid in source
	};
	//cooking equipment available capacity
	_fill_amount = _source_fill_amount; //default
	if (_cooking_equipment_amount + _source_fill_amount > _liquid_max_volume) then
	{
		_fill_amount = _liquid_max_volume - _cooking_equipment_amount; //not enough capacity in target cooking equipment
	};	
	
	_liquid_type = _source getVariable ['liquidType',''];
	_source_modifiers = _source getVariable ['modifiers', []];
	//set new quantity
	_cooking_equipment setQuantity (_fill_amount + _cooking_equipment_amount);
	_source setQuantity (quantity _source - _source_fill_amount);
	//set new liquidType
	_cooking_equipment setVariable ['liquidType', _liquid_type];
	//transfer modifiers
	[_source, _cooking_equipment] call _transfer_modifiers;
	
	//player message
	[_player, format["You have poured a bit of the %2 into the %1.", displayName _cooking_equipment, displayName _source], "colorAction"] call fnc_playerMessage;	
};
*/

switch _state do
{	

/*	
	//fill cooking pot with liquid
	case 1: 
	{
		private["_cooking_equipment","_source","_fill_amount"];
		_cooking_equipment = _params select 0;
		_source = _params select 1;
		_fill_amount = _params select 2;
		
		//fill with liquid
		[_cooking_equipment, _source, _fill_amount] call _fill_with_liquid;
	};
*/	
	//(DEBUG) check contents
	case -1: 
	{
		private["_source","_cooking_equipment","_liquid_type"];
		_cooking_equipment = _params select 0;
		_liquid_type = _cooking_equipment getVariable ['_liquidType', ''];
		_liquid_temp = _cooking_equipment getVariable ['temperature', 0];
		_modifiers = _cooking_equipment getVariable ['modifiers', []];
		
		//player message
		[_player, format["[Debug] Equipment = %1 | liquidType = %2 | temperature = %3 | modifiers = %4", displayName _cooking_equipment, _liquid_type, _liquid_temp, _modifiers], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	default {};
};
