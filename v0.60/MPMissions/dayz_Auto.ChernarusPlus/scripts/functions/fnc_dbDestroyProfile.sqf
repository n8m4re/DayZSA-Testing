private ["_key","_uid","_agent"];

_uid = _this select 0;

_agent = _this select 1;

_agent setDamage 1;

null = [_uid, _agent] call fnc_dbSaveToProfile;

_key = format ["UID_%1", _uid];

_re = callFunction ["Enf_DbDelete",_key];

// _uid call fnc_dbCreateCharInProfile;

if (DB_DEBUG) then {
	diag_log format ["dbDestroyProfile: %1", _key];
	diag_log format ["callFunction result: %1",_re];
};

true
