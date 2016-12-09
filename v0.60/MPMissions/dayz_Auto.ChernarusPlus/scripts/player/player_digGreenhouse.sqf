/*
This script handles players' interaction with a greenhouse. Digging, fertilizing and planting is handled here. Plant growth is handled in player_plantStages script.

TO DO: Remove slot offset positions since they are handled in p3d files as Memory Points
*/

private["_greenhouse","_person","_playAnim","_animationLenght","_digToolsConfig","_greenhouseState","_toolParameters", "_isPlayerBusy", "_baseFertility", "_greenhouseConfig"];

// Parameters
_greenhouse		= _this select 0;
_inHandObject	= _this select 1;
_person			= _this select 2;
_passedSlot		= _this select 3;
_isPlayerBusy 	= (_person getVariable ["isUsingSomething",0] == 1);

if (damage _inHandObject == 1) exitWith
{
	[_person, "The tool is ruined.", "colorImportant"] call fnc_playerMessage;
};

// SLOT VALUES
_baseFertility = _greenhouse getVariable "baseFertility";
_greenhouseConfig = [];
_groundType = typeof _greenhouse;
_useRandomRotation = false;
_useTerrainHeight = false;

switch (_groundType) do
{
	case("Land_Misc_Greenhouse"): {
		_useRandomRotation = true;
		_useTerrainHeight = false;
		_baseFertility = 1; // Because fertility is undefined for greenhouses, it has to be redefined.
		_greenhouseConfig = 
		[
			//	[0-state, 1-digging progress in %, 2-[slot offset position], 3-seed type, 4-pile, 5-slot nutrients, 6-texture id in hiddenSelectionsTextures]
		
			// Back row
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			// Left side
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			// Right side
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1]
		];
	};
	
	case("GardenPlot"): {
		_useRandomRotation = false;
		_useTerrainHeight = true;
		if (isNil "_baseFertility") then {
			_baseFertility = 0.1; // Just in case this value is not initialized for some reason.

			_greenhouse setVariable ["baseFertility", _baseFertility];
		};
		_greenhouseConfig = 
		[
			//	[0-state, 1-digging progress in %, 2-[slot offset position], 3-seed type, 4-pile, 5-slot nutrients]
			// East column
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			// Middle column
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			// West column
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1],
			[SLOT_EMPTY, 0, [], "", objNull, _baseFertility, -1]
		];
	};
};

_digToolsConfig = 
[
	// values: 0-tool id name, 1-toolEffectivity, 2-toolAnimation
	["Tool_Shovel",1.0, "digShovel"],
	["Tool_FieldShovel",1.0, "digShovel"],
	["FarmingHoe",1.0, "digHoe"],
	["Pickaxe",1.0, "digHoe"],
	["Tool_Iceaxe",1.0, "PlayerCraft"]
];

_seedsConfig = 
[
	// values: 0-seed id name, (can have more parameters)
	["Cultivation_TomatoSeeds"],
	["Cultivation_PepperSeeds"],
	["Cultivation_PumpkinSeeds"],
	["Cultivation_ZucchiniSeeds"],
	["Fruit_Potato"],
	["Cultivation_CannabisSeeds"]
];

/*-----------------------------------
--------------FUNCTIONS--------------
-----------------------------------*/

fnc_digSlot = {
	_user = _this select 0;
	_diggedObject = _user getVariable "lastDiggedobject";
	_freeSlotId = _diggedObject call fnc_getFreeSlotId;
	_useTerrainHeight = _this select 2;
	_useRandomRotation = _this select 3;
	
	_user setVariable ["isUsingSomething",0];
	
	if ( _freeSlotId > -1 ) then
	{
		itemInHands _user setDamage (damage itemInHands _user + 0.005);
		
		// Create invisible interactive object on slot position
		_slotPos = [_diggedObject, _freeSlotId, _useTerrainHeight] call fnc_getSlotPosition;
		_obj = "DiggedSoil" createVehicle _slotPos;
		_obj setVariable ["soil", _diggedObject];
		_obj setVariable ["slot", _freeSlotId];
		_obj setpos _slotPos;
		
		// Show digged selection on this slot
		_diggedObject animate[ ( "slotDigged_" + ((_freeSlotId+1) call fnc_convertNumber) ) , 0]; // 0 means UNhide!
		_texture = getArray (configfile >> "CfgVehicles" >> typeOf _diggedObject >> "hiddenSelectionsTextures") select 0; // Select the digged (unfertilized) texture
		_diggedObject setObjectTexture [_freeSlotId, _texture];
		
		if (_useRandomRotation) then {
			_obj setDir random 360;
		};
		
		// Give player some worm
		_possiblyFoundWorm = [_user, 0.1] call fnc_giveWorms;
		if (isNull _possiblyFoundWorm) then {
			[_user, "I've prepared the slot.", "colorAction"] call fnc_playerMessage;
		} else {
			[_user, "I've prepared the slot and found a worm in the ground.", "colorAction"] call fnc_playerMessage;
		};
		
		// update the config and mark slot as digged
		_diggedObjectConfig = _diggedObject getVariable "config";
		_slot = _diggedObjectConfig select _freeSlotId;
		_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 3, _obj, _slot select 5, _slot select 6];
		_slot set [0, SLOT_READY ];
		_slot set [1, 0 ];
		_slot set [6, 0];
		
		_diggedObjectConfig set [_freeSlotId, _slot ];
		_diggedObject setVariable ["config", _diggedObjectConfig];
	}
	else
	{
		[_user, "There are no free slots for digging.", "colorImportant"] call fnc_playerMessage;
	};
};

