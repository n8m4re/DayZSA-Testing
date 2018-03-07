private ["_obj","_items"];

_obj = _this select 0;

_items = _this select 1;

if (isNull _obj) exitWith {true};

if !(typeName _items == "ARRAY") exitWith {true};

{
		private["_class","_state","_inv","_item","_invNew"];
		
		_class = _x select 0;
		
		_state = _x select 1;
		
		_inv = _x select 2;
						
		_item = _obj createInCargo _class;

		if (isNull _item) then
		{
			_item = _obj createInInventory _class;
		};		

		if ( typeName _state == "ARRAY" ) then 
		{
			if !( count _state <= 0 ) then 
			{ 
				null = [_item,_state] call fnc_addItemState;
			};
		};

		if ( typeName _inv == "ARRAY" ) then 
		{
			if !( count _inv <= 0 ) then 
			{ 				
				null = [_item,_inv call fnc_invOrder] call fnc_addInvItems;
			};
		};
		
		null = call 
		{
			if (_item isKindOf "FoodItemBase") exitWith {
				_item call event_fnc_foodStage;
			};
		};
		
} forEach _items;