private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;

//dbStats ["kill",_killer,1];

_type = typeOf _agent;
_last_pos = getPosATL _agent;

//cleanup
_respawn_delay = 300 + floor(random(120));

diag_log format ["ZOMBIE:: %1 DIED at %2, respawn after %3 seconds, timestamp %4",_type, _last_pos, _cleanup_delay, time];

sleep _respawn_delay;

_Z_spawnparams = [
  1 / 25.0,     // SPN_gridDensity
  400.0,        // SPN_gridWidth
  400.0,        // SPN_gridHeight
   4.0,         // SPN_minDist2Water
  20.0,         // SPN_maxDist2Water
   0.5,         // SPN_minDist2Static
  30.0,         // SPN_maxDist2Static
  -0.785398163, // SPN_minSteepness
  +0.785398163, // SPN_maxSteepness
  50.0,         // SPN_minDist2Zombie
 170.0,         // SPN_maxDist2Zombie
 125.0,         // SPN_minDist2Player
 270.0          // SPN_maxDist2Player
];

_pos = RespawnDeadNPC [ _last_pos, _Z_spawnparams ];

_types = getArray( configFile >> "CfgSpawns" >> "types");
_rnd = floor(random(count _types));

_zombie = createAgent [_types select _rnd, _pos, [], 1, "NONE"];
_zombie addeventhandler ["HandleDamage",{_this call event_hitZombie} ];
_zombie addeventhandler ["killed",{null = _this spawn event_killedZombie} ];
_zombie setDir floor(random 360);

diag_log format ["ZOMBIE:: %1 spawned at %2, distance from original spot %3",_zombie, _pos, (_pos distance _last_pos)];
