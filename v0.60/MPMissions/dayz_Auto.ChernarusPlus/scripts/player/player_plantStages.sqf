// This script handles the whole lifetime of each plant in horticulture.

// Basic definitions
_objSoil = _this select 0;
_plantSeed = _this select 1;
_plantOffset = _this select 2;
_plantSlot = _this select 3;
_isFertilized = _this select 5;
_energy = _this select 4;
_position = getposASL _objSoil;
_aboveSeaHeight = _position select 2;
_objPlant = objNull;
_currentStage = -1;
_skipSpoilTimer = false;

// variable definitions. Every time-period value is in seconds.
_growthStagesCount = 6; // number of growth selections named as plantStage_## in the plant p3d file
_plantType = ""; // p3d class name
_fullMaturityTime = 0; // How much time it takes for the plant to fully grow
_spoilTimer = 0; // How much time does it take for the plant to change from mature state to the spoiled state
_spoiledRemoveTimer = 0; // After how much time in spoiled state the plant disappears
_cropsCount = 0; // Amount of crops
_infestationChance = 0.2; // Chance of catching some infestation after planting the plant

_lifeTimeCoef = 1; // For debugging. Lower this value to shorten plant's lifespan. Default value is 1.

/*-----------------------------------
------------PLANT CONFIGS------------
-----------------------------------*/

if (_energy < 0.01) then { // Division by 0 prevention.
	_energy = 0.01;
};

// Global settings. These can be rewritten for each plant's settings.
_fullMaturityTime = (60*13 + random 60*4) / _energy;
_spoilTimer = (60*30 + random 60*30) * _energy;
_spoiledRemoveTimer = 60*20 + random 60*5;

// Plants configurations
switch (_plantSeed) do
{
	case ("Cultivation_TomatoSeeds"):
	{
		_plantType = "plant_tomato"; 
		_growthStagesCount = 6; 
		_cropsCount = 7 * _energy;
	};
	case ("Cultivation_PepperSeeds"):
	{
		_plantType = "Plant_Pepper"; 
		_growthStagesCount = 6; 
		_cropsCount = 3 * _energy;
	};
	case ("Cultivation_PumpkinSeeds"):
	{
		_plantType = "Plant_Pumpkin"; 
		_growthStagesCount = 7; 
		_cropsCount = 2;
	};
	case ("Cultivation_ZucchiniSeeds"):
	{
		_plantType = "Plant_Zucchini"; 
		_growthStagesCount = 7; 
		_cropsCount = 2 * _energy;
	};
	case ("Fruit_Potato"):
	{
		_plantType = "Plant_Potato"; 
		_growthStagesCount = 6; 
		_cropsCount = 3 * _energy;
	};
	case ("Cultivation_CannabisSeeds"):
	{
		_plantType = "plant_cannabis"; 
		_growthStagesCount = 6; 
		_cropsCount = 7 * _energy;
	};
};

_fullMaturityTime = _fullMaturityTime * _lifeTimeCoef;
_spoilTimer = _spoilTimer * _lifeTimeCoef;
_spoiledRemoveTimer = _spoiledRemoveTimer * _lifeTimeCoef;

/*-----------------------------------
------------PLANT STAGES-------------
-----------------------------------*/


/* -----INITIALIZATION----- */


// Create the plant itself.
_objPlant = _plantType createVehicle _position;
_useTerrainHeight = (typeOf _objSoil == "GardenPlot");
_slotPos = [_objSoil, _plantSlot, _useTerrainHeight] call fnc_getSlotPosition;
_objPlant setDir random 360;
//_objPlant setpos _slotPos;
_slotPos = [_slotPos select 0, _slotPos select 1, 0.2];
_objPlant setPosATL _slotPos;

// Save pointer to this plant object to greenhouse
_objSoil setVariable [format ["slotObj%1", _plantSlot], _objPlant];

