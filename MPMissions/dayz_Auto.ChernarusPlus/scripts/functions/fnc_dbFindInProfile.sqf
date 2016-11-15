private ["_char","_key","_re","_c"];
/*
 alive 0 | model/type 1 | pos 2 | dir 3 | inv 4 | stats 5 | online 6 
*/
_key = format ["UID_%1", _this];

_re = [false,"",[0,0,0],0,[],[],true];

// _char = profileNamespace getVariable _key;

_c = callFunction ["Enf_DbRead", _key];

diag_log format ["DEBUG-LOAD: %1", _c];
	
if (_c != "") then { 
	
	call compile format["_re = %1", _c];

};

_re
