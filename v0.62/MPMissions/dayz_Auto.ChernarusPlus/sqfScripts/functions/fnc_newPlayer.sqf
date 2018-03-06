private ["_id","_uid","_agent"];

_id = _this select 0;

_uid = _this select 1;

_posArr = call fnc_posBubbles;

_pos = _posArr select (floor random (count _posArr));

if (DB_DEBUG) then { _pos = [7053.37,2771.16,11.8116]; };

_mySkin = DZ_SkinsArray select (floor random (count DZ_SkinsArray));

_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");

_myTop = _top select (floor random (count _top));  
_myBottom = _bottom select (floor random (count _bottom));  
_myShoe = _shoe select (floor random (count _shoe));  

_agent = createAgent [_mySkin,  _pos, [], 0, "NONE"];

if (!isNil "cust_createFullEquipment" && DB_DEBUG ) then {

	_agent call cust_createFullEquipment;
_v = _agent createInInventory "Consumable_Stone";
_v = _agent createInInventory "EN5C_Canteen";


} else {

	{null = _agent createInInventory _x} forEach [_myTop,_myBottom,_myShoe];
	
	_v = _agent createInInventory "Consumable_Roadflare";
	_v = _agent createInInventory "Consumable_Rags"; _v setQuantity 1;
	
};

_agent call init_newPlayer;

// _agent initDBIDs[_id,_uid];

[_agent,_uid,_id] call init_newBody;

null = _uid call fnc_dbCreateCharInProfile;	

connectedPlayers set [(connectedPlayers find 0), _id];
	
// null = _agent call fnc_reloadWeaponOnSpawn;


	