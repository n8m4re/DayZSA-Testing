//basic defines
DZ_DEBUG = true;
DZ_MP_CONNECT = false;


//Simulation defines
DZ_TICK = 2;			//how many seconds between each tick
DZ_TICK_COOKING = 4;	//how many seconds between each cooking tick
DZ_THIRST_SEC = 0.13;	// (original was 0.034) how much per second a healthy player needs to drink to stay normal at rest
DZ_METABOLISM_SEC = 0.07; //  (original was 0.05) how much kcal per second a healthy player needs to maintain basal metabolism at rest
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

//generate skins
_format = getText(configFile >> "cfgCharacterCreation" >> "format");
DZ_SkinsArray = [];
{
	_gender = _x;
	{
		_race = _x;
		DZ_SkinsArray set [count DZ_SkinsArray,format[_format,_gender,_race]];
	} forEach getArray(configFile >> "cfgCharacterCreation" >> "race");
	{
		DZ_SkinsArray set [count DZ_SkinsArray,format[_format,_gender,_x]];
	}  forEach getArray(configFile >> "cfgCharacterCreation" >> format["%1custom",_gender]);
} forEach getArray(configFile >> "cfgCharacterCreation" >> "gender");

_format = getText(configFile >> "cfgCharacterCreation" >> "format");
_gender = getArray(configFile >> "cfgCharacterCreation" >> "gender");
_race = getArray(configFile >> "cfgCharacterCreation" >> "race");
_skin = getArray(configFile >> "cfgCharacterCreation" >> "skin");
_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");	

event_saySound =
{
	private["_unit","_type","_chance","_rnd","_sound","_local","_dis"];
	_unit = _this select 0;
	_type = _this select 1;

	_doSound = true;
	if (count _this > 2) then
	{
		_rnd = (0 min (_this select 2)) max 1;
		//random check
		if ((random 1) < _rnd) then {}
		else
		{
			_type == ""
		};
	};

	//[_person,"craft_rounds"] call event_saySound;
	if (_type == "") exitWith {};

	_config = 	configFile >> "CfgActionSounds" >> _type;
	_sounds = 	getArray (_config >> "sounds");
	_distance = getNumber (_config >> "distance");

	if (count _sounds > 0) then
	{
		_sound = _sounds select (floor random (count _sounds));
		_unit say3D _sound;
	};
};

ui_fnc_createDefaultChar = {
	_lastInv = profileNamespace getVariable ["lastInventory",[]];
	_lastChar = profileNamespace getVariable ["lastCharacter",""];
	if (typeOf demoUnit != _lastChar) then
	{
		deleteVehicle demoUnit;
		demoUnit = _lastChar createVehicleLocal demoPos;
		demoUnit setPos demoPos;
		demoUnit setDir createDir;
	};
	if (isNull demoUnit) exitWith {};
	{
		if !((typeOf _x) in _lastInv) then {deleteVehicle _x};				
	} forEach itemsInInventory demoUnit;
	_myInv = itemsInInventory demoUnit;
	{
		null = demoUnit createInInventory _x;
	} forEach _lastInv;
	demoUnit call ui_fnc_animateCharacter;
};

