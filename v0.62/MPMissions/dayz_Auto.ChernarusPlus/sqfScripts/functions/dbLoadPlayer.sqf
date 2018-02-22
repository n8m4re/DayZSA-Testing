
_clientNew =
{
	//_cid  = _this select 2;
	//_pid  = _this select 3;
	
	[_id] spawnForClient {setEVUser -5;disableUserInput true};
	
	_dummy = createAgent ["SurvivorPartsMaleAfrican",[0,0,0],[],0,"NONE"];
	// _dummy setCaptive true;
	_dummy setPosATL [0,0,0];
	_dummy setVariable ["isDummy",true];
	_id selectPlayer _dummy;
	_dummy setDamage 1;
	
	_vm = [_id,_dummy] spawn 
	{
		_id 		= _this select 0;
		_dummy 		= _this select 1;
		_uid 		= getClientUID _id;
		_savedChar 	= _uid call fnc_dbFindInProfile;
		_isAlive 	= _savedChar select 0;
		_pos 		= _savedChar select 2;
		_timer 		= DZ_SPAWN_TIME;
		
		if (_timer > 0) then {
			while {_timer > -1} do {
				[_id,_timer] spawnForClient {titleText[format["Spawning in %1 seconds... Please wait...",(_this select 1)],"PLAIN",10e10]};
				_timer = _timer - 1;
				uiSleep 1;
			};
		};
		
		[_id] spawnForClient {disableUserInput false;titleText["","PLAIN",10e10]};
		
		deleteVehicle _dummy;
	
		uiSleep 1;
	
		if (_isAlive) then {
			[_id,_uid,_pos] call fnc_previousPlayer;
		} else {
			[_id,_uid] call fnc_newPlayer;
		};
			
	};
	
};



_clientRespawn = 
{

	_vm = _id spawn 
	{
		_id 	= _this; 
		_uid 	= getClientUID _id;
		_timer 	= DZ_SPAWN_TIME;

		_uid call fnc_dbDestroyProfile;
		
		_freedPos = connectedPlayers find _id;
		connectedPlayers set [_freedPos,0];
		
		if (_timer > 0) then {
			while {_timer > -1} do {
				[_id,_timer] spawnForClient {titleText[format["Respawning in %1 seconds... Please wait...",(_this select 1)],"PLAIN",10e10]};
				_timer = _timer - 1;
				uiSleep 1;
			};
		};
		
		uiSleep 1;
		
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
	
			_isDummy = _agent getVariable ["isDummy",false];
		
			if (!_isDummy) then 
			{
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
					uiSleep DZ_SPAWN_TIME;
					
					if ( !_killed ) then {
						[1,_uid,_agent] call dbSavePlayer;
					};
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
