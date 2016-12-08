_cfgSpawns = configFile >> "CfgSpawns" >> "ZombiesSpawns";

DZ_ZombieTypes = getArray(_cfgSpawns >> "types");
DZ_TotalZombies = 0;
_mult = DZ_MAX_ZOMBIES / getNumber(_cfgSpawns >> "serverZombieSpawn");
_totalAreas = ((count _cfgSpawns) - 1);
_posZ = 0;


//real zombie spawning
fnc_spawnZombie = 
{
	DZ_TotalZombies = DZ_TotalZombies + 1;
	_zombie = createAgent [_this select 0, _this select 1,[],0,"CAN_COLLIDE"];
	_zombie addeventhandler ["HandleDamage",{_this call event_hitZombie} ];
	_zombie addeventhandler ["killed",{null = _this spawn event_killedZombie} ];
	_zombie setDir floor(random 360);
	_zombie
};

//count all possible spawning positions
for "_areaNum" from 0 to _totalAreas do 
{
	if ( isClass (_cfgSpawns select _areaNum)) then
	{
		_cfgArea = (_cfgSpawns select _areaNum);
		_posZ = _posZ + count getArray(_cfgArea >> "locations");
	};
};

//make the spawns areas array
_spawnsArray = [];
for "_areaNum" from 0 to _totalAreas do 
{
	_class = _cfgSpawns select _areaNum;
	if ( isClass _class ) then
	{
		_scope = getNumber ( _cfgSpawns >> configName _class >> "scope");
		_maxNumber = getNumber( _cfgSpawns >> configName _class >> "maxSpawn");
		if ( _scope == 2 && _maxNumber > 0) then
		{
			_spawnsArray set [count _spawnsArray, configName _class];
		};
	};
};
/*
//randomize spawns areas array 
for "_areaNum" from 0 to (count _spawnsArray) - 1 do 
{
	_indexR = floor (random (count _spawnsArray));
	_spawnArea = _spawnsArray select _indexR;
	_temp = _spawnsArray select _areaNum;
	
	_spawnsArray set [ _indexR,_temp];
	_spawnsArray set [ _areaNum,_spawnArea];
};
*/

//sort spawns areas array
_xLoop = 0;
while { _xLoop < ((count _spawnsArray) - 2) } do
{
	_spawnArea = _spawnsArray select _xLoop;
	_tempArea = _spawnsArray select (_xLoop + 1);

	_max_SpawnArea = getNumber( _cfgSpawns >> _spawnArea >> "maxSpawn");
	_max_TempArea = getNumber( _cfgSpawns >> _tempArea >> "maxSpawn");

	if ( _max_TempArea > _max_SpawnArea ) then
	{
		_spawnsArray set [ _xLoop, _tempArea ];
		_spawnsArray set [ _xLoop +1, _spawnArea];
		if ( _xLoop > 0 ) then
		{
			_xLoop = _xLoop - 1;
		};
	}
	else
	{
		_xLoop = _xLoop + 1;
	};
};

diag_log format ["spawnArray: %1", _spawnsArray];

/*
{
	diag_log format ["Zombie Spawning >>> Sorted Areas array %1",_x];

} forEach _spawnsArray;
*/

_maxBase =  getNumber ( _cfgSpawns >> "SpawnVillage" >> "maxSpawn");
_lastPopulatedArea = "All";
//spawn zombies in spawns areas
{
	//read data from CfgSpawns
	_class = _cfgSpawns >> _x;

	_areaName = (configName _class);
	_radius = getNumber(_class >> "radius");
	_min = getNumber(_class >> "minSpawn");
	_max = getNumber(_class >> "maxSpawn");
	_locations = getArray(_class >> "locations");
	_types = getArray(_class >> "types");

/* commented out 02.11.2015
we want to try exact numbers of zombies defined in cfgSpawns.hpp
	//calculate dependency on max server population
	if ( _mult < 0.5 && _max <= _maxBase ) then
	{
		_max = _max;
		_min = _min;
	}
	else
	{
		_max = _max * _mult;
		_min = _min * _mult;
	};
*/
	_rnd = random(( _max - _min));
	_cnt = floor ( _min + _rnd );
	_agentTypes = [];
	
	//first get array of the zombie types
	//size of array is exect count of zombies per spawn area (so we can use forEach)
	while{ count _agentTypes < _cnt && count _agentTypes < count _locations } do
	{
		_rType = floor (random( count _types));
		_agentTypes set [ count _agentTypes, _types select _rType];
	};

	//Check for bad defines in config
	if ( count _agentTypes > 0 && count _locations > 0 ) then
	{
		{
			//spawn zombie only if the maximum is not reached
			if ( DZ_TotalZombies < DZ_MAX_ZOMBIES ) then
			{
				_index = floor ( random (count _locations));
				_loc = _locations select _index;
				_sizeLoc = (count _locations) - 1;

				//be sure to not spawn on the same position
				//remove actual position from the array and resize it
				if ( _sizeLoc > 0 ) then
				{
					//_tempIndex = _index;
					for "_int" from _index to _sizeLoc do
					{
						_locations set [ _int, _locations select (_int + 1) ];
						//_tempIndex = _tempIndex + 1;
					};

					_locations resize ( _sizeLoc );
				};

				_zombie = [ _x, _loc] call fnc_spawnZombie;
			}
			else
			{
				//if ( _lastPopulatedArea == "All") then
				//{
					_lastPopulatedArea = configName _class;
				//};
			};
		} forEach _agentTypes;
		
		if ( DZ_TotalZombies <= DZ_MAX_ZOMBIES ) then
		{
			diag_log format ["Zombie Spawning >>> %1 :: %2, Total :: %3",_x,(count _agentTypes), DZ_TotalZombies ];
		};
	};
} forEach _spawnsArray;

//write the results into *.rpt file
_text = format["Zombie Spawning >>> Global locations: %1, SPAWNED %2 ZOMBIES, LAST POPULATED AREA: %3", _posZ,DZ_TotalZombies, _lastPopulatedArea ];
//hint _text;
diag_log _text;
