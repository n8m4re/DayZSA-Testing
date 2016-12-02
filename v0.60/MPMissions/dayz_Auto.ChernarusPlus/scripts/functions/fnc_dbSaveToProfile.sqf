private ["_uid","_agent","_vars","_char","_state","_items","_itemInHands"];

_uid = _this select 0;
_agent = _this select 1;
_vars = [["exposure",0],["modifiers",[]],["modstates",[]],["bloodtype","BloodONeg"],["blood",0],["health",0],["shock",0],["feet",0],["energy",0],["water",0],["stomach",0],["restrainedwith",0],["bodytemperature",0],["heatcomfort",0],["diet",0],["kzombies",0],["kplayers",0],["bleedingsources","[]"],["unconscious",true],["myNotifiers",[]],["damageArray",[]],["wet",0],["musclecramp",0],["penalties",0],["totalWeight",0],["totalHeatIsolation",0],["bleedingLevel",0],["underwater",0],["falldamage",false]];
_char = [false,"",[0,0,0]];
_state = [[],["","","","","","","","",""]]; // vars 0 | quickbar 1
_items = [[],[]]; // inventory 0 | hands 1

if (isNull _agent) exitWith {true};

// Save CHAR 
// alive 0 | model/type 1 | pos 2 | dir 3 
_char set [0,((lifeState _agent == "ALIVE")&&(not captive _agent))];
_char set [1,(typeOf _agent)];
_char set [2,(getPosATL _agent)];
_char set [3,(getDir _agent)];
_char set [4,(vectorUp _agent)];
_char set [5,(vectorDir _agent)];
_char set [6,(animationState _agent)];


// Save CHAR 
null = [_uid, _char] spawn 
{
	null = callFunction ["DataBaseWrite",format["%1_CHAR",_this select 0],format["%1",_this select 1]];
	if (DB_DEBUG) then {diag_log format ["Save CHAR: %2  | UID: %1",_this select 0,_this select 1]};
};


// Player state vars
{(_state select 0) set [(count(_state select 0)),[(_x select 0),(_agent getVariable [(_x select 0),(_x select 1)])]]} forEach _vars;


//Quickbar
{
	_quickIdx =	_agent getQuickBarIndexOfEntity _x;
	if ( _quickIdx > -1 ) then {(_state select 1) set [_quickIdx,(typeOf _x)]};
} forEach (itemsInInventory _agent);



// Save STATE 
null = [_uid, _state] spawn 
{
	null = callFunction ["DataBaseWrite",format["%1_STATE",_this select 0],format["%1",_this select 1]];
	if (DB_DEBUG) then {diag_log format ["Save STATE: %2  | UID: %1",_this select 0,_this select 1]};
};



// Inventory Items [ TYPE 0 | STATE 1 [dmg 0| qty/ammo 1 | wet 2] | ITEMS 2]
{
	_slotItem = _agent itemInSlot _x;
	if !(isNull _slotItem) then 
	{
		(_items select 0) set [(count (_items select 0)),[(typeOf _slotItem),(_slotItem call fnc_getItemState),(_slotItem call fnc_getInvItems)]];
	};
} forEach (itemEnumSlots _agent);


// Hands
_itemInHands = itemInHands _agent;
if !(isNull _itemInHands) then 
{
	_items set [1,[(typeOf _itemInHands),(_itemInHands call fnc_getItemState),(_itemInHands call fnc_getInvItems)]];
};


// Save ITEMS 
null = [_uid, _items] spawn 
{
	null = callFunction ["DataBaseWrite",format["%1_ITEMS",_this select 0],format["%1",_this select 1]];
	if (DB_DEBUG) then {diag_log format ["Save ITEMS: %2  | UID: %1",_this select 0,_this select 1]};
};


if (DB_DEBUG) then {
	diag_log format ["dbSaveToProfile: %1 DONE!",_char];
};

true
