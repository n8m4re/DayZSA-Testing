DB_DEBUG = false; 
DEBUG_SPAWN = false;
DZ_SAVE_SLEEP = 90;

//events
event_playerKilled = compile preprocessFileLineNumbers "scripts\events\event_playerKilled.sqf";
event_killedZombie = compile preprocessFileLineNumbers "scripts\events\event_killedZombie.sqf";
event_assessDamage = compile preprocessFileLineNumbers "scripts\events\event_assessDamage.sqf";
event_killedWildAnimal = compile preprocessFileLineNumbers "scripts\events\event_killedWildAnimal.sqf";

//functions
fnc_addItemState = compile preprocessFileLineNumbers "scripts\functions\fnc_addItemState.sqf";
fnc_getItemState = compile preprocessFileLineNumbers "scripts\functions\fnc_getItemState.sqf";
fnc_getInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_getInvItems.sqf";
fnc_addInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_addInvItems.sqf";
fnc_dbDestroyProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbCreateCharInProfile.sqf";


dbLoadPlayer = compile preprocessFileLineNumbers "scripts\functions\dbLoadPlayer.sqf";
dbSavePlayerPrep = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayerPrep.sqf";
dbSavePlayer = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayer.sqf";
tick_environment = compile preprocessFileLineNumbers "scripts\functions\tick_environment.sqf";


//initialize
player_initialize = compile preprocessFileLineNumbers "scripts\init\player_initialize.sqf";
init_newPlayer = compile preprocessFileLineNumbers "scripts\init\init_newPlayer.sqf";
init_newBody = compile preprocessFileLineNumbers "scripts\init\init_newBody.sqf";


// custom
spawnACar =	compile preprocessFileLineNumbers "scripts\custom\spawnACar.sqf";
createFullEquipment = compile preprocessFileLineNumbers "scripts\custom\createFullEquipment.sqf";
spawnChristmasTrees = compile preprocessFileLineNumbers "scripts\custom\spawnChristmasTrees.sqf";



// PLAYER FUNCTIONS
player_fnc_roundsDistribute = compile preprocessFileLineNumbers "scripts\player\player_fnc_roundsDistribute.sqf";
player_fnc_processStomach = compile preprocessFileLineNumbers "scripts\player\player_fnc_processStomach.sqf";

