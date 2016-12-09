private ["_state","_params"];

/*
	Food
	
	Usage:
	
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_params = _this select 1;  //additional params

_fuel_burn_rate = 2; //units per _update_interval

switch _state do
{	
	//on item attached
	case 1:
	{
		_gascooker = _params select 0;
		_item = _params select 1; 

		if (_item isKindOf "CookwareBase" or 
			_item isKindOf "CookwareContainer") then 
		{
			_gascooker setVariable ['cooking_equipment', _item]; //attach cooking equipment
			
			//cooking equipment ready - true
			_item setVariable ['cooking_ready', true];
			
			//refresh visual state
			_item call event_fnc_cookingEquipmentState;
			
			//refresh visual state
			_item call event_fnc_cookingEquipmentState;			
		};
		
		if (_item isKindOf "GasCanisterBase") then 
		{
			_gascooker setVariable ['fuel_item', _item]; //attach fuel
		};	
		
		//debugLog
		//hint format["Item attached '%1'", displayName _item];
	};
	
	//on item detached
	case 2:
	{
		_gascooker = _params select 0;
		_item = _params select 1; 
		
		if (_item isKindOf "CookwareBase" or 
			_item isKindOf "CookwareContainer") then 
		{
			_gascooker setVariable ['cooking_equipment', objNull]; //detach cooking equipment
			
			//cooking equipment ready - false
			_item setVariable ['cooking_ready', false];
			
			//refresh visual state
			_item call event_fnc_cookingEquipmentState;			
		};
		
		if (_item isKindOf "GasCanisterBase") then 
		{
			_gascooker setVariable ['fuel_item', objNull]; //detach fuel
			//set fire off
			_gascooker setVariable ['fire', false];
		};		
		
		//debugLog
		//hint format["Item detached '%1'", displayName _item];
	};
	
	//turn on (action) 
	case 3:
	{
		_gascooker = _params select 0;
		_player = _params select 1;
		
		_gascooker say3D 'flashlight_switch_on';
		
		//turn on
		_fuel_item = _gascooker getVariable 'fuel_item';
		_fuel = _fuel_item getVariable ['butane', 0];
		if (_fuel >= _fuel_burn_rate) then
		{
			[5, [_gascooker]] call gascooker_manageActions;
		}
		else
		{
			[_player, format['There is not enough butane to start a fire.'],'colorAction'] call fnc_playerMessage;
		};
	};
	
	//turn off (action)
	case 4:
	{
		_gascooker = _params select 0;
		
		_gascooker say3D 'flashlight_switch_off';
		
		//stop cooking
		_cooking_equipment = _gascooker getVariable ['cooking_equipment', objNull];
		if !(isNull _cooking_equipment) then
		{
			_cooking_equipment setVariable ['is_cooking', false];
		};
	
		//turn off
		[6, [_gascooker]] call gascooker_manageActions;
	};	
	
	//turn on (state)
	case 5:
	{
		_gascooker = _params select 0;
		
		//set fire on
		_gascooker setVariable ['fire', true];
		
		//start heating
		[1, [_gascooker]] spawn gascooker_manageFire;
	};		
	
	//turn off (state)
	case 6:
	{
		_gascooker = _params select 0;
		
		//set fire off
		_gascooker setVariable ['fire', false];
		
		//start heating
		[2, [_gascooker]] spawn gascooker_manageFire;
	};	
	
	default {};
};