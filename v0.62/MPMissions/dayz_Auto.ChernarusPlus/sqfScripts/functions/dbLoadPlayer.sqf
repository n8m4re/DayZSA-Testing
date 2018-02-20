
_clientNew =
{
	//_cid  = _this select 2;
	//_pid  = _this select 3;
	
	_uid 		= getClientUID _id;
	_savedChar 	= _uid call fnc_dbFindInProfile;
	_isAlive 	= _savedChar select 0;
	_pos 		= _savedChar select 2;
	
	if (_isAlive) then {
		[_id,_uid,_pos] call fnc_previousPlayer;
	} else {
		[_id,_uid] call fnc_newPlayer;
	};

	[_id,DZ_SPAWN_TIME] spawnForClient 
	{	
		_timer = _this select 1;
		DZ_Brightness=0;DZ_Contrast=0;
		if (_timer > 0) then {
			disableUserInput true;
			while {_timer > 0} do 
			{	
				titleText[format["Spawning in %1 seconds... Please wait...",_timer],"BLACK FADED",10e10];			
				_timer = _timer - 1;
				if (_timer <= 0) then {
					DZ_Brightness=1;DZ_Contrast=1;
					titleText["","BLACK",10e10];
					disableUserInput false;
				};
				
				sleep 1;
			};
		};
		
	};
};



_clientRespawn = 
{
	
	_vm = [_agent,_id,_uid] spawn 
	{
		_agent 	= _this select 0;
		_id 	= _this select 1; 
		_uid 	= _this select 2;
		
		_timer 	= DZ_SPAWN_TIME;

		[_uid,_agent] call fnc_dbDestroyProfile;
		
		_freedPos = connectedPlayers find _id;
		connectedPlayers set [_freedPos,0];
		
		if (vehicle _agent != _agent) then {moveOut _agent};
		
		if (alive _agent) then {deleteVehicle _agent};
		
		if (_timer > 0) then {
			while {_timer > 0} do {
				[_id,_timer] spawnForClient {titleText[format["Respawning in %1 seconds... Please wait...",(_this select 1)],"BLACK FADED",10e10]};
				_timer = _timer - 1;
				sleep 1;
			};
		};
		
		[_id] spawnForClient {titleText["","BLACK",1]};
		
		[_id,_uid] call fnc_newPlayer;
		
	};
	
};

_disconnectPlayer =
{	
	_vm = [_agent,_id,_uid,_name] spawn 
	{
		_agent 	= _this select 0;
		_id 	= _this select 1; 
		_uid 	= _this select 2;
		_name 	= _this select 3;
		
		_killed = [0,_uid,_agent] call dbSavePlayer;

		diag_log format ["SCHEDULER: Removing disconnecting clientId %1, name %2", _id, _name];
		
		_freedPos = connectedPlayers find _id;
		if (_freedPos >= 0) then
		{
			connectedPlayers set [_freedPos,0];
			diag_log format ["SCHEDULER: Updated 'connected players' array %1", connectedPlayers];
		};
		
		if (isNull _agent) then
		{
			diag_log format ["SCHEDULER: Agent is null - disconnecting clientId %1, name %2", _id, _name];
		};
		
		if (!isNull _agent) then
		{
			sleep 1;
			
			_agent playAction "SitDown";
			
			sleep DZ_SPAWN_TIME - 1;
			
			if ( !_killed ) then {
				[1,_uid,_agent] call dbSavePlayer;
			};
		};
		
		endDisconnectPlayer [_agent,_uid];
	};
};


onPlayerConnecting _clientNew;
// onClientNew _clientNew;
// onClientReady _clientReady;
onClientRespawn _clientRespawn;
onPlayerDisconnected _disconnectPlayer;
