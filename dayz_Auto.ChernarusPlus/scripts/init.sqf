DB_DEBUG = false;
player_initialize = 		compile preprocessFileLineNumbers "scripts\init\player_initialize.sqf";
event_playerKilled = 		compile preprocessFileLineNumbers "scripts\events\event_playerKilled.sqf";
fnc_dbDestroyProfile =		compile preprocessFileLineNumbers "scripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile =		compile preprocessFileLineNumbers "scripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile =		compile preprocessFileLineNumbers "scripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile =		compile preprocessFileLineNumbers "scripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile =	compile preprocessFileLineNumbers "scripts\functions\fnc_dbCreateCharInProfile.sqf";
init_spawnChristmasTrees =	compile preprocessFileLineNumbers "scripts\init\spawnChristmasTrees.sqf";
init_spawnACar =			compile preprocessFileLineNumbers "scripts\init\spawnACar.sqf";
dbLoadPlayer =				compile preprocessFileLineNumbers "scripts\functions\dbLoadPlayer.sqf";


init_newPlayer =
{
	//establish default variables
	_this setVariable ["health",DZ_HEALTH];
	_this setVariable ["blood",DZ_BLOOD];
	_this setVariable ["energy",DZ_ENERGY];
	_this setVariable ["water",DZ_WATER];
	_this setVariable ["stomach",DZ_STOMACH];
	_this setVariable ["diet",DZ_DIET];
	_this setVariable ["bodytemperature",DZ_TEMPERATURE];
	_this setVariable ["heatComfort",DZ_HEATCOMFORT];
	_this setVariable ["wet",0];
	_this setVariable ["musclecramp",DZ_MUSCLECRAMP];
	_this setVariable ["restrainedwith",0];
	_this setVariable ["totalHeatIsolation",DZ_TOTALHEATISOLATION];
	_this setVariable ["totalWeight",DZ_TOTALWEIGHT];
	[0,_this,'HitLegs'] call event_modifier; //leg fracture check
	
	//get blood type
	_bloodTypes = getArray (configFile >> "cfgSolutions" >> "bloodTypes"); 
	_rand = random 1; 
	_newType = ""; 
	{ 
		_chance = getNumber (configFile >> "cfgSolutions" >> _x >> "probabilityScale"); 
		if (_rand < _chance) exitWith  
		{ 
			_newType = _x; 
		}; 
	} forEach _bloodTypes;	
	_this setVariable ["bloodtype",_newType];
};


init_newBody =
{
	//manage player body
	playerBodies set [count playerBodies,_agent];
	_agent setVariable ["UID",_uid];
	diag_log format["Recording player %1 with %2",name _agent,_uid];
	
	//move player into body
	_id selectPlayer _agent;
	_agent call player_initialize;	
	[_id] spawnForClient compile "player execFSM '\dz\modulesDayZ\fsm\brain_player_client.fsm'";
	
	_agent addEventHandler ["HandleDamage",{_this call event_assessDamage} ];
		
	//attach inventory handlers
	_agent addEventHandler ["ItemAttached",{_this call event_conatinerAttachedToPlayer} ];
	_agent addEventHandler ["ItemDetached",{_this call event_conatinerDetachedFromPlayer} ];
	
	_agent addEventHandler ["InventoryIn",{_this call event_itemInContainer} ];
	_agent addEventHandler ["InventoryOut",{_this call event_itemOutOfContainer} ];
	
	_agent call calc_heatweight;
	
	
	myNotifiers = _agent getVariable ["myNotifiers",[]];
	
	_id publicVariableClient "myNotifiers";	
};


dbSavePlayerPrep = 
{
	private["_array"];
	_agent = _this;
	//save lifestate
	switch (lifeState _agent) do
	{
		case "UNCONSCIOUS": {
			_agent setVariable ["unconscious",true];
		};
		case "ALIVE": {
			_agent setVariable ["unconscious",false];
		};
		default {
			_agent setVariable ["unconscious",false];
		};
	};
	//save damage
	//diag_log format ["Using %1",DZ_PlayerHitpoints];
	_array = [];
	{
		_v = _agent getHitPointDamage _x;
		//diag_log format ["Saving hitpoint %1 with %2",_x,_v];
		if (_v > 0) then
		{
			_array set [count _array,[_x,_v]];
		};
	} forEach DZ_PlayerHitpoints;
	_agent setVariable ["damageArray",_array];
	//diag_log format ["Saved %1",_array];
};


dbSavePlayer =
{
  _first = _this select 0;
  _killed = false;
	if ((lifeState _agent == "ALIVE") and (not captive _agent)) then
	{
		if ( _first > 0 ) then
		{
			_agent call dbSavePlayerPrep;
			[_uid, _agent] call fnc_dbSaveToProfile;
			diag_log "Saved as alive";
		};
	}
	else
	{
		if (!isNull _agent) then
		{
			[_uid, _agent] call fnc_dbDestroyProfile;
			_agent setDamage 1;
			_killed = true;
			diag_log "Saved as dead";
		}
		else
		{
			diag_log "No save, null";
		};
	};
  _killed
};
