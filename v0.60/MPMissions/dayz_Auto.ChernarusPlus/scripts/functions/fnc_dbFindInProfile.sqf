private ["_re","_key"];
_key = format["UID_%1",_this];
_re = callFunction ["Enf_DbRead",_key];
if ( _re == "") then 
{ [false,"",[0,0,0]] } 
else 
{ call compile _re };
