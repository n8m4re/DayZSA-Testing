// private["_array"];
_agent = _this;
//save lifestate
switch (lifeState _agent) do
{
	case "UNCONSCIOUS": {
		_agent setVariable ["unconscious",true];
	};
	case "ALIVE": {
		_agent setVariable ["unconscious",false];
	};
	default {
		_agent setVariable ["unconscious",false];
	};
};

//save damage
//diag_log format ["Using %1",DZ_PlayerHitpoints];
/*
_array = [];
{
	_v = _agent getHitPointDamage _x;
	//diag_log format ["Saving hitpoint %1 with %2",_x,_v];
	if (_v > 0) then
	{
		_array set [count _array,[_x,_v]];
	};
} forEach DZ_PlayerHitpoints;
_agent setVariable ["damageArray",_array];
//diag_log format ["Saved %1",_array];
*/

true
