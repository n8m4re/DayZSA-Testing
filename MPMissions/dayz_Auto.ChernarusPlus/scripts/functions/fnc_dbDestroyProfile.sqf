private ["_char","_key"];

_agent = _this select 1;

_key = format ["UID_%1", _this select 0];

// _char = profileNamespace getVariable _key;
// if (!isNil "_char") then {
// 	profileNamespace setVariable [_key, nil];
// };
// saveProfileNamespace;

callFunction ["Enf_DbDelete",_key];


if (DB_DEBUG) then {
	diag_log format ["dbDestroyProfile: %1", _char];
};

true