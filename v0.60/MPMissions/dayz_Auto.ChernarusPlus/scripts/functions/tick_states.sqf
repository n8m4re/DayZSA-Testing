ProfileStart "tick_states.sqf";
private["_liveState","_person","_client","_modifiers","_modstates","_doSave","_cleanup","_cfgStates"];
/*
	Run each tick to cycle through each state of the player and
	check if any modifier events should occur

	Author: Rocket
*/

//calculate tick
_person = _this;
_client = owner _person;

_modifiers = _person getVariable ["modifiers",[]];
_modstates = _person getVariable["modstates",[]];
_doSave = false;
_cleanup = false;

_cfgStates = configFile >> "CfgVehicles" >> typeOf _person >> "States";

for "_i" from 0 to ((count _cfgStates) - 1) do 
{
	//check each state
	_cfgState = _cfgStates select _i;
	_stateName = configName _cfgState;
	_liveState = _person getVariable [_stateName,0];
	_min = getNumber (_cfgState >> "min");
	_max = getNumber (_cfgState >> "max");
	
	//record initial state
	_initialState = _liveState;
	
	//alter for the tick
	_changeScript = getText (_cfgState >> "change");
	if (_changeScript != "") then
	{
		/*
		State changes each tick, so then check for
		any important events as listed in config
		*/
		_change = _person call compile _changeScript;
		_liveState = _liveState + (_change * DZ_TICK);
		
		//ensure state within parameters
		if (_liveState < _min) then {_liveState = _min};
		if (_liveState > _max) then {_liveState = _max};
		
		//save new value
		_person setVariable [_stateName,_liveState];
			
		//check if went up or down
		_isHigher = (_liveState > _initialState);
		
		//check for events
		_possibleEvents = getArray (_cfgState >> "events");
		{
			private["_modifier","_stage"];
			_modifier = _x;
			_inArray = _modifier in _modifiers;
			_cfgModifier = 	configFile >> "cfgModifiers" >> _modifier;
			
			if (!isClass _cfgModifier) exitWith
			{
				diag_log format["ERROR: %1 not found in CfgModifiers while state checking",_modifier];
				ProfileStop "tick_states.sqf";
			};
			
			if (!_inArray) then
			{
				/*not in array, so:
					- check states to see if should load it
				*/
				_stage = 0;
				call event_fnc_addModifier;	//will add the modifier if condition met
			};
		} forEach _possibleEvents;	
	};
};

//check to see if need to save
call event_fnc_saveModifiers;
ProfileStop "tick_states.sqf";