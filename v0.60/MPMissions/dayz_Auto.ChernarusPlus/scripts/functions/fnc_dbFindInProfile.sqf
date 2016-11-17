private ["_key","_def","_re","_c"];

_key = format ["UID_%1", _this];

_def = [false,"",[0,0,0],0,[],[],true];

_re = _def;

_c = callFunction ["Enf_DbRead", _key];
	
if (_c != "") then {

	call compile format["_re = %1", _c];

	if ( ((count _re) == 0) || (isNil "_re") ) then {
		_re = _def;
	};
};

_re
