private ["_agent","_item","_arr","_itemsInInventory","_itemsInCargo","_isIn"];

_agent = _this select 0;

_item = _this select 1;

if (isNull _agent) exitWith {true};

_arr = [];

_itemsInInventory = itemsInInventory _item;

_itemsInCargo = itemsInCargo _item;

_isIn = 
{
	if ( count _itemsInInventory > 0 && count _itemsInCargo > 0 ) exitWith 
	{
		_itemsInCargo
	};

	if ( count _itemsInInventory > 0 && count _itemsInCargo == 0 ) exitWith 
	{
		_itemsInInventory
	};
	
	_itemsInInventory
};

{
	_class = typeOf _x;
	
	_state = _x call fnc_getItemState;
	
	null = call 
	{
	
		if (count (itemsInInventory _x) > 0  || count (itemsInCargo _x) > 0 ) exitWith 
		{
			_arr set [(count _arr),[_class,_state,([_agent,_x] call fnc_getInvItems)]];
		};
		
		_arr set [(count _arr),[_class,_state,[]]];	
	};

} forEach ( call _isIn ); 

_arr	
