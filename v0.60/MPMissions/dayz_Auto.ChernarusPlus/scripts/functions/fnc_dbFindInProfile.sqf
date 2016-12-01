private ["_re"];
_re = call compile callFunction ["DataBaseRead",format["%1_CHAR",_this]];
if ( isNil "_re" ) exitWith {[false,"",[0,0,0]]};
_re
