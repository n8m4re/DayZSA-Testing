private ["_return"];
_return = [];
_cfg = ["cfgVehicles","cfgWeapons","cfgMagazines"];
{
	_configFile = configFile >> _x >> _this >> "itemSize";
	if (isArray _configFile) then {
		_return = getArray (_configFile);
		if ( (typeName _return == "ARRAY") && (count _return > 0) ) then {
			_return
		};
	};
} forEach _cfg;
_return