// helper function: get parameters from table based on key
_fnc_getValue =
{
	private ["_table","_key","_ret","_i","_currentKey"];
	_table = _this select 0;  //source table
	_key = _this select 1;  //key to find
	_ret = []; //to be filled with return array
	
	for "_i" from 0 to (count _table - 1 ) do 
	{
		//[_person,format["variable i=%1",_i]] call fnc_playerMessage;
		_currentKey = (_table select _i)select 0;
		if (_currentKey == _key) exitWith
		{
			_ret = (_table select _i);
		};
	};
	_ret;
};

// helper function: check if element is defined in table based on key
_fnc_isDefinedInTable =
{
	private ["_table","_key","_ret","_i","_currentKey"];
	_table = _this select 0;  //source table
	_key = _this select 1;  //key to find
	_ret = false;
	
	for "_i" from 0 to (count _table -1) do 
	{
		_currentKey = (_table select _i)select 0;
		if (_currentKey == _key) exitWith
		{
			_ret = true;
		};
	};
	_ret;
};

// return SLOT_EMPTY or SLOT_INPROGRESS slot if it is available
fnc_getFreeSlotId =
{
	_ret = -1; //to be filled with return array
	_table = (_this getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) step 1 do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		//[_person,format["iterate slot %1 %2.",_i,_slotState],"colorAction"] call fnc_playerMessage;
		
		if ( _slotState == SLOT_INPROGRESS || _slotState == SLOT_EMPTY) exitWith 
		{	
			_ret = _i;
			//[_person,format["Slot %1 selected.",(_slot select 0)],"colorAction"] call fnc_playerMessage;
		};
	};
	_ret;
};

// return SLOT_READY slot id
_fnc_getSlotReadyId =
{
	_ret = -1;
	_table = (_greenhouse getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		if ( _slotState == SLOT_READY ) exitWith 
		{	
			_ret = _i;
		};
	};
	_ret;
};

// returns ID of some fertilized slot. If it cannot find any, it returns ID of some ready slot instead
_fnc_getSlotFertilizedOrReadyId =
{
	_ret = -1;
	_table = (_greenhouse getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		if ( _slotState == SLOT_FERTILIZED ) exitWith 
		{	
			_ret = _i;
		};
	};
	if (_ret == -1) then
	{
		for "_i" from 0 to (count _table - 1 ) do 
		{
			_slot = _table select _i;
			_slotState = _slot select 0;
			if ( _slotState == SLOT_READY ) exitWith 
			{	
				_ret = _i;
			};
		};
	};
	_ret;
};

/*-----------------------------------
----------GREENHOUSE STATES----------
-----------------------------------*/

//if greenhouse is not initialized, then INITIALIZE it + all its slots
_greenhouseState = (_greenhouse getVariable ['config',objNull]);
if ( typeName _greenhouseState == "OBJECT" ) then
{
	//[_person, "INITIALIZE GREENHOUSE","colorAction"] call fnc_playerMessage;
	_greenhouse setVariable ['config', _greenhouseConfig];
}
else
{
	_greenhouseConfig = (_greenhouse getVariable ['config',objNull]);
};

// FIND type of object in hands
_isTool = [_digToolsConfig, typeOf _inHandObject] call _fnc_isDefinedInTable;
_isSeed = [_seedsConfig, typeOf _inHandObject] call _fnc_isDefinedInTable;
_isFertilizer = [fertilizersConfigs, typeOf _inHandObject] call _fnc_isDefinedInTable;