ui_fnc_animateCharacter =
{
	_anims = [];
	_anim = "";
	_inventory = itemsInInventory _this;
	_shoulder = _this itemInSlot "shoulder";
	_melee = _this itemInSlot "melee";

	_chainsaw = objNull;
	_pistol = objNull;
	_knife = objNull;
	_baseballBat = objNull;
	
	{
		if ( _x isKindOf "Chainsaw" ) then
		{
			_chainsaw = _x;
		};
		if ( _x isKindOf "Pistol" ) then
		{
			_pistol = _x;
		};
		if ( _x isKindOf "KnifeBase" ) then
		{
			_knife = _x;
		};
		if (  _x isKindOf "BaseballBat" ) then
		{
			_baseballBat = _x;
		};
	
	} forEach itemsInInventory _this;

	diag_log format["UI: %1 / %2",_shoulder,_melee];

	_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleUnarmed0" >> "variantsPlayer");
	_anims resize 0;
	_anims = _anims + ["menu_idleUnarmed0"];
	
	for "_i" from 0 to (count _animsRaw) - 1 step 2 do
	{
		_anims set [ count _anims, _animsRaw select _i];
	};
	
	//_anim = "menu_idleUnarmed0";

	if ( !isNull _baseballBat ) then
	{
		_this moveToHands _baseballBat;

		_anims resize 0;
		_anims = _anims + ["menu_idleBat0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleBat0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( !isNull _chainsaw ) then
	{
		_this moveToHands _chainsaw;

		_anims resize 0;
		_anims = _anims + ["menu_idleChainsaw0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleChainsaw0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( !isNull _knife ) then
	{
		_this moveToHands _knife;

		_anims resize 0;
		_anims = _anims + ["menu_idleKnife0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleKnife0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( !isNull _pistol ) then
	{
		_this moveToHands _pistol;

		_anims resize 0;
		_anims = _anims + ["menu_idlePistol0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idlePistol0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( !isNull _melee && isNull _baseballBat ) then
	{
		_this moveToHands _melee;

		_anims resize 0;
		_anims = _anims + ["menu_idleHatchet0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleHatchet0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( !isNull _shoulder ) then
	{
		_this moveToHands _shoulder;

		_anims resize 0;
		_anims = _anims + ["menu_idlerifleLong0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idlerifleLong0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	if ( _shoulder isKindOf "MilitaryRifle" ) then
	{
		_this moveToHands _shoulder;

		_anims resize 0;
		_anims = _anims + ["menu_idleRifle0"];
		_animsRaw = getArray (configFile >> "CfgMovesMaleSdr2" >> "States" >> "menu_idleRifle0" >> "variantsPlayer");
		
		for "_i" from 0 to (count _animsRaw) - 1 step 2 do
		{
			_anims set [ count _anims, _animsRaw select _i];
		};
	};

	_anim = _anims select (floor (random (count _anims)));

	_this switchMove _anim;
	//diag_log format ["animace Pole::%1",_anims];

	for "_i" from 0 to 50 do 
	{
		_anim = _anims select (floor (random (count _anims)));
		_this playMove _anim;
		diag_log format ["MainMenu %1 - %2",_i, _anim];
	};
	
/*
	while { ! isNull _this && MainMenuOpen } do 
	{
		_anim = _anims select (floor (random (count _anims)));
		_this playMove _anim;
		//diag_log format ["animace::%1",_anim];
		_i = 0;
		while { _i < 80 && MainMenuOpen } do
		{
			sleep 0.1;
			_i = _i + 1;
		};
	};
*/
	//diag_log "konec intra";
};

ui_fnc_mouseDrag = 
{
	_startX = uiNamespace getVariable 'mousePosX';
	_dirS = getDir demoUnit;
	demoUnit enableSimulation false;
	while {true} do
	{				
		createDir = _dirS + ((_startX - (uiNamespace getVariable 'mousePosX')) * 360);
		demoUnit setDir createDir;
	};
};
ui_fnc_mouseDragCancel = 
{
	terminate rotateObject;
	demoUnit enableSimulation true;
};

ui_fnc_setDefaultChar =
{
	//sync character
	_inventory = itemsInInventory demoUnit;
	_inventoryStr = [];
	{
		_inventoryStr set [count _inventoryStr,typeOf _x];
	} forEach _inventory;
	profileNamespace setVariable ["defaultInventory",_inventoryStr];
	profileNamespace setVariable ["defaultCharacter",(typeOf demoUnit)];
	saveProfileNamespace;
};

fnc_generateRscQuantity = {};

populateInventoryNotifiers =
{
	disableSerialization;
	while {dialog} do
	{
		_display = findDisplay 106;
		_container = 0;
		{
			if (!isNil "_x") then
			{
				if (typeName _x != "ARRAY") exitWith {};
				if (count _x > 0) then
				{
					//init
					_control = _display displayCtrl (1000 + _container);

					//set
					_control ctrlSetText (_x select 0);
					_control ctrlSetBackgroundColor (_x select 1);
					
					//end
					_container = _container + 1;
					//statusChat [str(_x),""];
				};
			};
		} forEach myNotifiers;
		for "_i" from _container to 9 do
		{
			_control = _display displayCtrl (1000 + _i);
			if (!isNull _control) then
			{
				_control ctrlSetText "";
				_control ctrlSetBackgroundColor [0,0,0,0];
			};
		};
		sleep 0.1;
	};
};

//UI defaults
setEVUser 0; //setAperture -1;
DZ_Brightness = 1;
DZ_Contrast = 1;
DZ_dynamicBlur = 0;
DZ_colorSat = 1;

//enable PP
"DynamicBlur" ppEffectEnable true;
"ColorCorrections" ppEffectEnable true;

DZ_BONES = call {
	_cfgClasses = configFile >> "CfgBody";
	_total = ((count _cfgClasses) - 1);
	_bones = [];
	for "_i" from 0 to _total do 
	{
		_bones set [count _bones,configName (_cfgClasses select _i)];
	};
	_bones
};

// player_queued = 		compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\player_queued.sqf";
player_queued = 		compile preprocessFileLineNumbers "modulesDayZ\scripts\player_queued.sqf";

//functions
fnc_generateTooltip = compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\fn_generateTooltip.sqf";
dayz_bulletHit = 		compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\dayz_bulletHit.sqf";
fnc_playerMessage =	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\fn_playerMessage.sqf";
randomValue =		compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\randomValue.sqf";
fnc_isItemDuctTapeCompatible = 	compile preprocessFileLineNumbers "\dz\modulesDayz\scripts\fnc_isItemDuctTapeCompatible.sqf";

//ui
ui_characterScreen =	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\ui_characterScreen.sqf";
ui_defaultCharacterScreen =	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\ui_defaultCharacterScreen.sqf";
ui_newScene =		compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\ui_newScene.sqf";

//melee
melee_startAttack = 	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\melee_startAttack.sqf";
melee_finishAttack = 	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\melee_finishAttack.sqf";
event_playerBleed = 	compile preprocessFileLineNumbers "\dz\modulesDayZ\scripts\event_playerBleed.sqf";

//init
init_fireplace = compile preprocessFileLineNumbers			"\dz\modulesDayZ\scripts\init\fireplace_initialize.sqf";
init_cooking_food = compile preprocessFileLineNumbers		"\dz\modulesDayZ\scripts\init\cooking_food_initialize.sqf";
init_gascooker = compile preprocessFileLineNumbers			"\dz\modulesDayZ\scripts\init\gascooker_initialize.sqf";
init_gascanister = compile preprocessFileLineNumbers		"\dz\modulesDayZ\scripts\init\gascanister_initialize.sqf";
init_cooking_equipment = compile preprocessFileLineNumbers			"\dz\modulesDayZ\scripts\init\cooking_equipment_initialize.sqf";
//action conditions
cooking_action_condition = compile preprocessFileLineNumbers 	"\dz\modulesDayZ\scripts\cooking\cooking_action_condition.sqf";
fireplace_action_condition = compile preprocessFileLineNumbers 	"\dz\modulesDayZ\scripts\cooking\fireplace_action_condition.sqf";
fireplace_state_condition = compile preprocessFileLineNumbers 	"\dz\modulesDayZ\scripts\cooking\fireplace_state_condition.sqf";
barrel_action_condition = compile preprocessFileLineNumbers 	"\dz\modulesDayZ\scripts\cooking\barrel_action_condition.sqf";

//event
event_explosives = compile preprocessFileLineNumbers 	"\dz\modulesDayZ\scripts\event\event_explosives.sqf";
event_ammo = compile preprocessFileLineNumbers 			"\dz\modulesDayZ\scripts\event\event_ammo.sqf";

/*
melee_fnc_checkHitLocal = {
	if (!_processHit) exitWith {};
	_array = lineHit [_this select 0, _this select 1, "fire", _agent,objNull,0];
	if (count _array>0) exitWith 
	{
		_array select 0 requestDamage [_agent, _array select 2, _ammo, _array select 1];
		//statusChat ["hit","colorImportant"];
		_processHit = false;	//possibly select for slashes?
		if (!_unarmed) then
		{
			playerAction ["BaseballAttackHit",{meleeAttack = false}];
		};
	};
};
*/

isUnderRoof = {
	_pos = getPosASL _this;
	_pos0 = [_pos select 0,_pos select 1,(_pos select 2)+ 50];
	_hits = lineHit [_pos,_pos0,"shadow",_this,objNull,0];
	_hits
};

rainCheck =
{
	_body = _this;
	if (rain > 0) then
	{
		_hits = _body call isUnderRoof;
		if (count _hits == 0) then
		{
			if (!gettingWet) then
			{
				gettingWet = true;
				playerWet = [_body,gettingWet];
				publicVariableServer "playerWet";
			};
		}
		else
		{
			if (gettingWet) then
			{
				//hint "not getting wet now!";
				gettingWet = false;	
				playerWet = [_body,gettingWet];
				publicVariableServer "playerWet";	
			};
		};
	}
	else
	{
		if (gettingWet) then
		{
			//hint "not getting wet now!";
			gettingWet = false;	
			playerWet = [_body,gettingWet];
			publicVariableServer "playerWet";		
		};
	};
};

//loose compiles
randomSelect = {
	private["_array","_item","_num"];
	_array = _this;
	_num = floor (random (count (_array)));
	_item = _array select _num;
	_item
};

syncWeather = {
	[_this select 0, date, overcast, fog, rain,_this select 1] spawnForPlayer 
	{
		if (_this select 5) then {setDate (_this select 1)};
		//DZ_WEATHER_CHANGE setFog (_this select 3);
		simulSetHumidity (_this select 2);
		[0,0] setRain (_this select 4);
		//hint "Weather Change from server!";
	};
};

randomValue = {
private["_min","_max","_v"];
	// hint str _this;
	if (count _this == 0) exitWith {-1};
	//[2,format["Random %1",_this],"colorStatusChannel"] call fnc_playerMessage;
	_min = (_this select 0);
	_max = (_this select 1);
	_diff = _max - _min;
	_v = round (_min + (random _diff));
	_v
};

fnc_addTooltipText = {
	//used in tooltips to generate array
	_usedText = text _text;
	_usedText setAttributes _attributes;
	_textArray set [count _textArray,lineBreak];
	_textArray set [count _textArray,_usedText];
};

effect_createBreathFog = {
	_agent = _this;
	if (!(_agent getVariable "fog")) exitwith {};
	_cl = 1;
	_int = 1;
	_source = "#particlesource" createVehicleLocal getPosATL _agent;
	_source setParticleParams
	/*Sprite*/		[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 12, 8],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		0.1*_int,
	/*Position*/		[0,0,0],
	/*MoveVelocity*/	[0, 0, 0],
	/*Simulation*/	0, 0.05, 0.04, 0.05,	//rotationVel,weight,volume,rubbing
	/*Scale*/		[0.02, 0.1,0.2],
	/*Color*/		[[_cl, _cl, _cl, 0.05],[_cl, _cl, _cl, 0.1],[_cl, _cl, _cl, 0.2],[0.05+_cl, 0.05+_cl, 0.05+_cl, 0.1],[0.1+_cl, 0.1+_cl, 0.1+_cl, 0.08],[0.2+_cl, 0.2+_cl, 0.2+_cl, 0.05], [1,1,1, 0]],
	/*AnimSpeed*/		[0.8,0.3,0.25],
	/*randDirPeriod*/	1,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/		[_agent, [[0,0.1,0.62],["Head",1]]]];
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity, {angle}, bounceOnSurface]
	_source setParticleRandom [2, [0, 0, 0], [0.0, 0.0, 0.0], 0, 0.2, [0, 0, 0, 0.1], 0, 0, 10];
	_source setDropInterval (0.02*_int);
	_agent setVariable ["breathingParticleSource",_source];
	
	null = [_source,_agent] spawn {
		_source = _this select 0;
		_agent = _this select 1;
		while {(alive _agent) and !(isNull _source)} do
		{
			sleep 1;
			_source setDropInterval 2;
			sleep 2;
			_source setDropInterval 0.02;
		};
		deleteVehicle _source;
	};
};

//---------------------------------------
effect_PumpWater_particle = 
{
		_cl = 1;
		_source = "#particlesource" createVehicleLocal getPosATL _this;
		_source setParticleParams
		/*Sprite*/		[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 12, 5, 0],"",// File,Ntieth,Index,Count,Loop(Bool)
		/*Type*/			"Billboard",
		/*TimmerPer*/		1,
		/*Lifetime*/		0.62,
		/*Position*/		[0.30,0,0.665],
		/*MoveVelocity*/	[0.12,0,-0.02],
		/*Simulation*/		0.1,0.32,0.2,0.01,//rotationVel,weight,volume,rubbing
		/*Scale*/			[0.02,0.07,0.1],
		/*Color*/			[[0.41,0.41,0.5,0.1],[0.5,0.5,0.6,0.05],[0.92,0.91,0.98,0.01]],
		/*AnimSpeed*/		[1,0.4,0.2],
		/*randDirPeriod*/	0,
		/*randDirIntesity*/	0,
		/*onTimerScript*/	"",
		/*DestroyScript*/	"",
		/*Follow*/		_this];
		//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity, {angle}, bounceOnSurface]
		_source setParticleRandom [0.1, [0, 0, 0], [0.05, 0.08, 0.04], 0, 0.2, [0, 0, 0.2, 0.1], 0, 0, 10];
		_source setDropInterval 0.02;
		[_source, _this] spawn {sleep 4;deleteVehicle (_this select 0);(_this select 1) setVariable["waterSources",((_this select 1) getVariable "waterSources")-1];};
};


event_fnc_gasLight = {
	private["_sfx"];
	_lamp = _this;
	_position = getPosATL _lamp;
	_lightOn = _lamp getVariable ["light",false];
	if (_lightOn) then
	{		
		call effect_gasLight; 
	}
	else
	{
		//stop light
		//deleteVehicle (_lamp getVariable ["lightObject",objNull]);
		//stop monitor 
		terminate (_lamp getVariable ["lightMonitor",null]); 
	};
};

effect_gasLight =
{
	_lamp = _this;
	
	//start light
	/*
	_light = "#lightpoint" createVehicleLocal _position;
	_light setLightColor [0.5,0.5,0.4];
	_light setLightAmbient [0.2,0.2,0.18];
	_light setLightBrightness 0.2;
	_light lightAttachObject [_lamp, [0,0,0]];
	_lamp setVariable ["lightObject",_light];
	
	//monitor
	_spawn = [_lamp,_light] spawn {
		_lamp = _this select 0;
		_light = _this select 1;
		while {alive _lamp} do
		{
			while {alive _lamp} do {
				if (!isNull (itemParent _lamp)) exitWith {};
				sleep 0.5;
			};
			_parent = itemParent _lamp;
			if (!isNull itemParent _parent) then {
				_parent = itemParent _parent;
			};			
			_light lightAttachObject [_parent, [0,0,0]];
			while {alive _lamp} do {
				if (isNull (itemParent _lamp)) exitWith {};
				sleep 0.5;
			};
			_light lightAttachObject [_lamp, [0,0,0]];
		};
		deleteVehicle _light;
	};
	_lamp setVariable ["lightMonitor",_spawn];
	*/
};

effect_playerVomit =
{
	private["_agent","_source"];
	_agent = _this;
	//vomit contents	
	_cl = 1;
	_int = 1;
	_source = "#particlesource" createVehicleLocal getPosATL _agent;
	_source setParticleParams
	/*Sprite*/		[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 12, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		0.8,
	/*Position*/		[0,0,0],
	/*MoveVelocity*/	[0,0,0],
	/*Simulation*/		0, 3, 1, 0,//rotationVel,weight,volume,rubbing
	/*Scale*/			[0.06,0.5],
	/*Color*/			[[0.5,0.5,0.5,1]],
	/*AnimSpeed*/		[1],
	/*randDirPeriod*/	0.1,
	/*randDirIntesity*/	0.1,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			[_agent, [[0,0.1,0.62],["Head",1]]]];
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity, {angle}, bounceOnSurface]
	_source setParticleRandom [0, [0, 0, 0], [0.06, 0.06, 0.06], 2, 0, [0, 0, 0, 0], 0, 0];
	
	//process effects
	sleep 1.4;	
	_start = diag_tickTime;
	while {(diag_tickTime - _start) < 2.1} do
	{
		_source setDropInterval (random 0.025);
		sleep 0.1;
	};
	deleteVehicle _source;
};

event_fnc_foodStage =
{
	private["_food","_config_name","_config_food","_food_stage","_food_selections","_food_textures","_food_materials","_food_texture_index","_food_material_index","_food_selection_index"];
	
	_food = _this;
	
	//CONFIG & PARAMS
	_config_name = "CfgVehicles";
	_config_food = configFile >> _config_name >> typeOf _food;

	_food_stage = _food getVariable ["food_stage",['Raw',0,0,0]];
	
	//VISUAL
	//food_stage = ['stage_name', selection_index, texture_index, material_index]
	_food_selection_index = _food_stage select 1;
	_food_texture_index = _food_stage select 2;
	_food_material_index = _food_stage select 3;
	
	_food_selections = getArray (_config_food >> "hiddenSelections");
	_food_textures = getArray (_config_food >> "hiddenSelectionsTextures");
	_food_materials = getArray (_config_food >> "hiddenSelectionsMaterials");
	
	//change selection
	//hide all
	_food_state_anim = _food_selections select _food_selection_index;
	for [{_i = 0}, {_i < (count _food_selections)}, {_i = _i + 1}] do
	{
		_anim = _food_selections select _i;
		
		if (_anim != _food_state_anim) then
		{
			_food animate[_anim, 1];
		};
	};
	//show selection
	_food animate[_food_state_anim, 0];
	//change texture
	_food setObjectTexture [_food_selection_index, _food_textures select _food_texture_index]; //0 - cs_all selection
	//change material
	_food setObjectMaterial [_food_selection_index, _food_materials select _food_material_index]; //0 - cs_all selection
};

event_fnc_gascookerFire = 
{
	private["_gascooker","_is_fire","_config_flame"];
	_gascooker = _this;
	
	_is_fire = _gascooker getVariable ["fire", false];	
	
	if (_is_fire) then
	{
		//change visual
		_config_flame = configFile >> "cfgVehicles" >> typeOf _gascooker >> "flame";
		_gascooker setObjectTexture [0, getText(_config_flame >> "texture")];	
	}
	else
	{
		//change visual
		_gascooker setObjectTexture [0, ""];
	};
};

//COOKING EQUIPMENT STATE
event_fnc_cookingEquipmentState = 
{
	_cooker = _this;
	
	_temperature = _cooker getVariable ['temperature', 0];
	_particle = _cooker getVariable ['cookingParticleSource', objNull];
	_item_parent = (itemParent _cooker);
	
	//diag_log format["| isNull particle = %1 |", isNull _particle];
	
	if ((_temperature >= 100) and 
		 (quantity _cooker > 0) and
		 ((_item_parent isKindOf 'FireplaceBase') or 
		  (_item_parent isKindOf 'CookerBase')) ) then
	{
		
		//if ( isNil "_particle") then
		if ( isNull _particle) then
		{
			//diag_log format["| start steam (_item_parent = '%1') |", _item_parent];
			call effect_createSteam;
		};
	}
	else
	{
		//if !( isNil "_particle") then
		if !( isNull _particle) then
		{	
			//diag_log format["| delete steam (_item_parent = '%1') |", _item_parent];
			deleteVehicle _particle;
		};
	};
};

effect_createSteam =
{
	_particle_position = [0.08, 0.1, 0.08]; //default
		
	_source = "#particlesource" createVehicleLocal getPosATL _cooker;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 12, 8, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		0.3,
	/*Lifetime*/		1.5,
	/*Position*/		//[0, 0, 0.4],
	/*Position*/		_particle_position,
	/*MoveVelocity*/	[0, 0, 0.2],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.1, 0.1, 0.1],
	/*Color*/			[[1, 1, 1, 0.05],[1, 1, 1, 0.2],[1, 1, 1, 0.4],[1.05, 1.05, 1.05, 0.3],[1.1, 1.1, 1.1, 0.2],[1.2, 1.2, 1.2, 0.05], [1,1,1, 0]],
	/*AnimSpeed*/		[1,0.4,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_cooker];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1.5, [0, 0, 0], [0.1, 0.1, 0.1], 20, 0.2, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.1);
	
	_cooker setVariable ["cookingParticleSource",_source];
};

//***********************************************************************************************************************************************
// FIREPLACE STATE & PARTICLES
//***********************************************************************************************************************************************
//'fire' is changed
event_fnc_fireplaceFire = 
{
	private["_fireplace","_mid_fireplace_temp","_fire_temp"];
	_fireplace = _this;
	_mid_fireplace_temp = 250;
	
	_fire_temp = _fireplace getVariable ["temperature", 0];	
	_is_fire = _fireplace getVariable ["fire", false];	
	_fire_intensity = _fireplace getVariable ['fire_intensity', 0];
	
	if (_is_fire) then
	{
		if (_fire_intensity == 0) then
		{
			_fireplace call fnc_kindlingFire_start;
		}
		else
		{
			_fireplace call fnc_fuelFire_start;
		};	
	}
	else
	{
		if (_fire_intensity == 0) then
		{
			_fireplace call fnc_kindlingFire_stop;
		}
		else
		{
			_fireplace call fnc_fuelFire_stop;
		};
	};
};

//'temperature' is changed
event_fnc_fireplaceIntensity =
{
	private["_fireplace","_mid_fireplace_temp","_fire_temp"];
	_fireplace = _this;
	_mid_fireplace_temp = 250;
	
	_fire_temp = _fireplace getVariable ["temperature",0];	
	_is_fire = _fireplace getVariable ["fire", false];
	_fire_intensity = _fireplace getVariable ['fire_intensity', 0];
	
	//if not fire, exit
	if !(_is_fire) exitWith {};
	
	//debuglog
	//[player, format["Fire intensity = %1, temperature = %2", _fire_intensity, _fire_temp], "colorStatusChannel"] call fnc_playerMessage;
	
	//small fire
	if (_fire_temp <= _mid_fireplace_temp and 
		_fire_intensity == 1) exitWith
	{
		_fireplace setVariable ['fire_intensity', 0];
		
		_fireplace call fnc_kindlingFire_start;
		_fireplace call fnc_fuelFire_stop;
	};
	
	//big fire
	if (_fire_temp > _mid_fireplace_temp and 
		_fire_intensity == 0) exitWith
	{
		_fireplace setVariable ['fire_intensity', 1];
		
		_fireplace call fnc_fuelFire_start;
		_fireplace call fnc_kindlingFire_stop;
	};
};

//FIREPLACE WITH FUEL
fnc_fuelFire_start =
{
	_fireplace = _this;
	
	call effect_createFireplaceFlames; 		
	call effect_createFireplaceSmoke;
	call effect_createFireplaceSparks;
	
	//debuglog
	//[player, format["Starting fuel fire..."], "colorStatusChannel"] call fnc_playerMessage;
};

fnc_fuelFire_stop =
{
	_fireplace = _this;
	
	_fireplaceFlames = _fireplace getVariable ["fireplaceFlamesParticleSource",objNull];		
	_fireplaceSmoke = _fireplace getVariable ["fireplaceSmokeParticleSource",objNull];		
	_fireplaceSparks = _fireplace getVariable ["fireplaceSparksParticleSource",objNull];
	deleteVehicle _fireplaceFlames;
	deleteVehicle _fireplaceSmoke;
	deleteVehicle _fireplaceSparks;
	
	//debuglog
	//[player, format["Stopping fuel fire..."], "colorStatusChannel"] call fnc_playerMessage;
};

//FIREPLACE WITH KINDLING ONLY
fnc_kindlingFire_start =
{
	_kindling = _this;
	_kindling setVariable ['fire_intensity', 0];
		
	call effect_createKindlingFlames; 		
	call effect_createKindlingSmoke;
	call effect_createKindlingSparks;
	
	//debuglog
	//[player, format["Starting kindling fire..."], "colorStatusChannel"] call fnc_playerMessage;
};

fnc_kindlingFire_stop =
{
	_kindling = _this;
	
	_kindlingFlames = _kindling getVariable ["kindlingFlamesParticleSource",objNull];		
	_kindlingSmoke = _kindling getVariable ["kindlingSmokeParticleSource",objNull];		
	_kindlingSparks = _kindling getVariable ["kindlingSparksParticleSource",objNull];
	deleteVehicle _kindlingFlames;
	deleteVehicle _kindlingSmoke;
	deleteVehicle _kindlingSparks;
	
	//debuglog
	//[player, format["Stopping kindling fire..."], "colorStatusChannel"] call fnc_playerMessage;
};

effect_createFireplaceFlames =
{
	_source = "#particlesource" createVehicleLocal getPosATL _fireplace;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 10, 32, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		0.5,
	/*Position*/		[0, 0, 0.3],
	/*MoveVelocity*/	[0, 0, 0.5],
	/*Simulation*/		0.2, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.6, 0.4, 0.2],
	/*Color*/			[[0.8,1,0.3,0],[0.8,1,0.3,-1],[0.8,1,0.3,-3],[0.8,1,0.3,-3],[0.8,1,0.3,-1],[0.8,1,0.3,0]],
	/*AnimSpeed*/		[0.8,0.3,0.25], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.1,
	/*randDirIntesity*/	0.05,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_fireplace];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0.2, [0, 0, 0], [0.1, 0.1, 0.4], 0.1, 0.1, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.03);
	
	_fireplace setVariable ["fireplaceFlamesParticleSource",_source];
};

effect_createFireplaceSmoke =
{
	_particle_position = [0, 0, 0.4]; //default
	
	//set alternate particle position
	_smoke_particle_point = _fireplace getVariable ['smoke_particle_point', nil];
	_follow_object = _fireplace;
	if !(isNil "_smoke_particle_point") then
	{
		_follow_object = [_fireplace, "HouseWithFireplace", [], 10] call fnc_getNearestObject;
		_particle_position = _smoke_particle_point; //set particle point as position
	};
	
	_source = "#particlesource" createVehicleLocal getPosATL _fireplace;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		3,
	/*Position*/		//[0, 0, 0.4],
	/*Position*/		_particle_position,
	/*MoveVelocity*/	[0, 0, 0.2],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.5, 0.7, 1.2],
	/*Color*/			[[0.6,0.6,0.6,0],[0.7,0.7,0.7,0.2],[0.8,0.8,0.8,0.1],[1,1,1,0]],
	/*AnimSpeed*/		[1,0.4,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_follow_object];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1.5, [0, 0, 0], [0.15, 0.15, 0.3], 30, 0.2, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.1);
	
	_fireplace setVariable ["fireplaceSmokeParticleSource",_source];
};

effect_createFireplaceSparks = 
{
	_source = "#particlesource" createVehicleLocal getPosATL _fireplace;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 13, 2, 0],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		0.5,
	/*Position*/		[0, 0, 0.3],
	/*MoveVelocity*/	[0, 0, 0.6],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.02, 0.02, 0.01],
	/*Color*/			[[0.6,0.5,0.3,-10],[0.8,0.7,0.4,-10],[1,0.9,0.5,-10],[0.8,0.7,0.4,-10]], //[[1,1,1,-10]]
	/*AnimSpeed*/		[1000], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.05,
	/*randDirIntesity*/	0.1,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_fireplace];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1, [0.2, 0.2, 0.1], [0.4, 0.4, 0.25], 100, 0, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.02);
	
	_fireplace setVariable ["fireplaceSparksParticleSource",_source];
};

