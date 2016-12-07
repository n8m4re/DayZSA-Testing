DZ_spawnpass3params = [30.0,70.0,25.0,70.0,0.5,2.0];
DZ_spawnpointsfile = "spawnpoints_players.bin";

queueTime = -12;

_createPlayer = 
{
	diag_log format["CONNECTION: _id: %1 _uid: %2 _name: %3",_id,_uid,_name];
	
	_savedChar = _uid call fnc_dbFindInProfile;
	_isAlive = _savedChar select 0;
	_isOnline = true;
	_pos = _savedChar select 2;
	
	_id updateServerCameraForNewClient _pos;
	
	if (!_isOnline) then
	{
		diag_log format["WARNING: No connection to HIVE. Player %1 could not be loaded.",_uid];
	};
	

	// [_id,_isAlive,_pos,overcast,rain,_isOnline,queueTime,player_queued] spawnForClient {
	//process client
	[_id,_isAlive,queueTime,player_queued] spawnForClient {
		titleText ["","BLACK FADED",10e10];
		player_queued = (_this select 3);
		playerQueueVM = _this call player_queued;
	};
};

//DISCONNECTION PROCESSING
_disconnectPlayer =
{
	if (!isNull _agent) then
	{	
		if (vehicle _agent != _agent) then
		{
			moveOut _agent;
		};

		_killed = [0] call dbSavePlayer;

		_vm = [_uid,_agent,_id,_name,_killed] spawn 
		{
			_uid = _this select 0;
			_agent = _this select 1;
			_id = _this select 2;
			_name = _this select 3;
			_killed = _this select 4;

			_connected = diag_tickTime - (_agent getVariable ["starttime",diag_tickTime]);
			
			diag_log format ["DISCONNECT: Player %1 agent %2 after %3 seconds",_uid,_agent,_connected];
			
			_hands = itemInHands _agent;
					
			_wait = queueTime;
			
			_wait = (-_wait) max 0;
			 
			sleep (_wait - 2);
			
			if ( !_killed ) then {
				[1] call dbSavePlayer;
			};

			//----- simple scheduler part -----
			diag_log format ["SCHEDULER: Removing disconnecting clientId %1, name %2, UID %3", _id, _name, _uid];
			_freedPos = connectedPlayers find _id;
			connectedPlayers set [_freedPos,0];
			diag_log format ["SCHEDULER: Updated 'connected players' array %1", connectedPlayers];
			//---------------------------------	
			
			if (alive _agent) then {
				deleteVehicle _agent;
			};			
		};
	};
};


"clientReady" addPublicVariableEventHandler
{
	_vm = _this spawn {
		_id = _this select 1;
		_uid = getClientUID _id;
		_uidFound = 0;

		for "_i" from 0 to count players - 1 do
   		{
			_actPlayer = players select _i;
			_actPlayerUid = getPlayerUID _actPlayer;
			if ( _actPlayerUid == _uid ) then { _uidFound = 1; };
		};

		if ( _uidFound == 0 ) then 
		{ 
				
				_agent = _uid call fnc_dbLoadFromProfile;
				
				if (isNull _agent) then 
				{ 
					//this should never happen!
					diag_log format["Player %1 has no agent on load, kill character",_uid];
					_id statusChat ["Your character was unable to be loaded and has been reset. A system administrator has been notified. Please reconnect to continue.","ColorImportant"];
				
				} else {
				
					call init_newBody;
					//----- simple scheduler part -----
					diag_log format ["SCHEDULER: Adding ready clientId %1, name %2, UID %3", _id, _name, _uid];
					_freePos = connectedPlayers find 0;
					connectedPlayers set [_freePos,_id];	
					diag_log format ["SCHEDULER: Updated 'connected players' array %1", connectedPlayers];
					//---------------------------------
				};
		};
	};
};

