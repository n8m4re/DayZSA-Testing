private ["_char","_agent","_uid","_vars","_state","_items","_itemInHands","_hands"];

_uid = _this select 0;

_agent = _this select 1;

_char = [false,"",[0,0,0]];

_hands = [];

_vars = [
["exposure",0],
["modifiers",[]],
["modstates",[]],
["bloodtype","BloodONeg"],
["blood",0],
["health",0],
["shock",0],
["energy",0],
["water",0],
["stomach",0],
["bodytemperature",0],
["heatcomfort",0],
["diet",0],
["unconscious",true],
["mynotifiers",[]],
["damageArray",[]],
["wet",0],
["musclecramp",0],
["restrainedwith",0],
["totalHeatIsolation",0],
["totalWeight",0],
["bleedingsources","[]"],
["bleedingLevel",0],
["underwater",0]
];

_items = [[],[]]; // inventory 0 | hands 1
_state = [[],["","","","","","","","","",""]]; // vars 0 | quickbar 1


if (isNull _agent) exitWith {true};


// Save CHAR 
// alive 0 | model/type 1 | pos 2 | dir 3 
_char set [0,((lifeState _agent == "ALIVE")&&(not captive _agent))];
_char set [1,(typeOf _agent)];
_char set [2,(getPosATL _agent)];
_char set [3,(getDir _agent)];

_re = callFunction ["Enf_DbWrite",format["%1_CHAR",_uid],format["%1",_char]];


// Player state vars
{ (_state select 0) set [(count (_state select 0)), [(_x select 0), (_agent getVariable [(_x select 0),(_x select 1)]) ]]} forEach _vars;


//Quickbar
{
	_quickIdx =	_agent getQuickBarIndexOfEntity _x;
	if ( _quickIdx > -1 ) then {(_state select 1) set [_quickIdx, (typeOf _x)];};
} forEach (itemsInInventory _agent);

// Save STATE 
_re = callFunction ["Enf_DbWrite",format["%1_STATE",_uid],format["%1",_state]];



// Inventory Items [ TYPE 0 | STATE 1 [dmg 0| qty/ammo 1 | wet 2] | ITEMS 2]
{
	
	_slotItem = _agent itemInSlot _x;
	
	if !(isNull _slotItem) then {
		(_items select 0) set [(count (_items select 0)), [ (typeOf _slotItem),(_slotItem call fnc_getItemState),(_slotItem call fnc_getInvItems)]];
	};
	
} forEach (itemEnumSlots _agent);



// Hands
_itemInHands = itemInHands _agent;

if !(isNull _itemInHands) then {
	_items set [1, [(typeOf _itemInHands),(_itemInHands call fnc_getItemState),(_itemInHands call fnc_getInvItems)]];
};

_re = callFunction ["Enf_DbWrite",format["%1_ITEMS",_uid],format["%1",_items]];


if (DB_DEBUG) then {
	diag_log format ["dbSaveToProfile: %1",_char];
};

true
