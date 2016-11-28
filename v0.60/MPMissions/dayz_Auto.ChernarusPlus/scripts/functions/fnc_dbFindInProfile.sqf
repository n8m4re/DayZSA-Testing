private ["_re"];
// _re = callFunction ["Enf_DbRead",_key];
_re = callFunction ["Enf_DbRead",format["%1_CHAR",_this]];
if ( _re == "") then 
{ [false,"",[0,0,0]] } 
else 
{ call compile _re };
