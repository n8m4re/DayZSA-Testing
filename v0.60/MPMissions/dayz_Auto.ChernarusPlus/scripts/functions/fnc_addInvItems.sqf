private ["_agent","_items","_attVehicles","_attWeapons"];

_agent = _this select 0;

_items = _this select 1;

if (isNull _agent) exitWith {true};

if !(typeName _items == "ARRAY") exitWith {true};

 _attVehicles = [];
// {_attVehicles set [count _attVehicles,toLower _x]} forEach getArray (configFile >> "CfgVehicles" >> typeOf _agent >> "attachments");
 _attWeapons = [];
// {_attWeapons set [count _attWeapons,toLower _x]} forEach getArray (configFile >> "cfgWeapons" >> typeOf _agent >> "attachments");
// diag_log format ["_agent: %1 | _class: %2 ", typeOf _agent, _class ]; 


{
		_class = _x select 0;
		_state = _x select 1;
		_inv = _x select 2;
			
		_item = _agent createInInventory _class;
	
		if ( _agent isKindOf "SurvivorBase" ) then 
		{
			if (isNull _item) then
			{
				_item = _class createVehicle (getPosATL _agent);
				_item setPosATL (getPosATL _agent);
			};	
		};	
		
		if ( count _state > 0 ) then 
		{ 
			 [_item,_state] call fnc_addItemState; 
		};

		if ( count _inv > 0 ) then 
		{
			[_item,_inv] call fnc_addInvItems;
		};
	
} forEach _items;

true
