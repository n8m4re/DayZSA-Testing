private["_agent","_uid"];

_agent = _this select 0;

_killer = _this select 1;

_type = typeOf _agent;

_last_pos = getPosATL _agent;

_respawn_delay = 1200 + floor(random(120));

diag_log format ["ANIMAL:: %1 DIED at %2, respawn after %3 seconds, timestamp %4",_type, _last_pos, _respawn_delay, time];

sleep _respawn_delay;

_pos = RespawnDeadNPC [_last_pos,[1/25.0,400.0,400.0,4.0,20.0,0.5,30.0,-0.785398163,+0.785398163,50.0,170.0,125.0,270.0]];

_types = getArray( configFile >> "CfgSpawns" >> "typesWildAnimals");

{_types set [count _types,_x]} forEach DZ_AnimalsTypes;

_rnd = floor(random(count _types));

_wildAnimal = createAgent [ (_types select _rnd), _pos, [], 1, "CAN_COLLIDE"];

_wildAnimal addeventhandler ["killed",{null = _this spawn event_killedWildAnimal} ];

_wildAnimal setDir floor(random 360);

diag_log format ["ANIMAL:: %1 spawned at %2, distance from original spot %3",_wildAnimal, _pos, (_pos distance _last_pos)];

true
