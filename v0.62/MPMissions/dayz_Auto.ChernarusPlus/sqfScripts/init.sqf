setTimeForScripts 90;
call compile preprocessFileLineNumbers "sqfScripts\compiles.sqf";

DB_DEBUG = false;
DZ_SAVE_SLEEP = 60; // Player Save every x seconds
DZ_SPAWN_TIME = 30; // Wait time for spawn in x seconds
DZ_MAX_ZOMBIES = 1200;
DZ_MAX_ANIMALS = 250;

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
call dbLoadPlayer;






//--------------------------------------------------------------------------------------------------------------------------------------------------------
setTimeForScripts 0.03; 
index = 0;
indexTarget = DZ_PLAYER_COUNT;
onEachFrame {	
	if (index < DZ_PLAYER_COUNT) then {
		_playerToTick = connectedPlayers select index;	
		if (_playerToTick != 0) then {
			_player = playerOn _playerToTick;		
			if ((alive _player) and (isSGTicksEnabled)) then
			{
				// if(DB_DEBUG) then {[_player,format ["DEBUG: Tick tock... diagFPS %1, indexTarget %2", diag_fps, indexTarget],""] call fnc_playerMessage;};
				_player call tick_modifiers;	
				_player call tick_states;		
				_player call tick_environment;
				_player call fnc_sendNotifiersToEnfusion;
			};
		};
	};
	index = index + 1;		
	if (index == indexTarget) then {
		indexTarget = (round(diag_fps * 2)) max DZ_PLAYER_COUNT;
		index = 0;
	};
};
DZ_MP_CONNECT = true;