private["_person","_itemCfg","_itemClass","_energy","_water","_stomach","_scale"];
/*
	Calculates how much total volume in the stomach should change based on energy/water used by player for actions or food/drink consumed by player
*/	
_person = _this select 0;
_item = _this select 1;	 

if (typename _item == "STRING") then
{
	_itemClass = _item;
}
else
{
	_itemClass = typeOf _item;
};

_itemCfg = configFile >> "CfgVehicles" >> _itemClass;

if (count _this > 2) then
{
	_scale = _this select 2;
}
else
{
	_scale = 1;
};

if (!isClass _itemCfg) exitWith {};

//if (isNil "_scale") then {_scale = 1;hint "bing!";};

_energy = _person getVariable ["energy",DZ_ENERGY]; // actual energy from all food and drink consumed
_water = _person getVariable ["water",DZ_WATER]; // actual water from all food and drink consumed
_stomach = _person getVariable ["stomach",DZ_STOMACH]; // actual volume in stomach
_diet = _person getVariable ["diet",DZ_DIET]; // actual diet 

_isFood = _itemClass isKindOf "FoodItemBase";
_isDrink = _itemClass isKindOf "DrinksItemBase";
_isMedicine = _itemClass isKindOf "MedicalItemBase";
_randomLiquid = _itemClass isKindOf "BottleBase";

switch true do
{
	case (_isFood || _isDrink || _randomLiquid):
	{
		// pull food and drink nutritions parameters from Nutrition class
		_nutritionConfig = _itemCfg >> "Nutrition";
/*
		if ( _randomLiquid ) then
		{
			_liquidType = (itemInHands _person) getVariable ["liquidType", ""];
			
			if ( _liquidType != "") then
			{
				_nutritionConfig = configFile >> "cfgLiquidTypes" >> _liquidType >> "Nutrition";
			};
		};
*/
		_totalVolume = 0;
		_consumableWater = 0;
		_consumableEnergy = 0;
		_consumableNutriIndex = 0;
		
		if ( !( isNumber (_nutritionConfig >> 'totalVolume'))) then
		{
			// pull food and drink nutritions parameters from Stages class
			//_item = _person getVariable "inUseItem";
			
			_food_stage = _item getVariable 'food_stage';
			_food_stage_name = _food_stage select 0;
			_food_stage_params = getArray (_itemCfg >> "Stages" >> _food_stage_name);
			_nutrition_values = _food_stage_params select 0;
			
			_totalVolume = _nutrition_values select 0;
			_consumableWater = _nutrition_values select 2;
			_consumableEnergy = _nutrition_values select 1;
			_consumableNutriIndex = _nutrition_values select 3;
		}
		else
		{
			_totalVolume = getNumber (_nutritionConfig >> "totalVolume");
			_consumableWater = getNumber (_nutritionConfig >> "water");
			_consumableEnergy = getNumber (_nutritionConfig >> "energy");
			_consumableNutriIndex = getNumber (_nutritionConfig >> "nutritionalIndex");
		};

		//statusChat [format ["D> energy:%1, water:%2, stomach:%3, scale:%4 (%5)",_energy,_water,_stomach,_scale,isNil "_scale"],""]; // debug: actual values of states
		//statusChat [format ["D> _totalVolume:%1, _consumableWater:%2, _consumableEnergy:%3, _consumableNutriIndex: %4",_totalVolume,_consumableWater,_consumableEnergy, _consumableNutriIndex],""]; 

		// volume of portion actually eaten/drunk/used
		_portionVolume = _totalVolume * _scale; // ??Am I sure to get proper scale from actionOnSelf??

		// change energy
		_energyGathered = _consumableEnergy * _scale; // energy actually gathered from serving		
		_energy = _energy + _energyGathered;
		_person setVariable ["energy",_energy];
		//dbStats ["calories",_person,_energyGathered];

		// change water
		_waterGathered = _consumableWater * _scale; // water actually gathered from serving
		_water = _water + _waterGathered;
		_person setVariable ["water",_water];
		//dbStats ["water",_person,_waterGathered];
		
		// change diet
		_dietGathered = _consumableNutriIndex * _scale * 0.01; // nutrients actually gathered from serving	
		_diet = (((9 * _diet) + _dietGathered) / 10) min 1; // diet formula (will be probably changed)
		_person setVariable ["diet",_diet];
		
		// change stomach volume
		_stomach = _stomach + _portionVolume;
		_person setVariable ["stomach",_stomach];
		
		/*
		//transfer item modifiers
		if (typename _item == "STRING") then
		{
			
			_modifiers = getArray (configFile >> "CfgVehicles" >> _b >> "diseases");				
		}
		else
		{
			_modifiers = _item getVariable ['modifiers',[]];
		};
		
		{
			[0,_person,_x] call event_modifier;
		} foreach _modifiers;
		*/
	};
	case _isMedicine:
	{
		_medicineConfig = _itemCfg >> "Medicine";
		_consumablePrevention = getNumber (_medicineConfig >> "prevention");
		
		// change diet
		_dietGathered = _consumablePrevention; // nutrients actually gathered from medicine
		_diet = (((4 * _diet) + _dietGathered) / 5) min 1; // diet formula (will be probably changed)
		_person setVariable ["diet",_diet];
	};
};



true
