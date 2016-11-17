private ["_char","_agent","_key","_uid","_vars","_inventory","_inventoryStr","_type","_qty","_dmg","_itemInHands"];
	
_uid = _this select 0;
_agent = _this select 1;
_key = format ["UID_%1", _uid];
_char = [];
_inventoryStr = [];
_stat = [];	
_hands = [];
_vars = [["health",0],["blood",0],["energy",0],["water",0],["shock",0],["stomach",0],["diet",0],["bodytemperature",0],["heatcomfort",0],["wet",0],["musclecramp",0],["restrainedwith",0],["totalHeatIsolation",0],["totalWeight",0],["bloodtype","BloodONeg"],["unconscious",true],["damageArray",[]],["myNotifiers",[]],["bleedingsources","[]"],["bleedingLevel",0],["modstates",[]],["modifiers",[]]];


// diag_log format["itemsInInventory: %1 | itemsInCargo: %2" , (itemsInInventory _agent), (itemsInCargo _agent)];	

// Player stats
{ _val = _agent getVariable[(_x select 0),(_x select 1)]; _stat set [count _stat, [(_x select 0),_val] ]; } forEach _vars;


// Inventory Items
{
	_slotName = _x;
	_item = _agent itemInSlot _slotName;
	_slotArr = [];

	if !(isNull _item) then {
		
		_qty = (quantity _item);
				
		if (_item isKindOf "MagazineBase") then {
			_qty = (magazineAmmo _item);
		};
		
		
		_slotArr = [(typeOf _item), (damage _item), _qty, (_item call fnc_getInvItems), (_item getVariable ["wet",0])];
		
		_inventoryStr set [(count _inventoryStr), _slotArr];
	};
} forEach itemEnumSlots _agent;



// Hands
_itemInHands = itemInHands _agent;

if !(isNull _itemInHands) then {

	_qty = (quantity _itemInHands);
	
	if (_itemInHands isKindOf "MagazineBase") then {
		_qty = (magazineAmmo _itemInHands);
	};
		
	_hands = [(typeOf _itemInHands), (damage _itemInHands), _qty, (_itemInHands call fnc_getInvItems), (_itemInHands getVariable ["wet",0])];
	
};


// alive 0 | model/type 1 | pos 2 | dir 3 | inv 4 | stats 5 | online 6 | hands 7 
_char set [0,((lifeState _agent == "ALIVE")&&(not captive _agent))];
_char set [1,(typeOf _agent)];
_char set [2,(getPosATL _agent)];
_char set [3,(getDir _agent)];
_char set [4,_inventoryStr];
_char set [5,_stat];
_char set [6,true];
_char set [7,_hands];

_re = callFunction ["Enf_DbWrite",_key, format ["%1",_char]];

if (DB_DEBUG) then {
	diag_log format ["dbSaveToProfile: %1",_char];
	diag_log format ["callFunction result: %1",_re];
};

true
