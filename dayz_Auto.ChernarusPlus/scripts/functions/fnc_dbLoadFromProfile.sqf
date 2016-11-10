private ["_char", "_agent", "_v"];

_char = _this call fnc_dbFindInProfile;

_agent = createAgent [(_char select 1),(_char select 2),[],0, "NONE"];

_agent setposASL (_char select 2);

_agent setDir (_char select 3);

// _agent setVectorDirAndUp [_dir,_up];

{
	null = _agent setVariable[(_x select 0),(_x select 1)]
} forEach (_char select 5);

{
	_v = _agent createInInventory (_x select 0); 
	_v setQuantity (_x select 1);
	_v setDamage (_x select 2);
 } forEach (_char select 4);



if (DB_DEBUG) then {
	diag_log format ["dbLoadFromProfile: %1",_char];
};

_agent
