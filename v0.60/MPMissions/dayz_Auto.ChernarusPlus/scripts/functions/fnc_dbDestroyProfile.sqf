private ["_key","_uid","_agent"];

_uid = _this select 0;

_agent = _this select 1;

_agent setDamage 1;

null = [_uid, _agent] call fnc_dbSaveToProfile;

_re = callFunction ["Enf_DbDelete",format["%1_CHAR",_uid]];

_re = callFunction ["Enf_DbDelete",format["%1_ITEMS",_uid]];

_re = callFunction ["Enf_DbDelete",format["%1_STATE",_uid]];

if (DB_DEBUG) then {
	diag_log format ["dbDestroyProfile: %1", _uid];
};

true
