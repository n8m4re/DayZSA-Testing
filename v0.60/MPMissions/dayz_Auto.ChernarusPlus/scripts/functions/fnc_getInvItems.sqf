private ["_arr","_item","_cargo","_isInCargo"];

_isInCargo = [];
_arr = [];
{			
	if (_x isKindOf "ContainerBase") then 
	{
		_cargo = [];
		
		{
			_isInCargo set [(count _isInCargo), _x];
			_cargo set [(count _cargo), [(typeOf _x),(_x call fnc_getItemState),(_x call fnc_getInvItems)]];
		} forEach (itemsInCargo _x);
		
		_arr set [(count _arr),[(typeOf _x),(_x call fnc_getItemState),_cargo]];
		// diag_log format ["isCARGO: %1 | %2 ",(typeOf _x) ,_inv];
		
	} else {
	
		if !( _x in _isInCargo ) then
		{	
			_arr set [(count _arr),[(typeOf _x),(_x call fnc_getItemState),(_x call fnc_getInvItems)]];
			// diag_log format ["notCARGO: %1 | %2 ",(typeOf _x) ,_inv];
		};
	};
	
	
		// diag_log format ["itemParent: %1",(typeOf (temParent _x)), (typeOf _x)];
	
} forEach (itemsInInventory _this);

_arr