effect_createKindlingFlames =
{
	_source = "#particlesource" createVehicleLocal getPosATL _kindling;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 10, 32, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		0.5,
	/*Position*/		[0, 0, 0.3],
	/*MoveVelocity*/	[0, 0, 0.2],
	/*Simulation*/		0.2, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.3, 0.2, 0.1],
	/*Color*/			[[0.8,1,0.3,0],[0.8,1,0.3,-1],[0.8,1,0.3,-3],[0.8,1,0.3,-3],[0.8,1,0.3,-1],[0.8,1,0.3,0]],
	/*AnimSpeed*/		[0.8,0.3,0.25], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.1,
	/*randDirIntesity*/	0.05,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_kindling];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0.2, [0, 0, 0], [0.1, 0.1, 0.4], 0.1, 0.1, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.03);
	
	_kindling setVariable ["kindlingFlamesParticleSource",_source];
};

effect_createKindlingSmoke =
{
	_particle_position = [0, 0, 0.4]; //default
	
	//set alternate particle position
	_smoke_particle_point = _kindling getVariable ['smoke_particle_point', nil];
	_follow_object = _kindling;
	if !(isNil "_smoke_particle_point") then
	{
		_follow_object = [_kindling, "HouseWithFireplace", [], 10] call fnc_getNearestObject;
		_particle_position = _smoke_particle_point; //set particle point as position
	};
	
	_source = "#particlesource" createVehicleLocal getPosATL _kindling;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		3,
	/*Position*/		_particle_position,	
	/*MoveVelocity*/	[0, 0, 0.15],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.25, 0.35, 0.6],
	/*Color*/			[[0.6,0.6,0.6,0],[0.7,0.7,0.7,0.2],[0.8,0.8,0.8,0.1],[1,1,1,0]],
	/*AnimSpeed*/		[1,0.4,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_follow_object];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1.5, [0, 0, 0], [0.15, 0.15, 0.3], 30, 0.2, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.1);
	
	_kindling setVariable ["kindlingSmokeParticleSource",_source];
};

