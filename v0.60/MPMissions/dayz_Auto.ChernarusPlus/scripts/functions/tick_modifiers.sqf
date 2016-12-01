ProfileStart "tick_modifiers.sqf";
private["_person","_modifiers","_modstates","_client","_i","_cleanup","_client","_array"];
/*
	Run each tick to cycle through each listed modifier and perform the
	modifications, move it to a new state, and gracefully dispose of it
	once finished

	Author: Rocket
*/

//Modifiers: ["classname"]
//Values: [stage,remaining,reminder]

//calculate tick
_person = _this;
_modifiers = _person getVariable ["modifiers",[]];
_modstates = _person getVariable["modstates",[]];

// don't do damage for dead bodies
if(!alive _person) exitWith {ProfileStop "tick_modifiers.sqf";};

if (count _modifiers != count _modstates) exitWith
{
	diag_log "ERROR: Stored modifiers and modstates arrays don't match. Reverting.";
	_person setVariable["modifiers",[]];
	_person setVariable["modstates",[]];	
	ProfileStop "tick_modifiers.sqf";
};

_client = owner _person;
//[_person,format["DEBUG: Modifiers: %1; shock: %2",_modifiers,_person getVariable "shock"],"ColorAction"] call fnc_playerMessage;	//debug
//statusChat["NEW TICK","colorImportant"];
_i = 0;
_cleanup = false;
{
	private["_modifier","_cfgModifier","_cfgStage","_states","_stage","_remaining","_reminder","_permanent","_skipSave","_array","_modifiersArray","_noMessages"];
	_modifier = _x;
	
	//get state data
	_cfgModifier = 	configFile >> "cfgModifiers" >> _modifier;
	_cfgStages =  _cfgModifier >> "Stages";
	_states = _modstates select _i;
	
	//select the stage
	_stage = 0;
	_stageArray = _states select 0;
	_cfgParent = _cfgModifier;
	
	/*
	{
		_stage = _x;
		_cfgStages = _cfgParent >> "Stages";
		_cfgStage = (_cfgStages) select _stage;
	} forEach _stageArray;
	*/
	
	if ((count _stageArray) == 1) then
	{	
		_stage = _stageArray select 0;
		_cfgStages = configFile >> "cfgModifiers" >> _modifier >> "Stages";
		//_cfgStages = _cfgParent >> "Stages"; //PN pull modifier main stages array from configfile
		_cfgStage = (_cfgStages) select _stage;
		_cfgStageName = configName _cfgStage;
	}
	else
	{	
		_childValue = _stageArray select ((count _stageArray) - 1);
		_parentValue = _stageArray select ((count _stageArray) - 2);
		
		_cfgParentStages = configFile >> "cfgModifiers" >> _modifier >> "Stages";
		_cfgParentStage = (_cfgParentStages) select _parentValue;
		
		_cfgChildStages = _cfgParentStage >> "Stages";
		_cfgChildStage = (_cfgChildStages) select _childValue;

		_stage = _childValue;
		_cfgStages = _cfgChildStages;
		_cfgStage = _cfgChildStage;
	};
	
	_remaining = _states select 1;
	_reminder = _states select 2;
	_permanent = count getArray (_cfgStage >> "duration") == 0;
	_noMessages = count getArray (_cfgStage >> "cooldown") == 0;
	_skipSave = false;
	
	//implement modifications
	_modifiersArray = getArray (_cfgStage >> "modifiers");
	{
		private["_v","_b","_b2","_myVal"];
		_v = _x select 0;
		_b = _x select 1;
		_b2 = abs _b;
		_myVal = _person getVariable [_v,0];
		
		if (count _x > 2) then
		{
			/*
			apply additional modifier, such as those
			used in blood calculations (more wounds == higher value)
			*/
			_b = _person call compile format["%1 %2",_b,(_x select 2)];
		};
		
		if ((_b2 > 0) and (_b2 < 1)) then
		{
			//treat as a percentage
			_myVal = _myVal * (1+(_b * DZ_TICK));
		}
		else
		{
			//treat as add/subt
			_myVal = _myVal + (_b * DZ_TICK);
		};			
		_person setVariable [_v,_myVal];
		
	} forEach _modifiersArray;
	
	//check remaining time
	if (_remaining > 0) then
	{
		_remaining = _remaining - (1 * DZ_TICK);
	};
	
	if (_reminder > 0) then
	{
		_reminder = _reminder - (1 * DZ_TICK);
	};
	
	//check whether to play message
	if ((_reminder <= 0) and !_noMessages) then
	{
		private["_messages","_style","_output"];
		//send message
		_messages = getArray (_cfgStage >> "messages");
		if (!isUnconscious _person) then
		{
			if (count _messages > 0) then
			{
				_style = getText (_cfgStage >> "messageStyle");
				_output = (_messages select (floor random(count _messages)));
				[_person,_output,_style] call fnc_playerMessage;
			};
			
			//play sound
			_sounds = getArray (_cfgStage >> "sounds");
			if (count _sounds > 0) then
			{
				_style = getText (_cfgStage >> "messageStyle");
				_output = _sounds select (floor random(count _sounds));
				_person say3D _output;
			};
		};
		
		//reset reminder
		_array = getArray (_cfgStage >> "cooldown");
		_reminder = _array call randomValue;
	};
	
	//check if condition still valid
	_condition = getText (_cfgStage >> "condition");
	_runEvent = _person call compile _condition;
	
	//diag_log format ["Modifier Condition: %1 _runEvent: %2 _permanent: %3",_condition,_runEvent,_permanent];
	
	if (!_runEvent) then
	{
		_cStage = 0;
		for "_c" from 0 to ((count _cfgStages) - 1) do 
		{
			private["_condition","_runEvent"];
			_condition = getText ((_cfgStages select _c) >> "condition");
			_runEvent = _person call compile _condition;
			if (_runEvent) then
			{
				_cStage = _c;
			};
		};
		if (_cStage != 0) then
		{
			_checkStages = _cfgStages;
			_cSerial = (count _stageArray) - 1;
			call event_fnc_advanceModifier;
		}
		else
		{			
			call event_fnc_endModifier;
		};
	} else {
		//check if need to move to next stage
		if (_permanent) then
		{
			//check if should advance within subclass
			if (isClass (_cfgStage >> "Stages")) then
			{
				_checkStages = _cfgStage >> "Stages";
				_cStage = 0;
				_cSerial = (count _stageArray);
				call event_fnc_advanceModifier;
			};

			//check if should advance within class
			_cStage = _stage + 1;
			_totalStages = count _cfgStages;
			if (_totalStages > 0) then {
				if (_cStage > (_totalStages - 1)) exitWith {ProfileStop "tick_modifiers.sqf";};
				if (isClass (_cfgStages select _cStage)) then
				{
					_checkStages = _cfgStages;
					_cSerial = (count _stageArray) - 1;
					call event_fnc_advanceModifier;
				};
			};
		}
		else
		{
			if (_remaining <= 0) then
			{
				//diag_log format ["Ending class, finding what to do"];
				//check if should advance within subclass
				if (isClass (_cfgStage >> "Stages")) then
				{
					//diag_log format ["Advancing to next subclass"];
					_cStage = 0;
					_checkStages = _cfgStage >> "Stages";	//mediumImpact:stages				
					_cSerial = (count _stageArray);	//1
					//statusChat[format["Trying to advancing to subclass...%1 ; %2",_checkStages,_cSerial],"colorFriendly"];
					//hint "dive into the sub-stage";
					call event_fnc_advanceModifier;
				}
				else
				{
					//check if should advance within class, otherwise deletes
					_canGoBack = getNumber (_cfgStage >> "canGoBack") == 1;
					_cStage = _stage + 1;
					_latestCfgStageIndex = (count (_cfgStages)) - 1;				
					
					if (_cStage <= _latestCfgStageIndex) then
					{
						if (isClass (_cfgStages select _cStage)) then
						{
							//diag_log format ["Advancing to next stage within class"];
							//statusChat["Trying to go forward within my class...","colorFriendly"];
							_checkStages = _cfgStages;	
							_cSerial = (count _stageArray) - 1;
							//hint "continue to stage on same level";
							call event_fnc_advanceModifier;
							
							//run ending statement
							_statement = getText (_cfgStage >> "statementExit");	//_person
							call compile _statement;
						}
					}	
					else
					{
						//diag_log format ["No advancing"];
						//check if can drop back					
						if _canGoBack then
						{
							//diag_log format ["Going Backwards"];
							//statusChat["Trying to go backward within my class...","colorFriendly"];
							_cStage = _stage - 1;
							if (isClass (_cfgStages select _cStage)) then
							{
								_result = call event_fnc_advanceModifier;
								if (!_result) then
								{
									call event_fnc_endModifier;
								};
							}
							else
							{
								call event_fnc_endModifier;
							};
						}
						else
						{
							//hint "delete whole modififier";
							call event_fnc_endModifier;
						};
					};
				};
			};
		};
	};

	//check if need to save
	if (!_skipSave) then 
	{
		//save modifier
		_modstates set [_i,[_stageArray,_remaining,_reminder]];
	};
	
	//next modifier
	_i = _i + 1;	
} forEach _modifiers;

//cleanup
if (_cleanup) then
{
	_modifiers = _modifiers - [0];
	_modstates = _modstates - [0];
};

//save to player
_person setVariable["modifiers",_modifiers];
_person setVariable["modstates",_modstates];
ProfileStop "tick_modifiers.sqf";