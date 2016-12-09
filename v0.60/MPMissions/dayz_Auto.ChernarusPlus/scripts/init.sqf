DB_DEBUG = false; 
DEBUG_SPAWN = false;
DZ_SAVE_SLEEP = 120;

//functions
fnc_addHandsItem = compile preprocessFileLineNumbers "scripts\functions\fnc_addHandsItem.sqf";
fnc_addQuickBarItems = compile preprocessFileLineNumbers "scripts\functions\fnc_addQuickBarItems.sqf";
fnc_addItemState = compile preprocessFileLineNumbers "scripts\functions\fnc_addItemState.sqf";
fnc_getItemState = compile preprocessFileLineNumbers "scripts\functions\fnc_getItemState.sqf";
fnc_getInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_getInvItems.sqf";
fnc_addInvItems = compile preprocessFileLineNumbers "scripts\functions\fnc_addInvItems.sqf";
fnc_dbDestroyProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile = compile preprocessFileLineNumbers "scripts\functions\fnc_dbCreateCharInProfile.sqf";
fnc_generatePlayerSpawnpoints = compile preprocessFileLineNumbers "scripts\functions\fnc_generatePlayerSpawnpoints.sqf";
// Temporary function for send notifiers to Enfusion Script
fnc_sendNotifiersToEnfusion = compile preprocessFileLineNumbers "scripts\functions\fnc_sendNotifiersToEnfusion.sqf";

dbLoadPlayer = compile preprocessFileLineNumbers "scripts\functions\dbLoadPlayer.sqf";
dbSavePlayerPrep = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayerPrep.sqf";
dbSavePlayer = compile preprocessFileLineNumbers "scripts\functions\dbSavePlayer.sqf";

tick_environment = compile preprocessFileLineNumbers "scripts\functions\tick_environment.sqf";
tick_modifiers = compile preprocessFileLineNumbers "scripts\functions\tick_modifiers.sqf";
tick_states = compile preprocessFileLineNumbers "scripts\functions\tick_states.sqf";


//initialize
player_initialize = compile preprocessFileLineNumbers "scripts\init\player_initialize.sqf";
init_newPlayer = compile preprocessFileLineNumbers "scripts\init\init_newPlayer.sqf";
init_newBody = compile preprocessFileLineNumbers "scripts\init\init_newBody.sqf";
init_spawnZombies = compile preprocessFileLineNumbers "scripts\init\spawnZombies.sqf";
init_spawnWildAnimals = compile preprocessFileLineNumbers "scripts\init\spawnWildAnimals.sqf";

//cooking
cooking_cookingProcess = compile preprocessFileLineNumbers "scripts\cooking\cooking_cookingProcess.sqf";
cooking_processFood = compile preprocessFileLineNumbers "scripts\cooking\cooking_processFood.sqf";
cooking_manageActions = compile preprocessFileLineNumbers "scripts\cooking\cooking_manageActions.sqf";
//fireplace
fireplace_manageFire = compile preprocessFileLineNumbers "scripts\cooking\fireplace_manageFire.sqf";
fireplace_manageFuel = compile preprocessFileLineNumbers "scripts\cooking\fireplace_manageFuel.sqf";
fireplace_manageState = compile preprocessFileLineNumbers "scripts\cooking\fireplace_manageState.sqf";
fireplace_manageActions = compile preprocessFileLineNumbers	"scripts\cooking\fireplace_manageActions.sqf";
//gascooker
gascooker_manageActions = compile preprocessFileLineNumbers	"scripts\cooking\gascooker_manageActions.sqf";
gascooker_manageFire = compile preprocessFileLineNumbers "scripts\cooking\gascooker_manageFire.sqf";

//events
event_playerKilled = compile preprocessFileLineNumbers "scripts\events\event_playerKilled.sqf";
event_killedZombie = compile preprocessFileLineNumbers "scripts\events\event_killedZombie.sqf";
event_assessDamage = compile preprocessFileLineNumbers "scripts\events\event_assessDamage.sqf";
event_killedWildAnimal = compile preprocessFileLineNumbers "scripts\events\event_killedWildAnimal.sqf";
event_fnc_sendActvMessage = compile preprocessFileLineNumbers "scripts\events\event_fnc_sendActvMessage.sqf";
event_fnc_advanceModifier = compile preprocessFileLineNumbers "scripts\events\event_fnc_advanceModifier.sqf";
event_openCan = compile preprocessFileLineNumbers "scripts\events\event_openCan.sqf";

// PLAYER FUNCTIONS
player_fnc_roundsDistribute = compile preprocessFileLineNumbers "scripts\player\player_fnc_roundsDistribute.sqf";
player_fnc_processStomach = compile preprocessFileLineNumbers "scripts\player\player_fnc_processStomach.sqf";
player_fnc_tickExposure = compile preprocessFileLineNumbers "scripts\player\player_fnc_tickExposure.sqf";
player_plantStages = compile preprocessFileLineNumbers "scripts\player\player_plantStages.sqf";
player_digGreenhouse = compile preprocessFileLineNumbers "scripts\player\player_digGreenhouse.sqf";

// custom
spawnACar =	compile preprocessFileLineNumbers "scripts\custom\spawnACar.sqf";
createFullEquipment = compile preprocessFileLineNumbers "scripts\custom\createFullEquipment.sqf";
spawnChristmasTrees = compile preprocessFileLineNumbers "scripts\custom\spawnChristmasTrees.sqf";

call fnc_generatePlayerSpawnpoints;

// client
player_queued = compile preprocessFileLineNumbers "modulesDayZ\scripts\player_queued.sqf";

