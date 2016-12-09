private ["_uid","_agent"];

_uid = _this select 0;
_agent = _this select 1;

null = callFunction ["DataBaseDelete",format["%1_CHAR",_uid]];

null = callFunction ["DataBaseDelete",format["%1_ITEMS",_uid]];

null = callFunction ["DataBaseDelete",format["%1_STATE",_uid]];

if (DB_DEBUG) then {diag_log format [":::: dbDestroyProfile: %1", _uid]};

true
