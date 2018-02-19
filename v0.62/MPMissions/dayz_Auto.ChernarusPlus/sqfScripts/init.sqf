setTimeForScripts 90;

call compile preprocessFileLineNumbers "\dz\modulesDayZ\init.sqf";

DB_DEBUG = false; 
DZ_SAVE_SLEEP = 120;
DZ_MAX_ZOMBIES = 3500;
DZ_MAX_ANIMALS = 500;
//--------------------------------------------------------------------------------------------------------------------------------------------------------
fnc_reloadWeaponOnSpawn = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_reloadWeaponOnSpawn.sqf";
fnc_addHandsItem = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addHandsItem.sqf";
fnc_addQuickBarItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addQuickBarItems.sqf";
fnc_addItemState = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addItemState.sqf";
fnc_getItemState = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_getItemState.sqf";
fnc_getInvItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_getInvItems.sqf";
fnc_addInvItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addInvItems.sqf";
fnc_dbDestroyProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbCreateCharInProfile.sqf";
fnc_generatePlayerSpawnpoints = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_generatePlayerSpawnpoints.sqf";
fnc_sendNotifiersToEnfusion = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_sendNotifiersToEnfusion.sqf";
fnc_posBubbles = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_posBubbles.sqf";
fnc_previousPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_previousPlayer.sqf";
fnc_newPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_newPlayer.sqf";
event_playerKilled = compile preprocessFileLineNumbers "sqfScripts\events\event_playerKilled.sqf";
init_newBody = compile preprocessFileLineNumbers "sqfScripts\init\init_newBody.sqf";
init_newPlayer = compile preprocessFileLineNumbers "sqfScripts\init\init_newPlayer.sqf";
player_initialize = compile preprocessFileLineNumbers "sqfScripts\init\player_initialize.sqf";
dbSavePlayerPrep = compile preprocessFileLineNumbers "sqfScripts\functions\dbSavePlayerPrep.sqf";
dbSavePlayer = compile preprocessFileLineNumbers "sqfScripts\functions\dbSavePlayer.sqf";
dbLoadPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\dbLoadPlayer.sqf";


//--------------------------------------------------------------------------------------------------------------------------------------------------------
DZ_PLAYER_COUNT = getServerMaxPlayers;
connectedPlayers = [];

for "_x" from 0 to (DZ_PLAYER_COUNT-1) do{connectedPlayers set [_x,0];};
diag_log format ["SCHEDULER: Connected players array init, count %1, %2",count connectedPlayers, connectedPlayers];

call dbLoadPlayer;

_humidity = random 0.8;
[0,0] setOvercast _humidity;
simulWeatherSync;

setWindMaxSpeed 10;
setWindSpeedOfChange 50;
setWindFnMin 0.2;
setWindFnMax 1;

call init_spawnZombies;
sleep 1;
call init_spawnWildAnimals;
sleep 1;
call init_spawnServerEvent;
// dbInitEconomy ["http://127.0.0.1:8181/"];
dbInitEconomy [true];

setTimeForScripts 0.03;

//----- simple scheduler part -----
index = 0;
indexTarget = DZ_PLAYER_COUNT;
onEachFrame {	
	if (index < DZ_PLAYER_COUNT) then {
		_playerToTick = connectedPlayers select index;	
		//diag_log format ["SCHEDULER: Select clientId to tick %1 on index %2", _playerToTick, index];	
		if (_playerToTick != 0) then {
			_player = playerOn _playerToTick;		
			if ((alive _player) and (isSGTicksEnabled)) then
			{
				//diag_log format ["SCHEDULER: Run ticks for clientId %1 on index %2", _playerToTick, index];
				//[_player,format ["DEBUG: Tick tock... diagFPS %1, indexTarget %2", diag_fps, indexTarget],""] call fnc_playerMessage;
				_player call tick_modifiers;	
				_player call tick_states;		
				_player call tick_environment;
				_player call fnc_sendNotifiersToEnfusion;
			};
		};
	};
	index = index + 1;		
	if (index == indexTarget) then {
		indexTarget = (round(diag_fps * 2)) max DZ_PLAYER_COUNT; //indexTarget = (round(diag_fps * 2)) max DZ_PLAYER_COUNT; //ideal is 25fps to get 2s ticks
		index = 0;
	};
};
//---------------------------------

DZ_MP_CONNECT = true;