effect_createKindlingSparks = 
{
	_source = "#particlesource" createVehicleLocal getPosATL _kindling;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 13, 2, 0],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		0.3,
	/*Position*/		[0, 0, 0.3],
	/*MoveVelocity*/	[0, 0, 0.4],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.02, 0.02, 0.01],
	/*Color*/			[[0.6,0.5,0.3,-10],[0.8,0.7,0.4,-10],[1,0.9,0.5,-10],[0.8,0.7,0.4,-10]], //[[1,1,1,-10]]
	/*AnimSpeed*/		[1000], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.05,
	/*randDirIntesity*/	0.1,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_kindling];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1, [0.2, 0.2, 0.1], [0.4, 0.4, 0.25], 100, 0, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.3);
	
	_kindling setVariable ["kindlingSparksParticleSource",_source];
};

//FIREPLACE STATE
event_fnc_fireplaceState = 
{
	_fireplace = _this select 0; 	//fireplace
	_is_fireplace = _fireplace getVariable ["is_fireplace", false];
	
	//_items = itemsInInventory _fireplace;
	__attached_items = _fireplace call fnc_getAttachments;
		
	
	//get kindling count
	_get_kindling_count = 
	{
		private["_fireplace","_items_count"];
		_fireplace = _this select 0;
		
		_items_count = 0;
		{
			_item_obj = _x;
			
			if ( !(isNull _item_obj) and 
				_item_obj isKindOf "Consumable_Rags" or 
				_item_obj isKindOf "Medical_BandageDressing" or 
				_item_obj isKindOf "Medical_Bandage" or 
				_item_obj isKindOf "Consumable_Bark_Oak" or 
				_item_obj isKindOf "Consumable_Bark_Birch" or 
				_item_obj isKindOf "Consumable_Paper" ) then
			{
				_items_count = _items_count + 1;
			};
		} foreach __attached_items;		
			
		_items_count
	};
	
	//hide all
	_fireplace animate ['Sticks', 1];
	_fireplace animate ['Wood', 1];
	_fireplace animate ['BurntWood', 1];
	
	//
	//fuel items
	//
	{
		_fuel_item = _x;
		//_item_obj = _fuel_item select 0;
		_item_obj = _fuel_item;
		
		//wooden stick
		if (!(isNull _item_obj) and 
			_item_obj isKindOf "Crafting_WoodenStick") then
		{
			_fireplace animate ['Sticks', 0];
		};
		
		//firewood
		if (!(isNull _item_obj) and 
			_item_obj isKindOf "Consumable_Firewood") then
		{
			if (_fireplace getVariable ['fire', false]) then
			{
				_fireplace animate ['BurntWood', 0];
			}
			else
			{
				_fireplace animate ['Wood', 0];
			};
		};
	} foreach __attached_items;
	
	//
	//kindling
	//
	_kinidling_items_count = [_fireplace] call _get_kindling_count;
	if (_is_fireplace) then 
	{
		_fireplace animate ['Kindling', 1]; //is fireplace
		_fireplace animate ['Ashes', 0];
	}
	else
	{
		_fireplace animate ['Ashes', 1];
		
		if (_kinidling_items_count == 0) then //if there is at least one kindling item
		{
			_fireplace animate ['Kindling', 1];
		}
		else
		{
			_fireplace animate ['Kindling', 0];
		};
	};
};	

