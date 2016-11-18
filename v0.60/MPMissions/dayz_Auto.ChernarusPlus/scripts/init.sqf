DB_DEBUG=false; 
DEBUG_SPAWN=false;


//events
event_playerKilled = compile preprocessFileLineNumbers "scripts\events\event_playerKilled.sqf";
event_killedZombie = compile preprocessFileLineNumbers "scripts\events\event_killedZombie.sqf";
event_assessDamage = compile preprocessFileLineNumbers "scripts\events\event_assessDamage.sqf";
event_killedWildAnimal = compile preprocessFileLineNumbers "scripts\events\event_killedWildAnimal.sqf";

//functions
fnc_getInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_getInvItems.sqf";
fnc_addInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_addInvItems.sqf";
fnc_dbDestroyProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbCreateCharInProfile.sqf";


dbLoadPlayer = compile preprocessFileLineNumbers "scripts\functions\dbLoadPlayer.sqf";
dbSavePlayerPrep = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayerPrep.sqf";
dbSavePlayer = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayer.sqf";
tick_environment = compile preprocessFileLineNumbers "scripts\functions\tick_environment.sqf";


//initialize
player_initialize = compile preprocessFileLineNumbers "scripts\init\player_initialize.sqf";
init_newPlayer = compile preprocessFileLineNumbers "scripts\init\init_newPlayer.sqf";
init_newBody = compile preprocessFileLineNumbers "scripts\init\init_newBody.sqf";


// custom
spawnACar =	compile preprocessFileLineNumbers "scripts\custom\spawnACar.sqf";
createFullEquipment = compile preprocessFileLineNumbers "scripts\custom\createFullEquipment.sqf";
spawnChristmasTrees = compile preprocessFileLineNumbers "scripts\custom\spawnChristmasTrees.sqf";




/*
	PLAYER FUNCTIONS
*/
player_fnc_roundsDistribute = {
	/*
	Used when distributing rounds amongst piles
	uses the _quantity , _person , _ammo, _parent parent variables
	*/
	private["_pile","_receiverQty","_exchanged","_max"];
	/*
	_max = 	getNumber (configFile >> "CfgVehicles" >> _ammo >> "count");
	if (_quantity <= 0) exitWith {};
	_pile = objNull;
	{
		if (_x isKindOf _ammo) then
		{
			//has a pile
			if (!(_x call fnc_isMaxQuantity)) then
			{
				_pile = _x;
				_receiverQty = quantity _pile;
				//process changes
				_exchanged = ((_receiverQty + _quantity) min _max) - _receiverQty;
				_receiverQty = _receiverQty + _exchanged;
				
				_pile addQuantity _exchanged;				
			};
		};
	} forEach itemsInCargo _parent;
	if (_quantity > 0) then 
	{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setMagazineAmmo _quantity;
	};
	*/
	_magdmg = _this;
	
	 _max = getNumber (configFile >> "CfgMagazines" >> _ammo >> "count");
	_sound = getText (configFile >> "CfgMagazines" >> _ammo >> "emptySound");
	
	// _max =  getNumber (configFile >> "CfgVehicles" >> _ammo >> "count");
	 // _sound = getText (configFile >> "CfgVehicles" >> _ammo >> "emptySound");
	
	if (_quantity > _max)then{
		_amam = floor (_quantity/_max);
		if(_amam < 8)then{
			for [{_x=0},{_x<_amam},{_x=_x+1}] do{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setMagazineAmmo _max;
			};
			if(_amam*_max != _quantity)then{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setMagazineAmmo (_quantity-(_amam*_max));
			};
			[_person,_sound] call event_saySound;
		};
	}else{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setMagazineAmmo _quantity;
		[_person,_sound] call event_saySound;
	};
	//if unpacked ammo box is damaged pass it to ammo
	if(_magdmg != 0)then{
		_pile setDamage _magdmg;
	};
};

player_fnc_processStomach = {
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
};
