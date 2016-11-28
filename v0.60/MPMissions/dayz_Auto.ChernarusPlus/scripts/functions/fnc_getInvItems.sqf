private ["_invItems","_cargoItems","_arr","_item","_cargo","_inv","_isInCargo"];

_invItems = itemsInInventory _this;
// _cargoItems = itemsInCargo _this;
_isInCargo = [];
_inv = [];
_arr = [];
{			

	if (_x isKindOf "ContainerBase") then 
	{
		_cargo = [];
		_cargoItems = itemsInCargo _x;
		
		{
			_isInCargo set [(count _isInCargo), _x];
			_cargo set [(count _cargo), [(typeOf _x),(_x call fnc_getItemState),(_x call fnc_getInvItems)]];
		} forEach _cargoItems;
		
		_inv = [(typeOf _x),(_x call fnc_getItemState),_cargo];
		_arr set [(count _arr),_inv];
		// diag_log format ["isCARGO: %1 | %2 ",(typeOf _x) ,_inv];
		
	} else {
	
		if !( _x in _isInCargo ) then
		{	
			_inv = [(typeOf _x),(_x call fnc_getItemState),(_x call fnc_getInvItems)];
			_arr set [(count _arr),_inv];
			// diag_log format ["notCARGO: %1 | %2 ",(typeOf _x) ,_inv];
		};
	};
} forEach _invItems;

_arr
