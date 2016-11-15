private ["_key","_def"];

_key = format ["UID_%1", _this];
_def = format ["%1",[false,"",[0,0,0],0,[],[],true]];
//  profileNamespace setVariable [_def];
// saveProfileNamespace;
callFunction ["Enf_DbWrite",_key,_def];

if (DB_DEBUG) then {
	diag_log format ["dbCreateCharInProfile: %1", _key];
};

true