"respawn" addPublicVariableEventHandler
{
	_agent = _this select 1;
	
	// _agent setVariable["respawningPlayer", true];
	 
	diag_log format ["CLIENT request to respawn %1 (%2)",_this,lifeState _agent];
	
	if (lifeState _agent != "ALIVE") then
	{
		_id = owner _agent;
		_uid = getClientUID _id;
		_agent setDamage 1;
		
		[_uid, _agent] call fnc_dbDestroyProfile;
		
		diag_log format ["CLIENT killed character %1 (clientId %2 / Unit %2)",_uid,_id,lifeState _agent];
		
		//----- simple scheduler part -----
		diag_log format ["SCHEDULER: Removing respawning clientId %1, name %2, UID %3", _id, _name, _uid];
		_freedPos = connectedPlayers find _id;
		connectedPlayers set [_freedPos,0];
		diag_log format ["SCHEDULER: Updated 'connected players' array %1", connectedPlayers];
		//---------------------------------
		
		//process client
		[_id,false,queueTime,player_queued] spawnForClient { 
			titleText ["Respawning... Please wait...","BLACK FADED",10e10];
			player_queued = (_this select 3);
			playerQueueVM = _this call player_queued;
		};
	};
};

"clientNew" addPublicVariableEventHandler
{
	_array = _this select 1;
	_id = _array select 2;
	diag_log format ["CLIENT %1 request to spawn %2",_id,_this];
	
	// _id spawnForClient {statusChat ['testing 1 2 3','']};
	
	_savedChar = (getClientUID _id) call fnc_dbFindInProfile;
	
	if (_savedChar select 0) exitWith {diag_log format ["CLIENT %1 spawn request rejected as already alive character",_id]};
		
	_charType = _array select 0;
	_charInv = _array select 1;
	_pos = findCachedSpawnPoint [ DZ_spawnpointsfile, DZ_spawnpass3params ];
	
	if (DEBUG_SPAWN) then 
	{
		_pos = [7201.3716, 3013.104,0]; 
		_pos = [7053.37,2771.16,11.8116]; 
	};
	
	// approximate position of camera needs to be set ASAP (network optimization)
		diag_log format["SPAWN: updateServerCameraForNewCLient for new player"];
	_id updateServerCameraForNewClient _pos;

	//load data
	_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
	_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
	_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");
	
	_myTop = _top select (_charInv select 0);
	_myBottom = _bottom select (_charInv select 1);
	_myShoe = _shoe select (_charInv select 2);
	_mySkin = DZ_SkinsArray select _charType;
	
	_uid = getClientUID _id;
	_res1 = _uid call fnc_dbCreateCharInProfile;
	diag_log format["SERVER: Creating %1 at %2 for clientId %3 (DB result %4)",_mySkin,_pos,_id,_res1];
	
	_agent = createAgent [_mySkin,  _pos, [], 0, "NONE"];
	
	if (DEBUG_SPAWN) then {
		call createFullEquipment;
		_v = _agent createInInventory "tool_flashlight";
		_v = _agent createInInventory "tool_transmitter";
		_v = _v createInInventory "consumable_battery9V";_v setVariable ["power",30000];	
		
		_v = _agent createInInventory "Container_Protector_Small";
		_v = _agent createInInventory "Consumable_Chemlight_White";
		_v = _agent createInInventory "Consumable_Roadflare";
		_v = _agent createInInventory "Consumable_Rags";_v setQuantity 1;
		_v = _agent createInInventory "Consumable_Paper";
		_v = _agent createInInventory "Pen_Green";
		
	} else { 
	
		{null = _agent createInInventory _x} forEach [_myTop,_myBottom,_myShoe];
		_v = _agent createInInventory "Consumable_Roadflare";
		_v = _agent createInInventory "Consumable_Rags";_v setQuantity 1;
	};

	_agent call init_newPlayer;
	call init_newBody;
	
	diag_log format["SERVER: Created %1 for clientId %2",_agent,_id];
	
	//----- simple scheduler part -----
	diag_log format ["SCHEDULER: Adding new clientId %1, name %2, UID %3", _id, _name, _uid];
	_freePos = connectedPlayers find 0;
	connectedPlayers set [_freePos,_id];	
	diag_log format ["SCHEDULER: Updated 'connected players' array %1", connectedPlayers];	
	//---------------------------------
};

// Create player on connection
onPlayerConnecting _createPlayer;
onPlayerDisconnected _disconnectPlayer;