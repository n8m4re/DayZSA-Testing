private ["_state", "_fireplace","_item"];

/*
	Manage fireplace - checks.
	
	Usage:
	[_state, fireplace, fuel_item] call fireplace_manageFuel
	X = 0 -> check fuel level
	X = 1 -> check temperature level
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_fireplace = _this select 1;
_item = _this select 2;
_params = _this select 3;

_firewood_energy = 50;
_woodstick_energy = 13;
_book_energy = 10;
_rags_energy = 7;
_medical_band_energy = 7;
_oak_bark_energy = 10;
_birch_bark_energy = 7;
_paper_energy = 5;

switch _state do
{
	//Debug
	//check fuel level
	case -1: 
	{
		private ["_item","_item_obj","_energy_value"];
		
		_fuel_items = _fireplace getVariable 'fuel_items';
		
		for [{_i = 0}, {_i < (count _fuel_items)}, {_i = _i + 1}] do
		{
			_item = _fuel_items select _i;
			_item_obj = _item select 0;
			_energy_value = _item select 1;
			
			if !(isNull _item_obj) then
			{
				[player, format["Fireplace [Attached fuels = %1[%2] (i=%3)]", displayName _item_obj, _energy_value, _i], "colorStatusChannel"] call fnc_playerMessage; 
			};
		};
		
		_kindling_items = _fireplace getVariable 'kindling_items';
		
		for [{_i = 0}, {_i < (count _kindling_items)}, {_i = _i + 1}] do
		{
			_item = _kindling_items select _i;
			_item_obj = _item select 0;
			_energy_value = _item select 1;
			
			if !(isNull _item_obj) then
			{
				[player, format["Fireplace [Attached kindlings = %1[%2] (i=%3)]", displayName _item_obj, _energy_value, _i], "colorStatusChannel"] call fnc_playerMessage; 
			};
		};
		
		//spending fuel 
		_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0]];
		_spending_fuel_item = _spending_fuel select 0;
		_spending_fuel_amount = _spending_fuel select 1;
		[player, format["Fireplace spending fuel = %1[%2]]", displayName _spending_fuel_item, _spending_fuel_amount], "colorStatusChannel"] call fnc_playerMessage; 
	};
	
	
	//add to fuel and kindling items
	case 1: 
	{
		//
		//Fuel
		//		
		_fuel_items = _fireplace getVariable 'fuel_items';
		
		//E1
		if (_item isKindOf "Consumable_Firewood") exitWith
		{
			_fuel_items set [0, [_item, _firewood_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};
		
		//E2
		if (_item isKindOf "Crafting_WoodenStick") exitWith
		{
			_fuel_items set [1, [_item, _woodstick_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};
		
		//E3
		if (_item isKindOf "ItemBook") exitWith
		{
			_fuel_items set [2, [_item, _book_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};
		
		//
		//Kindling
		//
		_kindling_items = _fireplace getVariable 'kindling_items';
		
		//E1
		if (_item isKindOf "Consumable_Rags") exitWith
		{
			_kindling_items set [0, [_item, _rags_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E2
		if (_item isKindOf "Medical_BandageDressing" or 
			_item isKindOf "Medical_Bandage") exitWith
		{
			_kindling_items set [1, [_item, _medical_band_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E3
		if (_item isKindOf "Consumable_Bark_Oak") exitWith
		{
			_kindling_items set [2, [_item, _oak_bark_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E4
		if (_item isKindOf "Consumable_Bark_Birch") exitWith
		{
			_kindling_items set [3, [_item, _birch_bark_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E5
		if (_item isKindOf "Consumable_Paper") exitWith
		{
			_kindling_items set [4, [_item, _paper_energy]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
	};
	
	//remove from fuel and kindling items
	case 2: 
	{
		//
		//Fuel
		//		
		_fuel_items = _fireplace getVariable 'fuel_items';
		
		//E1
		if (_item isKindOf "Consumable_Firewood") exitWith
		{
			_fuel_items set [0, [objNull, 0]]; //[item, energy value]

			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};
		
		//E2
		if (_item isKindOf "Crafting_WoodenStick") exitWith
		{
			_fuel_items set [1, [objNull, 0]]; //[item, energy value]

			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};
		
		//E3
		if (_item isKindOf "ItemBook") exitWith
		{
			_fuel_items set [2, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['fuel_items', _fuel_items];
		};	
		
		//
		//Kindling
		//
		_kindling_items = _fireplace getVariable 'kindling_items';
		
		//E1
		if (_item isKindOf "Consumable_Rags") exitWith
		{
			_kindling_items set [0, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E2
		if (_item isKindOf "Medical_BandageDressing" or 
			_item isKindOf "Medical_Bandage") exitWith
		{
			_kindling_items set [1, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E3
		if (_item isKindOf "Consumable_Bark_Oak") exitWith
		{
			_kindling_items set [2, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E4
		if (_item isKindOf "Consumable_Bark_Birch") exitWith
		{
			_kindling_items set [3, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
		
		//E5
		if (_item isKindOf "Consumable_Paper") exitWith
		{
			_kindling_items set [4, [objNull, 0]]; //[item, energy value]
			
			//set
			_fireplace setVariable ['kindling_items', _kindling_items];
		};
	};
	
	//set spending fuel 
	case 3:
	{
		//set default
		_fireplace setVariable ['spending_fuel', [objNull, 0]];
		
		//check which fuel will be spent
		_fuel_items_count = [4, _fireplace, objNull, ['fuel_items']] call fireplace_manageFuel;
		_kinidling_items_count = [4, _fireplace, objNull, ['kindling_items']] call fireplace_manageFuel;
		_var_name = "kindling_items";
		if (_kinidling_items_count == 0) then //firstly spend items with lowest energy values (kindling)
		{
			_var_name = "fuel_items";
		};
		
		//TODO
		//_fuel_max_coef = _fireplace getVariable ["fuel_max_capacity_mp", 1];
		
		_items = _fireplace getVariable _var_name;
		
		for [{_i = (count _items)-1}, {_i > -1}, {_i = _i-1}] do
		{
			_item = _items select _i;
			_item_obj = _item select 0;
			
			if !(isNull _item_obj) exitWith
			{
				_fireplace setVariable ['spending_fuel', _item];
			};
		};
	};
	
	//spend actual fuel
	case 5:
	{
		_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0] ];
		_item = _spending_fuel select 0;
		[_item, -1] call fnc_addQuantity;
		
		//refresh visual
		[_fireplace] call event_fnc_fireplaceState;
	};

	//get fuel count
	case 4:
	{
		_var_name =  _params select 0;
		_items = _fireplace getVariable [_var_name, []];
		_items_count = 0;
		{
			_item_obj = _x select 0;
			
			if !(isNull _item_obj) then
			{
				_items_count = _items_count + 1;
			};
		} foreach _items;		
		
		_items_count
	};
	
	default {};
};
