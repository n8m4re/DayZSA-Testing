setTimeForScripts 90;

call compile preprocessFileLineNumbers "modulesDayZ\init.sqf";

DZ_MAX_ZOMBIES = 500;
DZ_MAX_ANIMALS = 250;
DZ_MP_CONNECT = true;
DEBUG_SPAWN = false;
DB_DEBUG = false; 

dboffline;
// dbSelectHost "https://192.168.1.2/";
// dbSelectShard "099999";
// dbSelectEnviroment "experimental";

connectedPlayers = [];
for "_x" from 0 to 49 do{connectedPlayers set [_x,0];};
diag_log format ["SCHEDULER: Connected players array init, count %1, %2",count connectedPlayers, connectedPlayers];

call dbLoadPlayer;

// setDate getSystemTime;									
// setDate getLocalTime;
// setDate [2016,12,11,10,0]; //yyyy.mm.dd.hh.mm.

_humidity = random 0.8;
[0,0] setOvercast _humidity;
simulWeatherSync;


[] spawn init_spawnZombies;
sleep 1;
[] spawn init_spawnWildAnimals;

dbInitServer;

setTimeForScripts 0.03;

index = 0;
indexTarget = 50; //indexTarget = 50;
onEachFrame {	
	if (index < 50) then { //if (index < 50) then {
		_playerToTick = connectedPlayers select index;	
		//diag_log format ["SCHEDULER: Select clientId to tick %1 on index %2", _playerToTick, index];	
		if (_playerToTick != 0) then {
			_player = playerOn _playerToTick;		
			if (alive _player) then
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
		indexTarget = (round(diag_fps * 2)) max 50; //indexTarget = (round(diag_fps * 2)) max 50; //ideal is 25fps to get 2s ticks
		index = 0;
	};
};
