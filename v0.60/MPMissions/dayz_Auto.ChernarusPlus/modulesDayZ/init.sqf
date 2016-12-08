//basic defines
DZ_DEBUG = true;
DZ_MP_CONNECT = false;

//Simulation defines
DZ_TICK = 2;			//how many seconds between each tick
DZ_TICK_COOKING = 4;	//how many seconds between each cooking tick
DZ_THIRST_SEC = 0.13;	// (original was 0.034) how much per second a healthy player needs to drink to stay normal at rest
DZ_METABOLISM_SEC = 0.08; //  (original was 0.05) how much kcal per second a healthy player needs to maintain basal metabolism at rest
DZ_SCALE_SOAK = 1;		//How much an item will soak with water when submerged per tick
DZ_SCALE_DRY = 1;			//Scales how fast things dry
DZ_WET_COOLING = 6;		//The degrees by which a fully wet item will reduce temperature
DZ_COOLING_POINT = 0;	//point at which body changes between warming/cooling
DZ_BODY_TEMP = 36.8;		//Degrees Celcius
DZ_MELEE_SWING = 1.3;		//number of seconds between melee attacks
DZ_FLAME_HEAT = 0.01;	//degrees per second for heating
DZ_BOILING_POINT = 99.97; //degrees of boiling point
DZ_DEW_POINT = 5;		//below which air will fog from player
DZ_WEATHER_CHANGE = 5;	//number of seconds to smooth weather changes in
DZ_DIGESTION_RATE = 1;	//number of ml to consume per second

//medical defines
DZ_BLOOD_UNCONSCIOUS = 500;	//minimum blood before player becomes unconscious
unconscious = false;	//remove this with lifeState is synchronized

//control defines
DZ_KEYS_STUGGLE = [38];	//DIK codes for keys that action struggle out of restraints

//zombie defines
dayz_areaAffect = 3;				//used during attack calculations
zombieActivateDistance = 500;		//The distance which to activate zombies and make them move around
zombieAlertCooldown = 60;		//The distance which to activate zombies and make them move around
zombieClass = ["zombieBase"];		//These are the classes of the zombies, and will be woken by players
totalitems = 0;

//cooldowns
meleeAttack = false;	//set to true during a melee attack (client only).
meleeAttempt = false;	//true while player is trying to melee (holding down)
struggling = false;	//set to true when player is struggling (client only)
meleeAttackType = 1;	//alternates between two attacks

//New player defines
DZ_ENERGY = 1000;	// actual energy from all food and drink consumed
DZ_HUNGER = 0;	//0 to 6000ml size content of stomach, zero is empty
DZ_THIRST = 0; 	//0 to 6000ml size content of stomach, zero is empty
DZ_WATER = 1800;	// actual water from all food and drink consumed
DZ_STOMACH = 1000; // actual volume in stomach
DZ_DIET = 0.5; // actual diet state
DZ_HEALTH = 5000;
DZ_BLOOD = 5000;
DZ_TEMPERATURE = 36.5;
DZ_HEATCOMFORT = 0;
DZ_TOTALWEIGHT = 0;
DZ_TOTALHEATISOLATION = 0;
DZ_MUSCLECRAMP = 0;

//publicVariables
effectDazed = false;	//PVEH Client
actionRestrained = -1;	//PVEH Client
actionReleased = -1;	//PVEH Server
myNotifiers = [];
gettingWet = false;

init_cooker = {};

if (isServer) then
{
	call compile preprocessFileLineNumbers "scripts\init.sqf";
};
