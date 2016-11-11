private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;

//dbStats ["hunt",_killer,1];

_type = typeOf _agent;
_last_pos = getPosATL _agent;

//cleanup
//_cleanup_delay = floor(random(300));
sleep 300;

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

// @TODO: randomize zombie type (commented out because of some errors )
//_rnd = floor(random(count DZ_ZombieTypes));

_types = getArray( configFile >> "CfgSpawns" >> "typesWildAnimals");
_rnd = floor(random(count _types));

_wildAnimal = createAgent [ _types select _rnd, _pos, [], 1, "NONE"];
//_wildAnimal addeventhandler ["HandleDamage",{_this call event_hitWildAnimal} ];
_wildAnimal addeventhandler ["killed",{null = _this spawn event_killedWildAnimal} ];
_wildAnimal setDir floor(random 360);

diag_log format ["Wild Animal died: %1, %2 spawned", _type, _wildAnimal];
