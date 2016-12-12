private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;

// _animalArray = ["Animal_CanisLupus_White","Animal_CanisLupus_Grey","Animal_OvisOrientalis","Animal_SusDomesticus","Animal_SusScrofa","Animal_VulpesVulpes","Animal_UrsusArctos","Animal_OvisAriesF","Animal_OvisAries","Animal_CervusElaphusF","Animal_CervusElaphus","Animal_CapreolusCapreolusF","Animal_CapreolusCapreolus","Animal_CapraHircus"];
_animalArray = ["Animal_CanisLupus_White","Animal_CanisLupus_Grey"];

_type = typeOf _agent;
_last_pos = getPosATL _agent;

_respawn_delay = 1200 + floor(random(120));

diag_log format ["ANIMAL:: %1 DIED at %2, respawn after %3 seconds, timestamp %4",_type, _last_pos, _respawn_delay, time];

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

_types = getArray( configFile >> "CfgSpawns" >> "typesWildAnimals");
{_types set [count _types,_x]} forEach _animalArray;

_rnd = floor(random(count _types));

_wildAnimal = createAgent [ (_types select _rnd), _pos, [], 1, "CAN_COLLIDE"];
//_wildAnimal addeventhandler ["HandleDamage",{_this call event_hitWildAnimal} ];
_wildAnimal addeventhandler ["killed",{null = _this spawn event_killedWildAnimal} ];
_wildAnimal setDir floor(random 360);

diag_log format ["ANIMAL:: %1 spawned at %2, distance from original spot %3",_wildAnimal, _pos, (_pos distance _last_pos)];

true