//***********************************************************************************************************************************************

//TORCH PARTICLE EFFECTS
event_fnc_torchFire =
{
	private["_sfx"];
	//hint "event_fnc_torchFire";
	_torch = _this;
	_position = getPosATL _torch;
	_fireOn = _torch getVariable ["fire",false];
	if (_fireOn == 1) then
	{		
		//hint "turn pfx on";
		call effect_createTorchFlames; 		
		call effect_createTorchSmoke;
		call effect_createTorchSparks;
	}
	else
	{
		//hint "turn pfx off";		
		_torchFlames = _torch getVariable ["torchFlamesParticleSource",objNull];		
		_torchSmoke = _torch getVariable ["torchSmokeParticleSource",objNull];		
		_torchSparks = _torch getVariable ["torchSparksParticleSource",objNull];
		deleteVehicle _torchFlames;
		deleteVehicle _torchSmoke;
		deleteVehicle _torchSparks;
	};
};

effect_createTorchFlames =
{
	_source = "#particlesource" createVehicleLocal getPosATL _torch;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 10, 32, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		0.17,
	/*Position*/		"emitter",
	/*MoveVelocity*/	[0, 0, 0.2],
	/*Simulation*/		0.2, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.13, 0.09, 0.047],
	/*Color*/			[[0.8,1,0.3,0],[0.8,1,0.3,-1],[0.8,1,0.3,-3],[0.8,1,0.3,-3],[0.8,1,0.3,-1],[0.8,1,0.3,0]],
	/*AnimSpeed*/		[0.7,0.3,0.25], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.3,
	/*randDirIntesity*/	0.02,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_torch];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0.2, [0, 0, 0], [0.1, 0.1, 0.4], 0.1, 0.1, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.005);
	
	_torch setVariable ["torchFlamesParticleSource",_source];
};

