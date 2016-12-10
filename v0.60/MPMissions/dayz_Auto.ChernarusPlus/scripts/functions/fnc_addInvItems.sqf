private ["_obj","_items"];

_obj = _this select 0;

_items = _this select 1;

if (isNull _obj) exitWith {true};

if !(typeName _items == "ARRAY") exitWith {true};

{
		private["_class","_state","_inv","_item"];
		
		_class = _x select 0;
		
		_state = _x select 1;
		
		_inv = _x select 2;
				
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

		/**	
		if( _class isKindOf "MagazineBase" ) then 
		{	
			if(isClass(configFile >> "CfgWeapons" >> (typeOf _obj)) then 
			{
				if !(isNull _item) then
				{
					diag_log _item;
					null = moveToGround _item;
					// null = moveToGround (itemParent _x);
					null = _item moveToInventory _obj;
					//null = _agent moveToInventory (itemParent _x);
				};			
			};		
		};
		**/

} forEach _items;

true
