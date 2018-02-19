
_first = _this select 0;

_killed = false;

if ((lifeState _agent == "ALIVE")&&(not captive _agent)) then {
	
	if ( _first > 0 ) then {
		
		_agent call dbSavePlayerPrep;
		
		[_uid, _agent] call fnc_dbSaveToProfile;
		
		diag_log "Saved as alive";
	};
	
	
} else {

	if (!isNull _agent) then {
		
	
		_agent setDamage 1;
		
		_killed = true;
		
		[_uid, _agent] call fnc_dbDestroyProfile;
		
		diag_log "Saved as dead";
		
	} else {
	
		diag_log "No save, null";
	};
};

_killed
