private ["_arr","_inventoryItems","_item"];
_arr = [];
_inventoryItems = [];
{			
	_qty = (quantity _x);
	if (_x isKindOf "MagazineBase") then {
		_qty = (magazineAmmo _x);
	};
	
	_item = [(typeOf _x),(damage _x),_qty];
	_arr set [(count _arr), _item];
	//_arr set [(count _arr),(_inventoryItems call fnc_getInventoryItems)];
} forEach itemsInInventory _this;

_arr
