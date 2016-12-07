private ["_obj","_items"];

_obj = _this select 0;

_items = _this select 1;

if (isNull _obj) exitWith {true};

if !(typeName _items == "ARRAY") exitWith {true};

// diag_log format ["_obj: %1 | _class: %2 ", typeOf _obj, _class ]; 

{
		_class = _x select 0;
		_state = _x select 1;
		_inv = _x select 2;
		
		// if(isClass(configFile >> "CfgWeapons" >> _class)) then 
		_item = _obj createInCargo _class;
		
		if (isNull _item) then
		{
			_item = _obj createInInventory _class;
		};		
		
		if (count _state > 0) then 
		{ 
			 null = [_item,_state] call fnc_addItemState; 
		};
		
		if (count _inv > 0) then 
		{
			 null = [_item,_inv] call fnc_addInvItems;
		};
		
} forEach _items;

true
