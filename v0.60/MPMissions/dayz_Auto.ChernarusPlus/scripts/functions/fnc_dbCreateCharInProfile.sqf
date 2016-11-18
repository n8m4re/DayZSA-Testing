private ["_key","_char"];

_key = format ["UID_%1", _this];

_char = [false,"",[0,0,0]];
 
 _re = callFunction ["Enf_DbWrite",_key, format ["%1",_char]];

if (DB_DEBUG) then {
	diag_log format ["dbCreateCharInProfile: %1",_key];
	diag_log format ["callFunction result: %1",_re];
};

true