// DIGGING
if ( _isTool && !_isPlayerBusy ) then
{	
	_toolParameters = [_digToolsConfig, typeOf _inHandObject] call _fnc_getValue;

	// get free slot if exists
	_freeSlotId = _greenhouse call fnc_getFreeSlotId;
	
	// dig free slot
	if ( _freeSlotId > -1 ) then
	{
		// Play animation for digging and make him unable to do other actions
		_playAnim		= (_toolParameters select 2);
		_animationLenght	= (_toolParameters select 3);
		
		_result = format["[_this, %1, %2, %3] call fnc_digSlot", _freeSlotId, _useTerrainHeight, _useRandomRotation];
		_person setVariable ["lastDiggedobject", _greenhouse];
		_person playAction [_playAnim, compile _result];
		_person setVariable ["isUsingSomething",1];
	}
	else
	{
		[_person, "There are no free slots for digging.", "colorImportant"] call fnc_playerMessage;
	};
};

// PLANTING
if ( _isSeed && !_isPlayerBusy ) then
{
	_seedParameters = [_seedsConfig, typeOf _inHandObject] call _fnc_getValue;
	
	// get ready slot if exists
	_readySlotId = -1;
	if (isNil "_passedSlot") then
	{
		_readySlotId = call _fnc_getSlotFertilizedOrReadyId;
	}else{
		_readySlotId = _passedSlot;
	};
	
	if ( _readySlotId == -1 ) then
	{
		[_person, "There are no ready slots.", "colorImportant"] call fnc_playerMessage
	}
	else
	{
		_slot = _greenhouseConfig select _readySlotId;
		[_inHandObject, -1] call fnc_addQuantity;

		deleteVehicle (_slot select 4);
		_isFertilized = (_slot select 0 == SLOT_FERTILIZED);
		if (_isFertilized) then {
			[_person, "I've planted a seed into the fertilized soil.", "colorAction"] call fnc_playerMessage;
		}else{
			[_person, "I've planted a seed.", "colorAction"] call fnc_playerMessage;
		};
		if (rain == 0) then{
			[_person, "However the soil is too dry for the plant to grow.","colorAction"] call fnc_playerMessage;
		};

		_greenhouseASLHeight = (getPosASL _greenhouse) select 2;
		
		if (_useTerrainHeight) then {
			[
				_greenhouse, 
				_seedParameters select 0, 
				[0,0,0], // Obsolete since Memory Points in p3ds are used instead
				_readySlotId, 
				_slot select 5, 
				_isFertilized
			] spawn player_plantStages;
		}else{
			[_greenhouse, _seedParameters select 0, _slot select 2, _readySlotId, _slot select 5, _isFertilized] spawn player_plantStages; 
		};
		
		// set slot state to PLANTED
		_slot set [0, SLOT_PLANTED ];
		
		// update table
		_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 4, objNull, _slot select 5, _slot select 6];
		_greenhouseConfig set [ _readySlotId, _slot  ];
		_greenhouse setVariable ['config', _greenhouseConfig];
	};
};

// Fertilization
if (_isFertilizer && !_isPlayerBusy ) then
{
	_FertilizerParams = [fertilizersConfigs, typeOf _inHandObject] call _fnc_getValue;
	// get ready slot if exists
	_readySlotId = -1;
	if (isNil "_passedSlot") then
	{
		_readySlotId = call _fnc_getSlotReadyId;
	}else{
		_readySlotId = _passedSlot;
	};
	
	if ( _readySlotId == -1 ) exitWith
	{
		[_person, "There are no digged slots.", "colorImportant"] call fnc_playerMessage
	};
	
	_slot = _greenhouseConfig select _readySlotId;
	_slotState = _slot select 0;
	if ( _slotState == SLOT_FERTILIZED ) exitWith {
		[_person, "This slot is already fertilized.", "colorImportant"] call fnc_playerMessage;
	};
	
	// Set the correct slot as FERTILIZED
	_slot set [0, SLOT_FERTILIZED ];
	
	// Apply nutrients
	_slot set [5, (_slot select 5) + (_FertilizerParams select 2) ];
	// subtract quantity
	[_inHandObject, -(_FertilizerParams select 3)] call fnc_addQuantity;
	
	// User feedback
	[_person, "I've fertilized the ground.", "colorAction"] call fnc_playerMessage;
	
	// Change pile texture
	_textureID = _FertilizerParams select 1;
	_texture = getArray (configfile >> "CfgVehicles" >> "GardenPlot" >> "hiddenSelectionsTextures") select _textureID; // Select the limed (fertilized) texture
	_greenhouse setObjectTexture [_readySlotId, _texture];
	
	// Update slot texture ID for correct restoring from store
	_slot set [6, _textureID ]; 
	
	// update table
	_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 3, _slot select 4, _slot select 5, _slot select 6];
	_greenhouseConfig set [ _readySlotId, _slot ];
	_greenhouse setVariable ['config', _greenhouseConfig];
	
};