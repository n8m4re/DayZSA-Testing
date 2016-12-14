ProfileStart "tick_environment.sqf";
private["_agent","_pos","_isWater","_bones","_delta","_anim","_bodyPosition","_isSwim","_playerWet"];
_agent = _this;
_height = surfaceHeightASL (getPosASL _agent);
_sur = surfaceTypeASL (getPosASL _agent);
_bones = [];
_delta = 0;
_isWater = false;
_gettingWet = _agent getVariable ["gettingWet",false];
_agentSpeed = ([0,0,0] distance (velocity _agent)) min 6;
_airTemperature = 0; //could be taken from server in future

if (_height < 1.5) then
{
    if (_sur == "FreshWater" || _sur == "sea") then
	{
		_isWater = true;
	};
};

//SeaWater or Water

//those informations should be provided directly by engine in future (drowning, being in water etc..)
if (_isWater) then
{
	_anim = animationState _agent;
	_bodyPosition = getText(configFile >> "CfgMovesMaleSdr2" >> "states" >> _anim >> "bodyPosition");
	_isSwim = _bodyPosition == "swim";
	_delta = 0.5 * DZ_TICK;	//increase in wetness
	
	//Is the water deep or shallow?
	if (_isSwim) then
	{
		//deep
		if(!(captive _agent))then{
			[_agent,0] call player_drown;
		};
		_delta = 10;
	}
	else
	{
		//shallow
		switch (_bodyPosition) do
		{
			case "prone":
			{
				// drowning
				[_agent,1] call player_drown;
				_delta = 1;
			};
			case "kneel":
			{
				if(_height < -1)then{[_agent,1] call player_drown;}else{[_agent,0] call player_drown;};//drowning should be definitely done in engine
				_delta = 0.5;
			};
			case "stand":
			{
				if(_height < -1.5)then{[_agent,1] call player_drown;}else{[_agent,0] call player_drown;};
				_delta = 0.25;
			};
		};
	};
}
else
{
	//drowning
	if(!(captive _agent))then{
		[_agent,0] call player_drown;
	};
	if (!_gettingWet) then
	{
		//probably drying
		//movement + wind + sunshine
		_delta = -1*(((1+(_agentSpeed/3)) + ((windSpeed min 2) max 1))/2000*((1+worldLightScale) min 2));
	}
	else
	{
		//getting rained on
		//but wearing waterproof top
		if((_agent itemInSlot "body") isKindOf "RaincoatBase" || (_agent itemInSlot "body") isKindOf "Gorka_up_Base" || (_agent itemInSlot "body") isKindOf "FirefighterJacketBase")then{
			if (_isWater) then {
				_delta = 10;
			}else{
				_delta = -1*(((1+(_agentSpeed/3)) + ((windSpeed min 2) max 1))/2000*((1+worldLightScale) min 2));
			};
		//not wearing it
		}else{
			_delta = rain * 0.2;
		};
	};
	/*
	//THIS SHOULD BE removed completely imo
	if ( !(isNull (_agent itemInSlot "Feet")) ) then
	{
		_speed = speed _agent;
		if ( _speed > 0.5 ) then
		{
			_shoes = _agent itemInSlot "Feet";
			if ( damage _shoes < 1 ) then
			{
				_rough = getNumber (configFile >> "CfgSurfaces" >> surfaceType getPosASL _agent >> "rough");
				_hp = getNumber (configFile >> "CfgVehicles" >> typeOf _shoes >> "armor");
				if (_speed < 5) then
				{
					_rough = _rough * 0.25;
				};
				if (_speed >= 5 && _speed <= 10) then
				{
					_rough = _rough * 0.5;
				};
				if (_speed > 15) then
				{
					_rough = _rough * 2;
				};

				_dmg = (1/_hp) * 0.01 * _rough;
				_shoes setDamage damage _shoes + _dmg;
			};
		};
	};
	*/
	
};


/* GETTING WET OR DRY */

if(_delta != 0)then{
	_playerWet = _agent getVariable ["wet",0];
	_playerWet = ((_playerWet + (_delta * (_agentSpeed /8))) min 1) max 0;
	_agent setVariable ["wet",_playerWet];
	//display notifier in inventory
	if (_playerWet > 0) then { 
		[0,_agent,"Wet"] call event_modifier; //this could be probably done better just by permanent modifier?
	};
};


/* BONE DAMAGE HEALING */

_pblood = _agent getVariable ['blood',2500];
_penergy = _agent getVariable['energy',2500];
_pwater = _agent getVariable['water',2500];

if((_pblood >= 5000) && (_pwater > 2500) && (_penergy > 4000))then{
	_plegsdmg = _agent getHitPointDamage 'HitLegs';
	_pdamage = damage _agent;
	if(_pdamage > 0)then{
		_agent setDamage (_pdamage - 0.0025 * DZ_TICK);
	};
	if(_plegsdmg > 0)then{
		_agent setHit ['legs',_plegsdmg- 0.0005 * DZ_TICK];
	};
};


