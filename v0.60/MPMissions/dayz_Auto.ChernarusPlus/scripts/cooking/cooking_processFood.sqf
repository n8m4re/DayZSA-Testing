private ["_state","_food","_params","_config_name","_config_food"];

/*
	Food
	
	Usage:
	[_state, _food, _params] call cooking_processFood
	X = 0 -> transfer diseases
	X = 1 -> food - update progress (cooking)
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_food = _this select 1;
_params = _this select 2;  //additional params

//cooking_base default
_cooking_base_default = ["empty", 0, objNull];

//debugLog
//[player, format["displayname food = %1", displayName _food], "colorStatusChannel"] call fnc_playerMessage;

//config
_config_name = "CfgVehicles";
_config_food = configFile >> _config_name >> typeOf _food;

//cooking params
_food_temperature_coef = 10;
_food_max_temperature_mp = 1.2;
_food_lard_decrease_coef = 0.05;

//food params
_food_stage = _food getVariable ['food_stage', ['Raw']];
_food_stage_name = _food_stage select 0;
_food_stage_params = getArray (_config_food >> "Stages" >> _food_stage_name);

//***********************************************************


//get next food stage name (from cooking action)
_get_next_food_stage_name = 
{
	private["_food","_food_stage_name"];
	_food = _this select 0;
	_food_stage_name = (_food getVariable ['cooking_action_and_stage', ["",""]]) select 1;
	_food_stage_name
};

//get food action/next stage
_get_next_cooking_stage = 
{
	private["_next_action_and_stage","_food_stages","_stage","_stage_name","_action_and_stage"];
	_food_stages = _food_stage_params select 4; //all possible stages from actual food stage
	_action_name = _this select 0;
	
	_next_action_and_stage = ["",""];
	
	for [{_i = 0}, {_i < (count _food_stages)}, {_i = _i + 1}] do
	{
		_action_and_stage = _food_stages select _i;
		_action = _action_and_stage select 0;
		
		if (_action == _action_name) exitWith
		{
			_next_action_and_stage = _action_and_stage;
		};
	};
	
	//debugLog
	//[player, format ["_next_action_and_stage = %1", _next_action_and_stage], "colorStatusChannel"] call fnc_playerMessage;
	
	_next_action_and_stage
};

//get time and min temperature needed to cook for the next stage
_get_cooking_requirements = 
{
	private["_food","_food_stage","_food_stage_params","_cooking_reqs"];
	_food = _this select 0;
	_food_stage = (_food getVariable ['cooking_action_and_stage', ["",""]]) select 1;
	
	_cooking_reqs = [0, 0];
	if (_food_stage != "") then
	{
		_food_stage_params = getArray (_config_food >> "Stages" >> _food_stage);
		_cooking_reqs = (_food_stage_params select 1);
	};
	
	_cooking_reqs
};

//*******************************************************

switch _state do
{	
	//debug
	//check food status
	case -22:
	{
		private['_modifiers','_player'];
		_player = _params select 0;
		_modifiers = _food getVariable ['modifiers',[]];
		
		[_player, format["_food = %1 | _food_stage = %2 | modifiers = %3", displayName _food, _food_stage, _modifiers], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//set coooking stage (based on cooking equipment base ingredient)
	case 2:
	{
		private["_cooking_base","_cooking_action","_cooking_equipment","_next_action_and_stage"];
		_cooking_equipment = _params select 0;
		
		//default
		_cooking_action = 'Drying';
		
		//is cooking stick
		if (_cooking_equipment isKindOf "Crafting_LongWoodenStick") then
		{
			_cooking_action = 'Baking';
		};
		
		//is cooking equipment
		if (_cooking_equipment isKindOf "CookwareBase" or
			_cooking_equipment isKindOf "CookwareContainer") then
		{
			if (quantity _cooking_equipment > 0) exitWith
			{
				_cooking_action = 'Boiling';
			};
			
			if ([_cooking_equipment, 'Food_Lard'] call fnc_isItemInCargo) exitWith
			{
				_cooking_action = 'Baking';
			};
		};
		
		//get cooking action and next cooking stage
		_next_action_and_stage = [_cooking_action] call _get_next_cooking_stage;
		
		//debugLog
		//[player, format["_food = %1 | _next_action_and_stage = %2", displayName _food, _next_action_and_stage], "colorStatusChannel"] call fnc_playerMessage;
		
		_food setVariable ['cooking_action_and_stage', _next_action_and_stage];
	};
	
	//food - update progress (cooking)
	//[params = 0. fireplace temperature, ]
	case 1: 
	{
		private["_temp","_food_stage_set","_cooking_equipment","_food_stage_name_new","_food_stage","_food_temperature","_food_cooking_reqs","_food_cooking_time","_food_min_temperature","_food_time_to_cook"];
		_cooking_equipment_temp = _params select 0;
		_food_time_coef = _params select 1;
		_cooking_equipment = _params select 2;
		
		_food_temperature = _food getVariable ['temperature',0];
		_food_cooking_time = _food getVariable ['cooking_time',0];
		//get food cooking requirements
		_food_cooking_reqs = [_food] call _get_cooking_requirements;
		_food_min_temperature = _food_cooking_reqs select 0;
		_food_time_to_cook = _food_cooking_reqs select 1;
		_food_max_temperature = _food_cooking_reqs select 2; //optional, temperature on which food will be burned
		
		//cooking progress
		if (_cooking_equipment_temp > _food_temperature or 
			_cooking_equipment isKindOf "Crafting_LongWoodenStick") then
		{
			//add temerature
			_food_temperature = _food_temperature + _food_temperature_coef;
			//if minimum temperature for food stage is defined and maximum temperature is not
			if (_food_min_temperature > 0 and
				isNil "_food_max_temperature") then
			{
				_food_temperature = _food_temperature min (_food_min_temperature * _food_max_temperature_mp); //clamp temperature to food minimum temperature * coef
				
				//debugLog
				//[player, format["1. Food %1 temperature %2", displayName _food, _food_temperature], "colorStatusChannel"] call fnc_playerMessage;
			}
			else
			{
				_food_temperature = _food_temperature min (_cooking_equipment_temp / 2); //clamp temperature to cooking equipment temperature divided by 2
				
				//debugLog
				//[player, format["2. Food %1 temperature %2", displayName _food, _food_temperature], "colorStatusChannel"] call fnc_playerMessage;				
			};
			_food setVariable ['temperature', _food_temperature]; 
		
			//debugLog
			//[player, format["Food %1 temperature %2 | isNil Max? = %3", displayName _food, _food_temperature, isNil "_food_max_temperature"], "colorStatusChannel"] call fnc_playerMessage;
			
			if (_food_temperature >= _food_min_temperature and 
				_food_min_temperature > 0) then
			{
				//add time 
				_food_cooking_time = _food_cooking_time + _food_time_coef;
				_food setVariable ['cooking_time', _food_cooking_time];		
				
				//[player, format["Food %1 | food temperature %2 | _food_max_temperature = %3 | _cooking_equipment_temp = %4", displayName _food, _food_temperature, _food_max_temperature, _cooking_equipment_temp], "colorStatusChannel"] call fnc_playerMessage;
				
				//progress to next stage
				if (_food_cooking_time >= _food_time_to_cook) then
				{
					//set next food stage
					_food_stage_name_new = [_food] call _get_next_food_stage_name;
						
					//if max temperature is defined
					if !(isNil "_food_max_temperature") then
					{
						private["_food_stage_name"];
						_food_stage_name = (_food getVariable ['food_stage', ['Raw']]) select 0;
						
						//food temperature exceeds max limit?
						if (_food_temperature > _food_max_temperature and 
							_food_stage_name != 'Burned') then
						{
							_food_stage_name_new = 'Burned'; //set state to burned
						};				
					};
					
					//remove lard quantity if baking
					if (_food_stage_name_new == 'Baked') then
					{
						if !(_food isKindOf 'Food_Lard') then
						{
							_food_lard = [_cooking_equipment, 'Food_Lard'] call fnc_getCargoItem;

							if !(isNull _food_lard) then
							{
								[_food_lard, -_food_lard_decrease_coef] call fnc_addQuantity;
							};						
						};
					};
					
					//debugLog
					//[player, format["Food %1 | _food_stage_name_new %2", displayName _food, _food_stage_name_new], "colorStatusChannel"] call fnc_playerMessage;
					
					//set food stage
					[_food, _food_stage_name_new] call fnc_changeFoodStage;
					
					//reset cooking time
					_food setVariable ['cooking_time', 0];
				};
			};	
			
			//DebugLog
			//[player, format["Update _food_cooking_reqs = %1", _food_cooking_reqs], "colorStatusChannel"] call fnc_playerMessage;
		};
	};
	
	default {};
};