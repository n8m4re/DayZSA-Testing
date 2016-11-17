private ["_key"];

_key = format ["UID_%1", _this];

_re = callFunction ["Enf_DbWrite",_key, format ["%1",[]] ];

if (DB_DEBUG) then {
	diag_log format ["dbCreateCharInProfile: %1",_key];
	diag_log format ["callFunction result: %1",_re];
};

true