effect_createTorchSmoke =
{
	/*
	_particle_position = [0, 0, 0.4]; //default
	
	//set alternate particle position
	_smoke_particle_point = _kindling getVariable ['smoke_particle_point', nil];
	_follow_object = _kindling;
	if !(isNil "_smoke_particle_point") then
	{
		_follow_object = [_kindling, "HouseWithFireplace", [], 10] call fnc_getNearestObject;
		_particle_position = _smoke_particle_point; //set particle point as position
	};
	*/
	_source = "#particlesource" createVehicleLocal getPosATL _torch;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		3,
	/*Position*/		"emitter",	//_particle_position
	/*MoveVelocity*/	[0, 0, 0.15],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.25, 0.35, 0.6],
	/*Color*/			[[0.6,0.6,0.6,0],[0.7,0.7,0.7,0.2],[0.8,0.8,0.8,0.1],[1,1,1,0]],
	/*AnimSpeed*/		[1,0.4,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_torch];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1.5, [0, 0, 0], [0.15, 0.15, 0.3], 30, 0.2, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.1);
	
	_torch setVariable ["torchSmokeParticleSource",_source];
};

effect_createTorchSparks = 
{
	_source = "#particlesource" createVehicleLocal getPosATL _torch;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 13, 2, 0],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		0.3,
	/*Position*/		"emitter",
	/*MoveVelocity*/	[0, 0, 0.4],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.02, 0.02, 0.01],
	/*Color*/			[[0.6,0.5,0.3,-10],[0.8,0.7,0.4,-10],[1,0.9,0.5,-10],[0.8,0.7,0.4,-10]], //[[1,1,1,-10]]
	/*AnimSpeed*/		[1000], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.05,
	/*randDirIntesity*/	0.1,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_torch];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1, [0.2, 0.2, 0.1], [0.4, 0.4, 0.25], 100, 0, [0, 0, 0, 0], 0, 0];
	
	_source setDropInterval (0.3);
	
	_torch setVariable ["torchSparksParticleSource",_source];
};