// Assign all variables to the plant object
_objPlant setVariable ["soil", _objSoil];
_objPlant setVariable ["plantSlot", _plantSlot];
_objPlant setVariable ["cropsCount", _cropsCount];
_objPlant setVariable ["state", PLANT_IS_DRY];
_objPlant setVariable ["currentStage", _currentStage];
_objPlant setVariable ["isInfested", false];
_objPlant setVariable ["infestationChance", _infestationChance];

// update plant values
[_objPlant] call fnc_updatePlant;

if (_isFertilized) then {
	_objPlant animate["pile_02", 0]; // 0 means UNhide this selection!
	_objPlant animate["pile_01", 1]; // 1 means hide this selection!
}else{
	_objPlant animate["pile_01", 0]; // 0 means UNhide this selection!
	//_objPlant animate["pile_01", 1]; // 1 means hide this selection! (preparation for new types of fertilizers)
};


/* -----WATERING STAGE----- */


// Wait for watering
_waitingForWater = 0;
while {_objPlant getVariable "state" == PLANT_IS_DRY  and  !isnull _objPlant and rain == 0 } do
{
	_waitingForWater = _waitingForWater + 1;
	if ( _waitingForWater >= DELETE_DRY_PLANT_TIMER) then
	{	
		[_objSoil, _plantSlot] call fnc_resetSlotState;
		deleteVehicle _objPlant;
	};
	sleep 1;
};
// If the plant was removed, then stop the script
if (isnull _objPlant) exitWith {};

_objPlant setVariable ["state", PLANT_IS_GROWING];\

// By this point the plant is no longer dry


/* -----GROWTH STAGES----- */


// Growing up to the mature state
while {_currentStage < _growthStagesCount-2} do // -2 because the last spoiled stage has to be left out
{
	scopeName "loop";
	_currentStage = _currentStage + 1;
	
	// update plant variables
	_objPlant setVariable ["currentStage", _currentStage];
	[_objPlant] call fnc_updatePlant;
	
	if (_objPlant getVariable "isInfested" and _currentStage == _growthStagesCount-2) then 
	{// -2 because the fresh and spoiled stages has to be skipped
		_skipSpoilTimer = true;
		breakOut "loop";
	}else{
		if (_currentStage == _growthStagesCount-2) then
		{ // -2 because the spoiled stage has to be skipped
			breakOut "loop" 
		}; 
	};
	sleep (_fullMaturityTime / (_growthStagesCount-2) );
	if (isNull _objPlant) exitWith {};
	
	// Infestation handling
	// When the plant starts growing, it is decided if it will be infested and when.
	if (_currentStage == 0) then { // First visible stage
		_infestationScript = objNull;
		if (_objPlant getVariable "infestationChance" > random 1) then {
			_infestationScript = [_objPlant, _fullMaturityTime] spawn 
			{ // This is a separate thread on which infestation is handled. It can be terminated at anytime since player can cure the plant!
				_objPlant = 			_this select 0;
				_fullMaturityTime = 	_this select 1;
				_infestationStart = random (_fullMaturityTime * 0.5);
				
				sleep _infestationStart; // Note: This script can be terminated outside of its scope during this sleep.
				
				if (isNull _objPlant) exitWith {};
				[_objPlant, true] call fnc_enableInfestation;
			};
			_objPlant setVariable ["infestationScript", _infestationScript];
		};
	};
};

_objPlant setVariable ["state", PLANT_IS_MATURE];

/*
	if !(_skipSpoilTimer) then{
		sleep _spoilTimer;
	};
*/

/* -----SPOILED STAGE----- */


/* 
if (!isNull _objPlant) then
{
	_currentStage = _currentStage + 1;
	_objPlant setVariable ["currentStage", _currentStage];
	_objPlant setVariable ["state", PLANT_IS_SPOILED];
	[_objPlant] call fnc_updatePlant;
	sleep _spoiledRemoveTimer;
	if (!isNull _objPlant) then
	{
		[_objSoil, _plantSlot] call fnc_resetSlotState;
		deleteVehicle _objPlant;
	};
};
*/