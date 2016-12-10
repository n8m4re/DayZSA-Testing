private ["_itemState","_itemVars","_storeVariables","_mid"];

_itemState = [];

_itemVars = [];

if (isNull _this) exitWith {true};

_storeVariables = call 
{			
		if (_item isKindOf "CfgVehicles" ) exitWith 
		{
			getArray (configFile >> "CfgVehicles" >> typeOf _item >> "storeVariables")
		};

		if (_item isKindOf "cfgWeapons" ) exitWith 
		{
			getArray (configFile >> "cfgWeapons" >> typeOf _item >> "storeVariables")
		};
		
		if (_item isKindOf "CfgMagazines" ) exitWith 
		{
			getArray (configFile >> "CfgMagazines" >> typeOf _item >> "storeVariables")
		};
		
		["power","wet","internalenergy","butane","liquidType","fire","modifiers","note","ropemat","lidopen","busy","filledWith","color","message","ison","food_stage","temperature","used","state"]
};
	
	
	
{
	_var = _this getVariable _x;
	
	 if !(isNil "_var") then 
	 {
			null = call 
				{
					
					if ( _x == "message") exitWith 
					{
							
							_mid = _this getVariable ["message-id",(floor random 999)+(floor random 999)];
							
							null = callFunction ["DataBaseWrite",format ["MESSAGE-%1",_mid],format ["UID_%1",_uid],_var];

							_this setVariable ["message-id",_mid];
							
							_itemVars set [(count _itemVars),[_x,_mid]];
					};
					
					_itemVars set [(count _itemVars),[_x,_var]];
				};
		};
	 
	 
} forEach _storeVariables;


_itemState set [0,(damage _this)];
	
	null = call 
	{
		if (_this isKindOf "MagazineBase") exitWith 
		{
			_itemState set [1,(magazineAmmo _this)];
		};
	
		_itemState set [1,(quantity _this)];
	};

_itemState set [2,_itemVars];


_itemState
