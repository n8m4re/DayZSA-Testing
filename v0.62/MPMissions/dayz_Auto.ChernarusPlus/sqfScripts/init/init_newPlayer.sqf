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
