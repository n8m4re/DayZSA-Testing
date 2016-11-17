private ["_arr","_inventoryItems","_item"];
_arr = [];
_inventoryItems = [];
{			
	_qty = (quantity _x);
	if (_x isKindOf "MagazineBase") then {
		_qty = (magazineAmmo _x);
	};
	
	_item = [ (typeOf _x), (damage _x), _qty, (_x call fnc_getInvItems), (_x getVariable ["wet",0])];
	_arr set [(count _arr), _item];
	
} forEach itemsInInventory _this;

_arr
