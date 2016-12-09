private ["_state","_params"];

/*
	Food
	
	Usage:
	
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_params = _this select 1;  //additional params

//burning
_update_interval = 2;
_fuel_burn_rate = 1; //units per _update_interval
_temperature_inc_rate = 20; //units per _update_interval
_temperature_dec_rate = 50; //units per _update_interval

//gas cooker
_max_cooker_temp = 250; //degree Celsius
_min_cooker_temp = 20; //degree Celsius

//cooking
_cooking_equipment_temp_inc_rate = 10; //units per _update_interval
_cooking_temperature_threshold = 100; //degree Celsius
_cooking_equipment_max_temp = 250; //degree Celsius

//heat transfer
_fireplace_heat_radius = 0.5;


switch _state do
{	
	//heat up/ spend fuel
	//cooking process -> cooking_cookingProcess
	
	case 1:
	{
		_gascooker = _params select 0;
		_fuel_item = _gascooker getVariable 'fuel_item';
		
		//starting fuel level
		_fuel = _fuel_item getVariable ['butane', 0];
		
		//burn
		while { _fuel >= _fuel_burn_rate and 
				(_gascooker getVariable 'fire') } do
		{
			sleep _update_interval; 
			
			//temperature increase
			_temperature = _gascooker getVariable ['temperature', _min_cooker_temp];
			
			if (_temperature <= _max_cooker_temp - _temperature_inc_rate ) then
			{
				_temperature = _temperature + _temperature_inc_rate;
				_gascooker setVariable ['temperature', _temperature];
			};			
			
			//transfer heat to cooking equipment
			_cooking_equipment = _gascooker getVariable ['cooking_equipment', objNull];
			
			if !(isNull _cooking_equipment) then
			{
				_cooking_equipment_temp = _cooking_equipment getVariable ['temperature', _min_cooker_temp];
				
				if (_cooking_equipment_temp >= _cooking_temperature_threshold and
					!(_cooking_equipment getVariable ["is_cooking", false]) ) then
				{
					//start cooking
					[ 1, _cooking_equipment, []] spawn cooking_cookingProcess;
				};
				
				_cooking_equipment setVariable ["temperature", ((_cooking_equipment_temp + _cooking_equipment_temp_inc_rate) min _cooking_equipment_max_temp)];
			};
			
			//spend fuel
			_fuel_item setVariable ['butane', (_fuel - _fuel_burn_rate) max 0]; //clamp
			
			//update fuel level
			_fuel = _fuel_item getVariable ['butane', 0];
		};
		
		//turn off
		[6, [_gascooker]] call gascooker_manageActions;
	};
	
	//colling off
	case 2:
	{
		_gascooker = _params select 0;
		_temperature = _gascooker getVariable ['temperature', _min_cooker_temp];
		_check_cooking = true;
		
		while { _temperature >= _min_cooker_temp and
				!(_gascooker getVariable 'fire') } do
		{
			sleep _update_interval;
			
			_temp_heat_loss_coef = _gascooker getVariable ['temperature_loss_mp', 1];
			_temperature = _temperature - (_temp_heat_loss_coef * _temperature_dec_rate);
			_gascooker setVariable ['temperature', _temperature max 0];
			
			//stop cooking when temperature is below minimum
			if (_temperature < _cooking_temperature_threshold and _check_cooking) then
			{
				_cooking_equipment = _gascooker getVariable ['cooking_equipment', objNull];
				
				if !(isNull _cooking_equipment) then
				{
					_cooking_equipment setVariable ['is_cooking', false];
				};
				
				_check_cooking = false; //check only once
			};			
		};
	};
	
	default {};
};