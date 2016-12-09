private ["_re","_uid","_key"];
_uid = _this;
_key = format["%1_CHAR",_uid];
_re = callFunction ["DataBaseRead",format["%1_CHAR",_uid]];
if (_re == "") exitWith {[false,"",[0,0,0]]};
if (DB_DEBUG) then {diag_log format [":::: dbFindCharInProfile: %1",_key]};
call compile _re
