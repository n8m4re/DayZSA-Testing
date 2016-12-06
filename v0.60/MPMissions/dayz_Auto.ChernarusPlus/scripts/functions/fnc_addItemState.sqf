private ["_item","_state","_itemVars"];

_item = _this select 0;

_state = _this select 1;

	
	if (isNull _item) exitWith {true};
	
	if !(typeName _state == "ARRAY") exitWith {true};

	_item setDamage (_state select 0);

	// _storeVariables = getArray (configFile >> "CfgVehicles" >> typeOf _item >> "storeVariables"); 

	null = call 
	{
		if ( _item isKindOf "MagazineBase" ) exitWith 
		{
			_item setMagazineAmmo (_state select 1);
		};
	
		_item setQuantity (_state select 1);
	};
	
	_itemVars = _state select 2;
	
	if ( typeName _itemVars == "ARRAY" ) then
	{
		if ( count _itemVars > 0 ) then 
		{ 
			{ _item setVariable [(_x select 0),(_x select 1)] } forEach _itemVars;
		};
	};
	
true
