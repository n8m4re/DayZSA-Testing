private["_newStage"];
_newStage = _checkStages select _cStage;
/*
important! don't declare these values as private, as it uses its
parents variables
*/
//is condition met?
_condition = getText (_newStage >> "condition");
_runEvent = _person call compile _condition;
if (_runEvent) then
{
	//save old notifier
	_oldNotifier = getArray (_cfgStage >> "notifier");
	
	//load new stage
	_cfgStage = _newStage;
	_cfgStages = _checkStages;
	//statusChat[format["Advancing too...%1 in ; %2",configName _cfgStage,_cfgStages],"colorFriendly"];
	//diag_log format["Stage change to: %1; duration: %2",(_cfgStage),getArray (_cfgStage >> "duration")];
	_remaining = getArray (_cfgStage >> "duration") call randomValue;
	_reminder = getArray (_cfgStage >> "cooldown") call randomValue;
	_stage = _cStage;
	_stageArray set [_cSerial,_stage];
	_modstates set [_i,[_stageArray,_remaining,_reminder]];
	
	//send an activation message
	call event_fnc_sendActvMessage;
	
	//save
	//call event_fnc_saveModifiers;
};
_runEvent
	