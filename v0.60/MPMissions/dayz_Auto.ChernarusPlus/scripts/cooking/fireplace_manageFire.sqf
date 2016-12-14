private ["_state","_fireplace","_player","_params","_fuel"];

/*
	Manage fireplace.
	
	Usage:
	[X, fireplacem, player] call fireplace_manageFire
	X = 0 -> heating on
	X = 1 -> cooling off
	X = 2 -> turn fireplace on
	X = 3 -> turn fireplace off
	X = 4 -> re-ignite fire
	X = 5 -> burning process
	
	Author: Lubos Kovac, Peter Nespesny
*/

_state = _this select 0;
_fireplace = _this select 1;
_player = _this select 2;
_params = _this select 3;

_update_interval = 2;
_fuel_burn_rate = 1; //units per _update_interval
_temperature_inc_rate = 20; //units per _update_interval
_temperature_dec_rate = 20; //units per _update_interval

//fireplace
_min_fireplace_temp = 40;
_mid_fireplace_temp = 250; //temperature for fire without fuel items (kindling only)
_max_fireplace_temp = 1000;
_min_temp_to_reignite = 200;
_max_temp_after_extinguish = 80;
_min_fuel_to_ignite = 10; //excluding attached fuel items
_max_wet_level_to_ignite = 0.2;
_max_wet_level_to_burn = 0.5; //heating
_wet_inc_coef = 0.02;
_wet_start_threshold = 0.05;

//heat transfer
_fireplace_heat_radius = 2.5;
_fireplace_heat_wet_coef = 0.02; //speed coef which removes wetness
_fireplace_heat_dam_coef = 0.05; //speed coef which adds damage to item over time

//cooking
_cooking_equipment_temp_inc_rate = 10; //units per _update_interval
_cooking_temperature_threshold = 100; //degree Celsius
_cooking_stick_min_dist = 1.2;
_cooking_equipment_max_temp = 200; //degree Celsius

//boiling liquid
_liquid_boiling_point = 100;
_liquid_clear_modifiers = ['Cholera','Salmonellosis'];

//extinguish
_extinguish_wet_coef = 0.5;
_min_water_to_extinguish = 500; //ml

//burning items
_item_temperature_coef = 10; //add value per update for temperature addition
_cooking_max_temp_other = 200; //max temperature for other (non-ingredient) items in the cooking equipment

_lineHit = 
{
	_source = _this select 0;
	_max_height = _this select 1;
	
	_pos_start = getPosASL _source;
	_pos_end = [_pos_start select 0,_pos_start select 1,(_pos_start select 2)+ _max_height];
	_hits = lineHit [_pos_start, _pos_end, "shadow", _source, objNull, 0];
	(count _hits > 0)
};

_is_player_looking_at_fire = 
{
	_agent = _this select 0;
	_fireplace = _this select 1;
	//oldui	(playerTarget owner _agent == _fireplace)
	false
};

_is_posing = 
{
	_agent = _this select 0;
	
	_state = animationState _agent;
	(_state == 'CdzpAmovPknlMstpSnonWnonDnon_fishingIdle')
};

_get_ignite_animation = 
{
	_item = _this;
	_animation = "";
	
	switch true do
	{
		case (_item isKindOf 'Consumable_Matchbox'): 	{_animation = "startFire";};
		case (_item isKindOf 'Crafting_HandDrillKit'): 	{_animation = "startFire";};
		case (_item isKindOf 'Consumable_Roadflare'): 	{_animation = "ItemUseShort";};
		case (_item isKindOf 'Light_PetrolLighter'): 	{_animation = "ItemUseShort";};
		
		default {_animation = "ItemUseShort";};
	};
	
	_animation
};

_boil_liquid = 
{
	private["_liquid_container"];
	_liquid_container = _this;
	
	//vaporize liquid
	_liquid_container addQuantity -2;
	
	//clear modifiers
	{
		[1, _liquid_container, _x] call event_modifier;
	} forEach _liquid_clear_modifiers;
};

