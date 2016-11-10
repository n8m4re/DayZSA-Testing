private ["_char","_key","_re"];
/*
 alive 0 | model/type 1 | pos 2 | dir 3 | inv 4 | stats 5 | online 6 
*/
_key = format ["UID_%1", _this];

_char = profileNamespace getVariable _key;

_re = [false,"",[0,0,0],0,[],[],true];

if (!isNil "_char") then { _re  = _char };
_re
