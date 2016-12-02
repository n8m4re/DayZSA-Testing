private ["_agent","_items"];

_agent = _this select 0;
_items = _this select 1;

if (typeName _items != "ARRAY") exitWith {true}; 

{

		_created = 0;
		_item = objNull;
		_class = _x select 0;
		_state = _x select 1;
		_inv = _x select 2;
	
		_att = getArray (configFile >> "cfgWeapons" >> _class >> "attachments");
	
		if (_class in _att) then
		{
			_item = _agent createWeaponAttachment _class;
			_created = 1;
		};
		
		if (_class isKindOf "ContainerBase" ) then
		{
			_item = _agent createInCargo _class;
			_created = 1;
		};
		
		if (_created < 1) then
		{
			_item = _agent createInInventory _class;
		};	
		
		if ( _agent isKindOf "SurvivorBase" ) then 
		{
			if (isNull _item) then
			{
				_item = _class createVehicle (getPosATL _agent);
				_item setPosATL (getPosATL _agent);
			};	
		};		
			
		if !(isNull _item) then 
		{	
			if (typeName _state == "ARRAY") then 
			{
				[_item,_state] call fnc_addItemState;
			};
				
			if (typeName _inv == "ARRAY") then 
			{
				[_item,_inv] call fnc_addInvItems;
			};
		};

		
	// diag_log format ["INVENTORY: %1 | %2 | %3",_class,_item,(_x select 2)];
	
} forEach _items;

true
