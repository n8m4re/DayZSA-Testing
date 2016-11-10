private ["_char","_key","_uid","_vars","_inventory","_inventoryStr","_type","_qty","_dmg"];
	
_uid = 	_this select 0;

_agent = _this select 1;

_key = format ["UID_%1", _uid];

_char = profileNamespace getVariable _key;

_inventory = itemsInInventory _agent;

_inventoryStr = [];
{
    _type = typeOf _x;
    _qty = quantity _x;
    _dmg = damage _x;
    _inventoryStr set [count _inventoryStr, [_type, _qty, _dmg]];
} forEach _inventory;
	
// diag_log format ["DEBUG INVENTORY: %1", _inventoryStr];	
	
_vars = [
["health",0],
["blood",0],
["energy",0],
["water",0],
["shock",0],
["stomach",0],
["diet",0],
["bodytemperature",0],
["heatcomfort",0],
["wet",0],
["musclecramp",0],
["restrainedwith",0],
["totalHeatIsolation",0],
["totalWeight",0],
["bloodtype","BloodONeg"],
["unconscious",true],
["damageArray",[]],
["myNotifiers",[]],
["bleedingsources","[]"],
["bleedingLevel",0],
["modstates",[]],
["modifiers",[]]
];

_stat = [];	
{ 
	_val = _agent getVariable[(_x select 0),(_x select 1)];
	_stat set [count _stat, [(_x select 0),_val] ];
} forEach _vars;


/*
 alive 0 | model/type 1 | pos 2 | dir 3 | inv 4 | stats 5 | online 6 
*/
_char set [0, ((lifeState _agent == "ALIVE") && (not captive _agent))];
_char set [1, typeOf _agent];
_char set [2, getPosATL _agent];
_char set [3, getDir _agent];
_char set [4, _inventoryStr];
_char set [5, _stat];
_char set [6, true];

saveProfileNamespace;


if (DB_DEBUG) then {
	diag_log format ["dbSaveToProfile: %1",_char];
};

true