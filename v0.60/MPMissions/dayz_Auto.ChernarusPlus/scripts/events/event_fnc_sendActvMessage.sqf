//send an activation message
private["_messages","_style","_output","_statement","_print"];
	//_stages = _cfgModifier >> "Stages";
	//_cfgStage = _stages select _stage;


	// don't do damage for dead bodies
	if(!alive _person) exitWith {};

	_postpone = getNumber (_cfgStage >> "postponeMessageUntilCooldown");
	
	if(_postpone == 0) then {
	
		_messages = getArray (_cfgStage >> "messages");
		if (count _messages > 0) then
		{

			_style = getText (_cfgStage >> "messageStyle");
			_output = (_messages select (floor random(count _messages)));
			[_person,_output,_style] call fnc_playerMessage;
		};
		
	};


	_myNotifiers = _person getVariable ["myNotifiers",[]];
	_publishNotifiers = false;
	
	if (count _oldNotifier > 0) then	//blank old notifier
	{
		diag_log format ["notifier>>>before: %1", _myNotifiers];
		_myNotifiers set [_oldNotifier select 0,[]];
		_publishNotifiers = true;
		diag_log format ["notifier>>>after: %1", _myNotifiers];
	};
	
	_notifier = getArray (_cfgStage >> "notifier");
	if (count _notifier > 0) then	//send new notifier
	{	

		_myNotifiers set [_notifier select 0,[_notifier select 1,_notifier select 2]];
		_person setVariable ["myNotifiers",_myNotifiers];		
		_publishNotifiers = true;
	};
	
	if (_publishNotifiers) then
	{
		myNotifiers = _myNotifiers;
		(owner _person) publicVariableClient "myNotifiers";
	};
	
	//execute entry statement
	_statement = getText(_cfgStage >> "statementEnter");
	call compile _statement;
	