switch _state do
{	
	//TODO - split ignite functionality
	//ignite by match/ hand drill/petrol lighter
	case -1:
	{
		private["_ignition_item","_start_fire"];
		_ignition_item = itemInHands _player;
		
		//PREREQUISITIES	
		//check match quantity
		if (_ignition_item isKindOf 'Consumable_Matchbox' and 
			 quantity _ignition_item < 1) exitWith 
		{
			[_player,format['There are no matches left.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check petrol lighter gas quantity
		if (_ignition_item isKindOf 'Light_PetrolLighter' and 
			 _ignition_item getVariable ['petrol', -1] < 1) exitWith 
		{
			[_player,format['There is no petrol left.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check damage
		if ((damage _ignition_item) >= 1.0) exitWith 
		{
			[_player,format['You cannot start fire. %1 is ruined.', displayName _ignition_item],'colorAction'] call fnc_playerMessage;
		};
		
		//check fuel 
		_kinidling_items_count = [4, _fireplace, objNull, ['kindling_items']] call fireplace_manageFuel;
		
		if (_kinidling_items_count == 0) exitWith 
		{
			[_player,format['There needs to be some kindling to start a fire.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check wetness
		_wet_level = _fireplace getVariable ['wet',0];
		if (_wet_level >= _max_wet_level_to_ignite) exitWith
		{
			[_player,format['The fireplace is too wet to be ignited.'],'colorAction'] call fnc_playerMessage;
		};

		//test collision
		_is_under_roof = [_fireplace, 4] call _lineHit; 
		if  ( _is_under_roof and 
			!(_fireplace isKindOf 'FireplaceIndoor')) exitWith
		{
			[_player,format["I cannot ignite the fireplace here, it's not safe."],'colorAction'] call fnc_playerMessage;
		};
		
		//check rain
		_is_under_roof = [_fireplace, 100] call _lineHit; 
		if ( rain >= _wet_start_threshold and 
			 !_is_under_roof ) exitWith 
		{
			[_player,format['The fire went out because of the rain.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_pos = getPosASL _fireplace;
		_xPos = _pos select 0;
		_yPos = _pos select 1;
		_zPos = _pos select 2;
		_sur = surfaceTypeASL [_xPos, _yPos, _zPos];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot ignite fireplace in the water.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//check wind
		_windStrength = (wind select 0) + (wind select 1) + (wind select 2);
		_probability = 0;

		//set probability to ignite against wind
		switch true do 
		{
			case (_windStrength > 13.9): //[_owner,format['Feels like a strong wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.6;
			};
			case (_windStrength > 10.8): //[_owner,format['Feels like a moderate wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.7;
			};
			case (_windStrength > 5.4): //[_owner,format['Feels like a heavy breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.8;
			};
			case (_windStrength > 1.5): //[_owner,format['Feels like a moderate breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.9;
			};
			case (_windStrength >= 0): //[_owner,format['Feels like only a light breeze'],'colorAction'] call fnc_playerMessage;
			{		
				_probability = 1;
			};
			default
			{
				_probability = 1;
			};
		};
		
		//calculate probability to ignite
		_probability_to_not_ignite = 1 - _probability;
		_probability_to_ignite = random 1;
		if (_ignition_item isKindOf 'Crafting_HandDrillKit') then 
		{
			_probability_to_ignite = _probability_to_ignite * 0.75; //25% chance lower than match(es)
		};
		_start_fire = _probability_to_ignite > _probability_to_not_ignite;
		
		//get animation
		_animation = _ignition_item call _get_ignite_animation;
		
		//set and store parameters
		_player setVariable ['play_action_params', [_fireplace, _ignition_item, _start_fire]];
		_player setVariable ['isUsingSomething', 1];
		_fireplace setVariable ['is_in_use', true];
		_player playAction [_animation, {[-12, objNull, objNull, [_this]] call fireplace_manageFire;}];
	};
	
	//ignite by flare
	case -11:
	{
		private["_ignition_item","_start_fire"];
		_ignition_item = itemInHands _player;
		
		//check flare state
		if !(isOn _ignition_item) exitWith
		{
			[_player,format['The %1 must be lit first.',(displayName _ignition_item)],'colorAction'] call fnc_playerMessage;
		};
		
		//check fuel 
		_kinidling_items_count = [4, _fireplace, objNull, ['kindling_items']] call fireplace_manageFuel;
		
		if (_kinidling_items_count == 0) exitWith 
		{
			[_player,format['There needs to be some kindling to start a fire.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check wetness
		_wet_level = _fireplace getVariable ['wet',0];
		if (_wet_level >= _max_wet_level_to_ignite) exitWith
		{
			[_player,format['The fireplace is too wet to be ignited by flare.'],'colorAction'] call fnc_playerMessage;
		};
		
		//test collision
		_is_under_roof = [_fireplace, 4] call _lineHit; 
		if ( _is_under_roof and 
			!(_fireplace isKindOf 'FireplaceIndoor') ) exitWith
		{
			[_player,format["I cannot ignite the fireplace here, it's not safe."],'colorAction'] call fnc_playerMessage;
		};

		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_pos = getPosASL _fireplace;
		_xPos = _pos select 0;
		_yPos = _pos select 1;
		_zPos = _pos select 2;
		_sur = surfaceTypeASL [_xPos, _yPos, _zPos];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot ignite fireplace in the water.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//Start a fire
		//get animation
		_animation = _ignition_item call _get_ignite_animation;
		
		//set and store parameters
		_player setVariable ['play_action_params', [_fireplace, _ignition_item, true]];
		_player setVariable ['isUsingSomething', 1];
		_fireplace setVariable ['is_in_use', true];
		_player playAction [_animation, {[-12, objNull, objNull, [_this]] call fireplace_manageFire;}];			
	};
	
	//ignite action - end
	case -12:
	{
		private["_ignition_item","_start_fire"];
		_player = _params select 0;		
		_play_action_params = _player getVariable 'play_action_params';
		_fireplace = _play_action_params select 0;
		_ignition_item = _play_action_params select 1;
		_start_fire = _play_action_params select 2;
		
		//CONSUME IGNITION ITEM
		//remove quantity of ignition item (not for flare)
		if (_ignition_item isKindOf 'Crafting_HandDrillKit') then
		{
			_dmg = damage _ignition_item + 0.25; _ignition_item setDamage _dmg; 
			
			if (damage _ignition_item >= 1) then 
			{
				deleteVehicle _ignition_item;
			};
		};
		if (_ignition_item isKindOf 'Consumable_Matchbox') then
		{
			[_ignition_item, -1] call fnc_addQuantity;
		};
		if (_ignition_item isKindOf 'Light_PetrolLighter') then 
		{
			_petrol = _ignition_item getVariable 'petrol';
			_ignition_item setVariable ['petrol', _petrol - 1];
		};
		
		//failed to start fire because of wind
		if !(_start_fire) exitWith
		{
			[_player, format['The fire went out because of the wind.'],'colorAction'] call fnc_playerMessage;
		};
			
		//remove grass beneath the fireplace
		_fireplace_pos = position _fireplace;
		_grassRemoval = "Fireplace_ClutterCutter" createVehicle _fireplace_pos; // Removes the grass around the spot
		_grassRemoval setDir (getDir _fireplace);
		
		//set and clear params
		_player setVariable ['play_action_params', []];
		_player setVariable ['isUsingSomething', 0];
		_fireplace setVariable ['is_in_use', false];
		
		//start fire
		[2, _fireplace, _player, [true]] call fireplace_manageFire;
	};
	
	//**********************************************
	//reignite fire - start
	//blow air into the fire
	case -2:
	{
		_current_temp = _fireplace getVariable ['temperature',20];
		_wet_level = _fireplace getVariable ['wet', 0];
		
		//check wet level
		if (_wet_level > _max_wet_level_to_ignite) exitWith
		{
			[_player,format['Fireplace is too wet to be reignited.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check temperature
		if (_current_temp < _min_temp_to_reignite) exitWith 
		{
			//player message
			[_player,format['The temperature is too low.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//check fuel items
		_fuel_items_count = [4, _fireplace, objNull, ['fuel_items']] call fireplace_manageFuel;
		
		if (_fuel_items_count == 0) then
		{
			//player message
			[_player,format['There is nothing left to burn.'],'colorAction'] call fnc_playerMessage;		
		}
		else
		{
			//start action
			_player setVariable ['play_action_params', [_fireplace]];
			_player setVariable ['isUsingSomething', 1];
			_fireplace setVariable ['is_in_use', true];
			_player playAction ['DrinkPond', {[-22, objNull, _this, []] call fireplace_manageFire}];		
		};
	};
	
	//reignite fire - end
	case -22:
	{
		_params = _player getVariable 'play_action_params';
		_fireplace = _params select 0;
		
		//turn fire on and start heating on
		[2, _fireplace, _player, [false]] call fireplace_manageFire;
		
		//set and clear params
		_player setVariable ['play_action_params', []];
		_player setVariable ['isUsingSomething', 0];
		_fireplace setVariable ['is_in_use', false];
		
		//player message
		[_player,format['Blowing air into the ashes caused the fire to burn.'],'colorAction'] call fnc_playerMessage;
	};
	//**********************************************
	
	//**********************************************
	//extinguish - start
	case -3:
	{
		_water_source = itemInHands _player;
		
		if ((quantity _water_source) < _min_water_to_extinguish) exitWith 
		{
			[_player,format['There is not enough water in the %1 to extinguish the fire.', displayname _water_source],'colorAction'] call fnc_playerMessage;
		};
		
		_player setVariable ['play_action_params', [_fireplace, _water_source]];
		_player setVariable ['isUsingSomething', 1];
		_fireplace setVariable ['is_in_use', true];
		//_player playAction ['extinguishFire', {[-4, objNull, _this, []] call fireplace_manageFire}]; 
		_player playAction ['ItemUseShort', {[-33, objNull, _this, []] call fireplace_manageFire}]; 
	};
	
	//extinguish - end
	case -33:
	{
		private["_temperature","_cooking_equipment"];
		_params = _player getVariable 'play_action_params';
		_fireplace = _params select 0;
		_water_source = _params select 1;
		_fireplace setVariable ['fire',false]; 
		
		//set temperature
		_temperature = _fireplace getVariable ['temperature', 20]; 
		_fireplace setVariable ['temperature', (_temperature min _max_temp_after_extinguish)];
		
		//remove water from the source
		[_water_source, -_min_water_to_extinguish] call fnc_addQuantity;
		
		//stop cooking
		_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
		if !(isNull _cooking_equipment) then
		{
			_cooking_equipment setVariable ['is_cooking', false];
		};
		
		//add wetness to fireplace
		_wet_level = _fireplace getVariable ['wet', 0];
		_fireplace setVariable ['wet', (_wet_level + _extinguish_wet_coef) min 1];
		
		//set and clear params
		_player setVariable ['play_action_params', []];
		_player setVariable ['isUsingSomething', 0];
		_fireplace setVariable ['is_in_use', false];
		
		//turn fire off
		[3, _fireplace, _player, []] call fireplace_manageFire;
		
		//player message
		[_player,format['I have extinguished the fire.'],'colorAction'] call fnc_playerMessage;
	};
	//**********************************************
	
	//Cancel Current Action
	case 999:
	{
		//set and clear player params
		_player setVariable ['isUsingSomething',0]; 
		_player setVariable ['play_action_params',[]]; 
		_fireplace setVariable ['is_in_use', false];
		
		//cancel current animiation
		_player playAction 'CancelAction';
		
		//player message
		[_player, 'Current action was cancelled', ''] call fnc_playerMessage; 
	};
	
	//heating on
	case 0: 
	{
		private["_temperature","_cooking_equipment"];
		//add first fuel by spending available fuel/kindling item
		_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0]];
		_spending_fuel_amount = _spending_fuel select 1;
		
		//visual
		_fireplace setObjectMaterial [0,'dz\gear\cooking\data\stoneground.rvmat'];
		
		//wet level
		_wet_level = _fireplace getVariable ['wet', 0];
		
		//burn
		while {_spending_fuel_amount >= _fuel_burn_rate and
			   _fireplace getVariable ['fire',false] and
			   _wet_level <= _max_wet_level_to_burn
			  } do
		{
			sleep _update_interval; 
			
			//spent fuel 
			_temp_burn_rate = _fireplace getVariable ['fuel_burn_rate_mp', 1];
			_spending_fuel_amount = _spending_fuel_amount - (_temp_burn_rate * _fuel_burn_rate);
			_temperature_modifier = 0; //temperature modifier for various events (e.g. rain), slows down temperature increase
			
			if (_spending_fuel_amount < _fuel_burn_rate) then
			{
				//spend actual fuel item
				[5, _fireplace, objNull, []] call fireplace_manageFuel;
				//set next fuel item
				[3, _fireplace, objNull, []] call fireplace_manageFuel;
				
				//set new fuel amount
				_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0]];
				_spending_fuel_amount = _spending_fuel select 1;
			};
			
			//check wetness
			if (rain >= _wet_start_threshold) then
			{
				//check if fireplace is not under a roof
				_is_under_roof = [_fireplace, 100] call _lineHit; 
				if !( _is_under_roof ) exitWith
				{
					_fireplace setVariable ['wet', (_wet_level + (_wet_inc_coef * rain)) min 1]; //set wetness if rains (max = 1)
					_temperature_modifier = rain * _temperature_inc_rate;
				}; 
			};
			//refresh wet level
			_wet_level = _fireplace getVariable ['wet', 0];
			
			//temperature increase
			_temperature = _fireplace getVariable 'temperature';
			_temperature = _temperature + _temperature_inc_rate - _temperature_modifier;
				
			//check if there is fuel item attached (not just kindling items)
			//temperature is based on the attached fuel items
			_fuel_items_count = [4, _fireplace, objNull, ['fuel_items']] call fireplace_manageFuel;
			if (_fuel_items_count <= 0 ) then
			{
				_temperature = _temperature min _mid_fireplace_temp;
			}
			else 
			{
				_temperature = _temperature min _max_fireplace_temp;
			};
			_fireplace setVariable ['temperature', _temperature];
			
			//burn items
			[5, _fireplace, _player, []] call fireplace_manageFire; //burn items in fireplace
			
			//heat nearest agents
			[6, _fireplace, _player, []] call fireplace_manageFire; //heat nearest agents
			
			//transfer heat to cooking equipment
			_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
			
			if !(isNull _cooking_equipment) then
			{
				_cooking_equipment_temp = _cooking_equipment getVariable ['temperature', _min_fireplace_temp];
				
				if (_cooking_equipment_temp >= _cooking_temperature_threshold and
					!(_cooking_equipment getVariable ["is_cooking", false]) ) then
				{
					//start cooking
					[ 1, _cooking_equipment, []] spawn cooking_cookingProcess;
				};
				
				//temperature is based on temperature of fireplace
				_cooking_equipment_temp = (_cooking_equipment_temp + _cooking_equipment_temp_inc_rate) min _cooking_equipment_max_temp;
				
				_cooking_equipment setVariable ["temperature", _cooking_equipment_temp];
				
				//boil liquid
				if (_cooking_equipment_temp >= _liquid_boiling_point) then
				{
					//boil water
					_cooking_equipment call _boil_liquid;
				};
			};
		};
		
		//turn off fire
		[3, _fireplace, _player, []] call fireplace_manageFire; //turn off bonfire
	};
	
	 //colling off
	case 1:
	{
		private["_temperature","_cooking_equipment"];
		
		//fireplace still exists? (is not buried)
		if (isNil "_fireplace") exitWith {};
		
		private["_temperature","_temp_glow_on"];
		_temperature = _fireplace getVariable 'temperature';
		_check_glow = true; 
		_check_cooking = true;
		
		//wet level
		_wet_level = _fireplace getVariable ['wet', 0];
		
		_is_fire = _fireplace getVariable ['fire',false];
		
		//DebugLog
		//[player,format["Cooling...[%1] | cooling condition = %2", _temperature, (isNil "_fireplace")],'colorAction'] call fnc_playerMessage;
		
		while { !(isNil "_fireplace") and 
				_temperature >= _min_fireplace_temp and
				!_is_fire } do
		{
			sleep _update_interval; 
			
			_temperature_modifier = 0; //temperature modifier for various events (e.g. rain), speed up cooling process
			
			//check wetness
			if (rain > _wet_start_threshold) then
			{
				//check if fireplace is not under a roof
				_is_under_roof = [_fireplace, 50] call _lineHit; 
				if !( _is_under_roof ) exitWith
				{
					_fireplace setVariable ['wet', (_wet_level + (_wet_inc_coef * rain)) min 1]; //set wetness if rains (max = 1)
					_temperature_modifier = rain * _temperature_dec_rate;
				}; 
			};
			//refresh wet level
			_wet_level = _fireplace getVariable ['wet', 0];
			
			//decrease temperature
			_temp_heat_loss_coef = _fireplace getVariable ['temperature_loss_mp', 1];
			_temperature = _temperature - (_temp_heat_loss_coef * _temperature_dec_rate) - _temperature_modifier;
			_temperature = _temperature max 20; //clamp
			_fireplace setVariable ['temperature', _temperature];
			
			//DebugLog
			//hint format["Cooling off\n temperature = %1\n heat loss coef = %2\ntemperature decrease value%3, ",_temperature, _temp_heat_loss_coef, ((_wet_cooling_mp *_wet_level) + 1)];
			
			//stop cooking when temperature is below minimum
			if (_temperature < _cooking_temperature_threshold and _check_cooking) then
			{
				_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
				
				if !(isNull _cooking_equipment) then
				{
					_cooking_equipment setVariable ['is_cooking', false];
				};
				
				_check_cooking = false; //check only once
			};
			
			//turn off glow effect
			if (_temperature <= _min_temp_to_reignite and _check_glow) then
			{
				//visual
				_fireplace setObjectMaterial [0,'dz\gear\cooking\data\stonegroundnoemit.rvmat'];
				_check_glow = false;
							
				//turn light off
				_fireplace switchLight 'OFF';
			};
		};
		
		//DebugLog
		//hint format["Cooled off\n temperature = %1",_temperature];
	};
	
	//turn fire on
	case 2:
	{
		//DebugLog
		//[_player, format["Starting fire... plr = %1, fp = %2", _player, _fireplace], "colorStatusChannel"] call fnc_playerMessage;
		
		//show message for player actions
		_show_message = _params select 0;
		
		//turn fire on
		if !(_fireplace getVariable ['fire',false]) then 
		{
			//set spending fuel on fire start
			[3, _fireplace, objNull, []] call fireplace_manageFuel; //set spending fuel
			
			//turn fire state on
			_fireplace setVariable ['fire', true];
			_fireplace setVariable ['is_fireplace', true];
			
			//turn light on
			_fireplace switchLight 'ON';
			
			//if playAction
			if (_show_message) then 
			{
				//message
				[_player,format["I have started the fire."],'colorAction'] call fnc_playerMessage;
			};
			
			//turn heating on
			[0, _fireplace, _player, []] spawn fireplace_manageFire;
		};
	};
	
	//turn fire off
	case 3:
	{
		//DebugLog
		//[_player, format["Stopping fire..."], "colorStatusChannel"] call fnc_playerMessage;
		
		//spend actual fuel item
		[5, _fireplace, objNull, []] call fireplace_manageFuel;
		
		//turn fire off
		_fireplace setVariable ['fire', false];
		
		//start cooling
		[1, _fireplace, _player, []] spawn fireplace_manageFire; //start cooling off
	};
	
	//burning (damage) process
	case 5:
	{
		{
			private["_item","_name","_damage","_item_temp"];
			_item = _x;
			_name = displayName _item;
			
			_damage = damage _item;
			_item_temp = _item getVariable ['temperature', 20];
			
			if (_damage < 1) then
			{
				//set damage
				_item setDamage (_damage + _fireplace_heat_dam_coef);
				
				//add temerature
				_temp = _item_temp + _item_temperature_coef;
				_item setVariable ['temperature', (_temp min _cooking_max_temp_other)]; //clamp temperature				
				
				//DEBUG
				//[_player, format["Fire damaged item %1.[temperatire = %2]", _name, (_temp min _cooking_max_temp_other)], "colorStatusChannel"] call fnc_playerMessage;
			};
		} foreach itemsInCargo _fireplace;
	};
	
	//warm up nearest agents/cook with stick
	case 6:
	{
		private["_cooking_stick","_agents","_agent","_clothes","_wet_level","_agent_distance"];
		
		//SURVIVOR BASE
		_agents  =  nearestObjects [_fireplace, ["SurvivorBase"], _fireplace_heat_radius];
		{
			_agent = _x;
			_wet_level = _agent getVariable "wet"; //wetness level
			
			//heat comfort
			_agent_distance = (getPosASL _agent) distance (getPosASL _fireplace);
			
			//cooking on a stick
			if ((itemInHands _agent) isKindOf "Crafting_LongWoodenStick" and 
				[6, _agent, [_fireplace]] call fireplace_action_condition and   //facing fireplace
				[7, _agent, []] call fireplace_action_condition) then  			//posing stick towards fireplace
			{
				private["_cooking_stick","_agent_distance","_food"];
				_agent_distance = 0;
				_cooking_stick = itemInHands _agent;
				_food = _cooking_stick getVariable ['food', objNull];
				if (!(isNull _food)) then
				{
					_agent_distance = (getPosASL _agent) distance (getPosASL _fireplace); //get food (on a stick) distance
				};
				
				//debugLog
				//hint format["Cooking preparing... \n_cooking_stick = %1\n _food = %2\n _agent_distance = %3", _cooking_stick, _food, _agent_distance];
				
				if (_agent_distance <= _cooking_stick_min_dist and
					[_agent, _fireplace] call _is_player_looking_at_fire or 
					[_agent] call _is_posing and
					!(isNull _food) and
					(itemParent _food) == _cooking_stick) then
				{
					//debugLog
					//hint format["Cooking... \n_cooking_stick = %1\n _food = %2\n _agent_distance = %3", _cooking_stick, _food, _agent_distance];
					//hint format["Vector direction:\nplayer = %1\nfireplace = %2", vectorDir _agent, vectorDir _fireplace];
				
					//cook	
					[2, _cooking_stick, [_food, _fireplace, _update_interval]] call cooking_cookingProcess;
				};
			};
			
			//wet level
			if !(isNil "_wet_level") then
			{
				if (_wet_level > 0) then
				{
					private["_heat"];
					_heat = _fireplace_heat_wet_coef * (_fireplace_heat_radius - _agent_distance);
					_agent setVariable["wet", (_wet_level - _heat) max 0];
				};
			};
		} forEach _agents;
		
		
		//CLOTHING BASE
		/*
		_clothes  =  nearestObjects [_fireplace, ["ClothingBase"], _fireplace_heat_radius];
		{
			_cloth_object = _x;
			_wet_level = _cloth_object getVariable "wet"; //wetness level
			
			diag_log format["-Item = %1 | wetness = %2", displayName _cloth_object, (_cloth_object getVariable 'wet')];
			
			//wet level
			if !(isNil "_wet_level") then
			{
				//heat comfort
				_cloth_distance = (getPosASL _cloth_object) distance (getPosASL _fireplace);
			
				if (_wet_level > 0) then
				{
					private["_heat"];
					_heat = _fireplace_heat_wet_coef * (_fireplace_heat_radius - _cloth_distance);
					_cloth_object setVariable["wet", (_wet_level - _heat) max 0];
					
					diag_log format["--Item = %1 | wetness = %2", displayName _cloth_object, (_cloth_object getVariable 'wet')];
				};
			};			
		} forEach _clothes;
		*/
	};
	
	default {};
};
