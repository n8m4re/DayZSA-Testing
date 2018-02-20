setTimeForScripts 90;
call compile preprocessFileLineNumbers "sqfScripts\compiles.sqf";

DB_DEBUG = false;
DZ_SAVE_SLEEP = 60; // Player Save every x seconds
DZ_MAX_ZOMBIES = 9999;
DZ_MAX_ANIMALS = 500;

DZ_PLAYER_COUNT = getServerMaxPlayers;
connectedPlayers = [];
for "_x" from 0 to (DZ_PLAYER_COUNT-1) do{connectedPlayers set [_x,0];};

call dbLoadPlayer;

[0,0] setOvercast random 0.8;
simulWeatherSync;

setWindMaxSpeed 10;
setWindSpeedOfChange 50;
setWindFnMin 0.2;
setWindFnMax 1;

call init_spawnZombies;
call init_spawnWildAnimals;
call init_spawnServerEvent;

dbInitEconomy [true];
// dbInitEconomy ["http://127.0.0.1:8181/"];


setTimeForScripts 0.03;

index = 0;
indexTarget = DZ_PLAYER_COUNT;
onEachFrame {	
	if (index < DZ_PLAYER_COUNT) then {
		_playerToTick = connectedPlayers select index;	
		// diag_log format ["SCHEDULER: Select clientId to tick %1 on index %2", _playerToTick, index];	
		if (_playerToTick != 0) then {
			_player = playerOn _playerToTick;		
			if ((alive _player) and (isSGTicksEnabled)) then
			{
				// diag_log format ["SCHEDULER: Run ticks for clientId %1 on index %2", _playerToTick, index];
				// [_player,format ["DEBUG: Tick tock... diagFPS %1, indexTarget %2", diag_fps, indexTarget],""] call fnc_playerMessage;
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

DZ_MP_CONNECT = true;