//ROAD FLARE PARTICLE EFFECTS
event_fnc_flareFire =
{
	private["_sfx"];
	//hint "event_fnc_flareFire";
	_flare = _this;
	_position = getPosATL _flare;
	_fireOn = _flare getVariable ["fire",false];
	if (_fireOn == 1) then
	{		
		//hint "turn pfx on";
		//call effect_createFlareFlames; 		
		call effect_createFlareSmoke;
		call effect_createFlareSparks;
	}
	else
	{
		//hint "turn pfx off";
		//_flareFlames = _flare getVariable ["fireplaceFlamesParticleSource",objNull];		
		_flareSmoke = _flare getVariable ["flareSmokeParticleSource",objNull];		
		_flareSparks = _flare getVariable ["flareSparksParticleSource",objNull];
		//deleteVehicle _flareFlames;
		deleteVehicle _flareSmoke;
		deleteVehicle _flareSparks;
	};
};

effect_createFlareSmoke = 
{	
	_source = "#particlesource" createVehicleLocal getPosATL _flare;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		2,
	/*Position*/		"emitter",
	/*MoveVelocity*/	[0, 0.6, 0],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.2, 0.8, 2.6],
	/*Color*/			[[0.6,0.6,0.6,0],[0.7,0.7,0.7,0.2],[0.8,0.8,0.8,0.1],[1,1,1,0]], //[[1,1,1,-10]]
	/*AnimSpeed*/		[1.5,0.5], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.4,
	/*randDirIntesity*/	0.09,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_flare];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0.3, [0.1,0.2,0.1], [0.05,0.5,0.05], 0, 0.3, [0,0,0,0.1], 0.2, 0.05];
	
	_source setDropInterval (0.1);
	
	_flare setVariable ["flareSmokeParticleSource",_source];
};
	
effect_createFlareSparks = 
{
	_source = "#particlesource" createVehicleLocal getPosATL _flare;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 13, 2, 0],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		0.1,
	/*Position*/		"emitter",
	/*MoveVelocity*/	[0, 0, 0.6],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[0.02, 0.02, 0.01],
	/*Color*/			[[0.6,0.5,0.3,-10],[0.8,0.7,0.4,-10],[1,0.9,0.5,-10],[0.8,0.7,0.4,-10]], //[[1,1,1,-10]]
	/*AnimSpeed*/		[1000],
	/*randDirPeriod*/	0, //0.001
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_flare,
	/*Angle*/				0,
	/*RotateOnSurface - Heli Dust*/	false,
	/*InModelSpace*/		true];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0.2, [0.01,0.01,0.1], [0.08,0.08,0.3], 0, 0.06, [0.1,0.1,0.1,0], 0, 0];
	
	_source setDropInterval (0.01);
	
	_flare setVariable ["flareSparksParticleSource",_source];
};

//WRECK EVENT PARTICLE EFFECTS
event_fnc_wreckSmoke =
{
	private["_sfx"];
	_wreck = _this;
	_position = getPosATL _wreck;
	_fireOn = _wreck getVariable ["fire",false];
	if (_fireOn) then
	{					
		call effect_createWreckSmoke;
	}
	else
	{		
		_wreckSmoke = _wreck getVariable ["wreckSmokeParticleSource",objNull];			
		deleteVehicle _wreckSmoke;
	};
};

effect_createWreckSmoke = 
{	
	_source = "#particlesource" createVehicleLocal getPosATL _this;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		22,
	/*Position*/		[0, 0, 0], //"emitter"
	/*MoveVelocity*/	[0, 0, 0.2],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[1, 4, 9, 18],
	/*Color*/			[[0.1,0.1,0.1,0.6],[0.4,0.4,0.4,0.3],[0.7,0.7,0.7,0.1],[0.8,0.8,0.8,0]],
	/*AnimSpeed*/		[1,0.4,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_this];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [1.5, [0, 0, 0], [0.15, 0.15, 0.3], 30, 0.2, [0, 0, 0, 0], 0, 0];
	_source setDropInterval (0.15);
	
	//_this setVariable ["wreckSmokeParticleSource",_source];
	
	//_source particleAttachObject [_this, [0,0,0]];
};

