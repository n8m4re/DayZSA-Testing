DB_DEBUG=false;DZ_SAVE_SLEEP=0;DZ_MAX_ZOMBIES=0;DZ_MAX_ANIMALS=0;DZ_SPAWN_TIME=30;DZ_MP_CONNECT=false;DZ_PLAYER_COUNT=getServerMaxPlayers;connectedPlayers=[]; for "_x" from 0 to (DZ_PLAYER_COUNT-1) do{connectedPlayers set [_x,0];};
//--------------------------------------------------------------------------------------------------------------------------------------------------------
call compile preprocessFileLineNumbers "\dz\modulesDayZ\init.sqf";
fnc_reloadWeaponOnSpawn = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_reloadWeaponOnSpawn.sqf";
fnc_addHandsItem = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addHandsItem.sqf";
fnc_addQuickBarItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addQuickBarItems.sqf";
fnc_addItemState = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addItemState.sqf";
fnc_getItemState = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_getItemState.sqf";
fnc_getInvItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_getInvItems.sqf";
fnc_addInvItems = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_addInvItems.sqf";
fnc_dbDestroyProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbDestroyProfile.sqf";
fnc_dbFindInProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbFindInProfile.sqf";
fnc_dbLoadFromProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbLoadFromProfile.sqf";
fnc_dbSaveToProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbSaveToProfile.sqf";
fnc_dbCreateCharInProfile = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_dbCreateCharInProfile.sqf";
fnc_generatePlayerSpawnpoints = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_generatePlayerSpawnpoints.sqf";
fnc_posBubbles = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_posBubbles.sqf";
fnc_previousPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_previousPlayer.sqf";
fnc_newPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_newPlayer.sqf";
fnc_createDummy = compile preprocessFileLineNumbers "sqfScripts\functions\fnc_createDummy.sqf";
event_playerKilled = compile preprocessFileLineNumbers "sqfScripts\events\event_playerKilled.sqf";
player_initialize = compile preprocessFileLineNumbers "sqfScripts\init\player_initialize.sqf";
init_newBody = compile preprocessFileLineNumbers "sqfScripts\init\init_newBody.sqf";
dbSavePlayer = compile preprocessFileLineNumbers "sqfScripts\functions\dbSavePlayer.sqf";
dbLoadPlayer = compile preprocessFileLineNumbers "sqfScripts\functions\dbLoadPlayer.sqf";

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// custom stuff

cust_createFullEquipment = compile preprocessFileLineNumbers "sqfScripts\custom\cust_createFullEquipment.sqf";

//--------------------------------------------------------------------------------------------------------------------------------------------------------

