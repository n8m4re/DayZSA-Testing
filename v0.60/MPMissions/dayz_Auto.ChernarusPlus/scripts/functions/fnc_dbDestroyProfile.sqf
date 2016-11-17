private ["_key"];

_key = format ["UID_%1", _this];

_re = callFunction ["Enf_DbDelete",_key];

if (DB_DEBUG) then {
	diag_log format ["dbDestroyProfile: %1", _key];
	diag_log format ["callFunction result: %1",_re];
};

true