//GRENADE PARTICLE EFFECTS
effect_createGrenadeSmoke = 
{	
	_source = "#particlesource" createVehicleLocal getPosATL _this;
	
	_source setParticleParams
	/*Sprite*/			[["\dz\data\data\ParticleEffects\Universal\Universal", 16, 7, 48, 1],"",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		3,
	/*Lifetime*/		16,
	/*Position*/		[0, 0, 0], //"emitter"
	/*MoveVelocity*/	[0, 0, 0],
	/*Simulation*/		5, 0.05, 0.04, 0.05, //rotationVel,weight,volume,rubbing //0, 0.05, 0.04, 0.05,
	/*Scale*/			[1,4,10,14,20],
	/*Color*/			[[0.9,0.9,0.9,0.1],[0.9,0.9,0.9,1],[0.9,0.9,0.9,1],[0.9,0.9,0.9,1],[0.8,0.8,0.8,0.1]],
	/*AnimSpeed*/		[0.9,0.8,0.1], //[0.8,0.3,0.25],
	/*randDirPeriod*/	0.5,
	/*randDirIntesity*/	0.1,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_this];
	
	//[lifeTime, position, moveVelocity, rotationVelocity, size, color, randomDirectionPeriod, randomDirectionIntensity]
	_source setParticleRandom [0, [0, 0, 0], [0, 0, 0], 1, 0.5, [0, 0, 0, 0], 0, 0];
	_source setDropInterval (0.2);
	
	//_this setVariable ["wreckSmokeParticleSource",_source];
	
	//_source particleAttachObject [_this, [0,0,0]];
};

// Returns true or false if user can cut out seeds from the given fruit
// (typeOf _fruit) call fnc_canCutOutSeeds;
fnc_canCutOutSeeds = {
	_food = _this;
	_fruitHasSeeds = false;
	_config = configfile >> "CfgVehicles" >> typeOf _food;
	_seedsQuantity = getNumber (_config >> "containsSeedsQuantity");
	if (_seedsQuantity > 0) then
	{
		_fruitHasSeeds = true;
	};
	
	// Return result
	_fruitHasSeeds;
};

// Returns true or false if user can pick out seeds from the given fruit
// (typeOf _fruit) call fnc_canPickoutSeeds;
fnc_canPickoutSeeds = {
	_fruit = _this;
	
	_fruit_stage = _fruit getVariable ["food_stage",["Raw",0,0,0]];
	_fruitIsDry = ((_fruit_stage select 0) == "Dried");
	
	_fruitHasSeeds = false;
	_config = configfile >> "CfgVehicles" >> typeOf _fruit;
	_seedsQuantity = getNumber (_config >> "containsSeedsQuantity");
	if (_seedsQuantity > 0) then
	{
		_fruitHasSeeds = true;
	};
	
	_fruitIsDry && _fruitHasSeeds;
};

//get all attached items (temporary)
fnc_getAttachments = 
{
	private["_parent_object","_inv_items","_attached_items","_item_obj"];
	_parent_object = _this;
	_inv_items = itemsInInventory _parent_object;
	_cargo_items = itemsInCargo _parent_object;
	
	_attached_items = [];
	_item_obj = [];
	{
		_item_obj set [0, _x];
		
		if (!(_x in _cargo_items)) then
		{	
			_attached_items = _attached_items + _item_obj;
		};
	} foreach _inv_items;		
		
	_attached_items
};

//returns attachment of given type
fnc_getAttachment = 
{
	_object = _this select 0;
	_item_type = _this select 1;
	
	//_objects = itemsInInventory _object;
	_objects = _object call fnc_getAttachments;
	_target_item = objNull;
	
	for [{_i = 0}, {_i < (count _objects)}, {_i = _i + 1}] do
	{
		_obj = _objects select _i;
		
		if (_obj isKindOf _item_type) exitWith
		{
			_target_item = _obj;
		};
	};
	
	_target_item
};

//returns (first) cargo item of given type
fnc_getCargoItem = 
{
	_object = _this select 0;
	_item_type = _this select 1;
	
	//_objects = itemsInInventory _object;
	_objects = itemsInCargo _object;
	_target_item = objNull;
	
	for [{_i = 0}, {_i < (count _objects)}, {_i = _i + 1}] do
	{
		_obj = _objects select _i;
		
		if (_obj isKindOf _item_type) exitWith
		{
			_target_item = _obj;
		};
	};
	
	_target_item
};

//checks if item type is attached to object (Optional: with min specified quantity)
fnc_isItemAttached = 
{
	_object =	_this select 0;
	_item_type = _this select 1;
	_item_quantity = _this select 2; //optional
	
	//_objects = itemsInInventory _object;
	_objects = _object call fnc_getAttachments;
	_is_attached = false;
	
	for [{_i = 0}, {_i < (count _objects)}, {_i = _i + 1}] do
	{
		_obj = _objects select _i;
		
		if (_obj isKindOf _item_type) exitWith
		{
			if !(isNil "_item_quantity") then
			{
				if (quantity _obj >= _item_quantity) then
				{
					_is_attached = true;
				}
				else
				{
					_is_attached = false;
				};
			}
			else
			{
				_is_attached = true;	
			};
		};
	};
	
	_is_attached
};

//checks if item type is in cargo of target object
fnc_isItemInCargo = 
{
	_object =	_this select 0;
	_item_type = _this select 1;
	
	_objects = itemsInCargo _object;
	_is_in_cargo = false;
	
	for [{_i = 0}, {_i < (count _objects)}, {_i = _i + 1}] do
	{
		_obj = _objects select _i;
		
		if (_obj isKindOf _item_type) exitWith
		{
			_is_in_cargo = true;	
		};
	};
	
	_is_in_cargo
};

//returns the first nearest object of given type
fnc_getNearestObject = 
{
	private["_nearest_obj"];
	_object_source = _this select 0;
	_object_type = _this select 1;
	_exclude_object_types = _this select 2;
	_radius = _this select 3;
	
	_objects = nearestObjects [_object_source, [_object_type], _radius];
	
	for [{_i = 0}, {_i < (count _objects)}, {_i = _i + 1}] do
	{
		_obj = _objects select _i;
		if ((count _exclude_object_types) == 0 or
			!((typeOf _obj) in _exclude_object_types)) exitWith
		{
			_nearest_obj = _obj;
		};
	};
	
	//debuglog
	//hint format["_objects = %1, typeOf _nearest_obj = %2", _objects, typeOf _nearest_obj];
	
	_nearest_obj
};