/* TEMPERATURE */

	//CALCULATING HEAT FROM HEATPACKS AND PREHEATED ITEMS
	
_total_heat = 0; //total heat from all heated items that are stored/attached into/onto agent slots

_agent_slots = ["Body","Vest","Back","Legs","Feet"];  //slots with possible cargo items [NOTE: 'Feet' slot - because you can attach some items into 'Feet' slot that can be heated up, e.g. Knife]

{
	_slot_name = _x;
	_slot_item = _agent itemInSlot _slot_name;
	
	_heated_items_total_heat = 0; //reset counter
	_heated_items_count = 0;      
	if !(isNull _slot_item) then 
	{
		_inventory_items = itemsInInventory _slot_item;
		
		{
			_item_in_slot_item = _x;
			_item_temp = _item_in_slot_item getVariable ['temperature', 0];
			
			if ( _item_temp > 0 ) then  //calculate only when item temperature is set
			{
				_heated_items_total_heat = _heated_items_total_heat + (_item_temp min 100);  //SUM temperatures (+clamp temperature to max 100)
				_heated_items_count = _heated_items_count + 1;
			};
			
			//debugLog
			//diag_log format["Slot %1 | Slot item %2 | Item %3", _slot_name, displayName _slot_item, displayName _item_in_slot_item];		
			
		} forEach _inventory_items;
	};
	
	if ( _heated_items_count > 0 ) then
	{
		_heated_items_total_heat = _heated_items_total_heat / _heated_items_count;  //AVG of heated items in slot item
	};
		
	_total_heat = _total_heat + _heated_items_total_heat;  //SUM of all AVG temperatures from all slot items
	
} forEach _agent_slots;

//final heatcomfort value for all heated items in all (specified) agent slots
_heatcomfort_inv_items = _total_heat / 4; // for optimum heat comfort [0-25 => 1/4th of max 100]

//debugLog
//[player, format["Total heat = %1 [hc=%2]", _total_heat, _heatcomfort_inv_items], "colorStatusChannel"] call fnc_playerMessage;		


	//SETING BODY SHAKE when player is hypothermic
	//this could be probably done better just by permanent modifier?
_shake = 0;
_playerTemperature = _agent getVariable ["bodytemperature",36.5]; 
if(_playerTemperature < 35.5)then{
	_shake = ((35.5-_playerTemperature) min 1);
};
_agent SetBodyShaking _shake;

	//CALCULATING TOTAL HEATCOMFORT
_heatcomfort = 0;
_heatcomfort_max = 210; //burning state
_totalHeatIsolation = _agent getVariable ["totalHeatIsolation",0];
_totalHeatIsolation = _totalHeatIsolation max 0;
_totalHeatIsolation = (floor (_totalHeatIsolation*10))/10;
	//if standing near fireplace
_fireplace_temper_coef = 0;
_fireplace_heat_radius = 2.5;
_fireplace = [_agent, 'FireplaceBase', [], _fireplace_heat_radius] call fnc_getNearestObject; //radius max 2.5m
if !(isNil "_fireplace") then
{	
	_min_fireplace_heat_tempearature = 70; //in Â°C
	
	_fireplace_temperature = _fireplace getVariable ['temperature',0];
	_agent_distance = (getPosASL _agent) distance (getPosASL _fireplace);
	
	if (_fireplace_temperature >= _min_fireplace_heat_tempearature) then
	{
		_oldtemp = _agent getVariable["bodytemperature",37.7];
	
		if (_oldtemp < 37.6) then
		{
			_temp = 0.008 * (_fireplace_heat_radius - ((getPosASL _agent) distance (getPosASL _fireplace)));
		
			if (_temp > 0) then
			{
				_agent setVariable["bodytemperature",_oldtemp + _temp];
			};
		};
		
		//over-heat
		if (_agent_distance <= 0.5) exitWith //radius 0.0-0.4m
		{
			_fireplace_temper_coef = 210; //heatcomformt ~210
		};
		//over-heat
		if (_agent_distance <= 1.0 and _agent_distance > 0.5) exitWith //radius 0.4-0.8m
		{
			_fireplace_temper_coef = 60;  //heatcomformt ~40-60
		};
		//low heat
		if (_agent_distance <= _fireplace_heat_radius and _agent_distance > 1.0) exitWith //radius 0.8-2.5m
		{
			_fireplace_temper_coef = 30; //heatcomformt ~10-30
		};
	};
};

_heatcomfort = (_heatcomfort_inv_items + _fireplace_temper_coef + (((_airTemperature+_totalHeatIsolation) max 7)*((((_agentSpeed/3.2) max 1) - _playerWet) max 0.1))- ( _playerTemperature + (((worldLightScale max 0) min 2)*5) - ((windSpeed*3) min 6) - ((getPosASL _agent select 2)/100) ) ) min _heatcomfort_max;

_agent setVariable ["heatcomfort",_heatcomfort];

ProfileStop "tick_environment.sqf";