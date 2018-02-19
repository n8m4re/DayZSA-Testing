

_clientNew =
{
	//_cid  = _this select 2;
	//_pid  = _this select 3;
	
	_uid = getClientUID _id;
	_savedChar = _uid call fnc_dbFindInProfile;
	_isAlive = _savedChar select 0;
	_pos = _savedChar select 2;
	
		
	if (_isAlive) then 
	{
		[_id,_uid,_pos] call fnc_previousPlayer
		
	} else {
		[_id,_uid] call fnc_newPlayer;
	}
	
};

_clientRespawn = 
{
	[_uid, _agent] call fnc_dbDestroyProfile;
	_freedPos = connectedPlayers find _id;
	connectedPlayers set [_freedPos,0];
	[_id,_uid] call fnc_newPlayer;
};

_disconnectPlayer =
{	
	_vm = [_agent,_id,_uid,_name,0] spawn 
	{
		_agent = _this select 0;
		
		_id = _this select 1; 
		_uid = _this select 2;
		_name = _this select 3;
		_queueTime = _this select 4;
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
			sleep _queueTime;
			if ( !_killed ) then {
				[1,_uid,_agent] call dbSavePlayer;
			};
		};
		
		endDisconnectPlayer [ _agent, _uid ];
	};
};
onPlayerConnecting _clientNew;
// onClientNew _clientNew;
// onClientReady _clientReady;
onClientRespawn _clientRespawn;
onPlayerDisconnected _disconnectPlayer;
