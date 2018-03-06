private ["_itemSize"];

_itemSize = [];

_cfgWeapons = getArray ( configFile >> "cfgWeapons" >> _this >> "itemSize" );
_cfgMagazines = getArray ( configFile >> "cfgMagazines" >> _this >> "itemSize" );	
_cfgVehicles = getArray ( configFile >> "cfgVehicles" >> _this >> "itemSize" );

if (typeName _cfgWeapons == "ARRAY" && count _cfgWeapons > 0 ) then {
	_itemSize = _cfgWeapons;
};

if (typeName _cfgVehicles == "ARRAY" && count _cfgVehicles > 0 ) then {
	_itemSize = _cfgVehicles;
};

if (typeName _cfgMagazines == "ARRAY" && count _cfgMagazines > 0 ) then {
	_itemSize = _cfgMagazines;
};

_itemSize
