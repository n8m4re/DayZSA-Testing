private ["_id","_uid","_agent","_freePos"];

_id = _this select 0;

_uid = _this select 1;

_uidFound = 0;

for "_i" from 0 to count players - 1 do
{
	_actPlayer = players select _i;
	
	_actPlayerUid = getPlayerUID _actPlayer;
	
	if ( _actPlayerUid == _uid ) then { _uidFound = 1; };
};

if ( _uidFound == 0 ) then 
{ 
	_agent = _uid call fnc_dbLoadFromProfile;
	
	[_agent,_uid,_id] call init_newBody;
		
	connectedPlayers set [(connectedPlayers find 0), _id];
	
	//null = _agent call fnc_reloadWeaponOnSpawn;	
	
	null = [_agent,call compile callFunction ["DataBaseRead","QUICKBAR",format["UID_%1",_uid]]] call fnc_addQuickBarItems;
	
} else {

	diag_log format["CONNECTION: Player %1 has double UID on connect server, we are don't load him!",_uid];
	
	_id statusChat ["Your have double UID on connect server, we are don't load this.","ColorImportant"];
};
