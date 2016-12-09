private ["_state","_cooking_equipment","_params"];

/*
	Cooking
	
	Usage:
	[_state, _cooking_equipment, []] call cooking_cookingProcess
	X = 0 -> prepare cooking process
	X = 1 -> begin cooking process
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_cooking_equipment = _this select 1;
_params = _this select 2;

_update_interval = 3; //in seconds
_cooking_temperature_threshold = 100; //degree Celsius --config value?
_cooking_damage_coef = 0.05;

//burning items
_item_temperature_coef = 5; //add value per update for temperature addition in cooking equipment
_cooking_max_temp_other = 150; //max temperature for other (non-ingredient) items in the cooking equipment

/*
class Nutrition
{
	totalVolume = 250;			// total volume for whole pack/quantity in ml/g
	energy = 930;				//372kcal per 100g of ingredient
	//water = 25;				//10ml per 100g of ingredient
	water = -250;				//10ml per 100g of ingredient
	//nutritionalIndex = 0.42;	//dimensionless nutritional index for an ingredient
	nutritionalIndex = 105;		//0.42 per 1g - dimensionless nutritional index for an ingredient
};	
*/

switch _state do
{
	
	//start cooking process
	case 1: 
	{
		//debugLog
		//[player, format["Cooking process start..."], "colorStatusChannel"] call fnc_playerMessage;
		
		//cooking process starts
		_cooking_equipment setVariable ['is_cooking', true];
		
		//cook
		while {_cooking_equipment getVariable ['cooking_ready', false] and
			   _cooking_equipment getVariable ['is_cooking', false]} do
		{
			_cooking_equipment_temp = _cooking_equipment getVariable ["temperature", 20];
			
			//debugLog
			//[player, format["Cooking process...[cooking equipment temp = %1]", _cooking_equipment_temp], "colorStatusChannel"] call fnc_playerMessage;
			
			_cooking_equipment_content = itemsInCargo _cooking_equipment;
				
			//do cooking
			{
				_item = _x;
				
				//cook
				if (_item isKindOf "IngredientBase") then
				{
					//set food cooking action (Frying, Boiling, Drying)
					[2, _item, [_cooking_equipment]] call cooking_processFood;
				
					//update food
					//[_cooking_equipment_temp,_update_interval]
					[1, _item, [_cooking_equipment_temp ,_update_interval, _cooking_equipment]] call cooking_processFood; 
				}
				//damage
				else
				{
					_damage = damage _item;
					_temperature = _item getVariable ['temperature',0];
					
					if (_damage < 1) then
					{
						//add damage
						_item setDamage (_damage + _cooking_damage_coef);
						
						//add temperature
						_temp_new = _temperature + _item_temperature_coef;
						_item setVariable ['temperature', (_temp_new min _cooking_max_temp_other)]; //clamp temperature
					};
				};
			} foreach _cooking_equipment_content;
			
			//hint format["Cooking progress => %1, temperature => %3", _fuel, _temperature];
			sleep _update_interval; 
		};
		
		//cooking ends
		_cooking_equipment setVariable ['is_cooking', false];
		
		//debugLog
		//[player, format["Cooking process end..."], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//cooking on a stick
	case 2: 
	{
		private["_item","_fireplace","_update_interval","_temperature"];
		
		_item = _params select 0;
		_fireplace = _params select 1;
		_update_interval = _params select 2;
		
		//cooking temperature -> fireplace temperature
		_temperature = _fireplace getVariable ['temperature', 0];
		
		//set food cooking action (Frying, Boiling, Drying)
		[2, _item, [_cooking_equipment]] call cooking_processFood;
		
		//update food
		[1, _item, [_temperature ,_update_interval, _cooking_equipment]] call cooking_processFood; 
	};
	
	default {};
};
