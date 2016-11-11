private ["_key"];

_key = format ["UID_%1", _this];

profileNamespace setVariable [_key,[false,"",[0,0,0],0,[],[],true]];

saveProfileNamespace;

if (DB_DEBUG) then {
	diag_log format ["dbCreateCharInProfile: %1", _key];
};

true