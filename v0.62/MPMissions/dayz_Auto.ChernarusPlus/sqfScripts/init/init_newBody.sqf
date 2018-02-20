private ["_agent","_uid","_id"];

_agent = _this select 0;
_uid = _this select 1;
_id = _this select 2;

//manage player body
playerBodies set [count playerBodies,_agent];

_agent setVariable ["UID",_uid];

diag_log format["Recording player %1 with %2",name _agent,_uid];

//move player into body
_id selectPlayer _agent;

_agent call player_initialize;	

[_id] spawnForClient compile "player execFSM '\dz\modulesDayZ\fsm\brain_player_client.fsm'";

_agent addEventHandler ["HandleDamage",{_this call event_assessDamage} ];
	
//attach inventory handlers
_agent addEventHandler ["ItemAttached",{_this call event_conatinerAttachedToPlayer} ];
_agent addEventHandler ["ItemDetached",{_this call event_conatinerDetachedFromPlayer} ];

_agent addEventHandler ["InventoryIn",{_this call event_itemInContainer} ];
_agent addEventHandler ["InventoryOut",{_this call event_itemOutOfContainer} ];

_agent call calc_heatweight;


myNotifiers = _agent getVariable ["myNotifiers",[]];

_id publicVariableClient "myNotifiers";	
