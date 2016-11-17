private ["_char","_agent","_hand"];

_char = [];
_char = _this call fnc_dbFindInProfile;
_agent = createAgent [(_char select 1),(_char select 2),[],0, "NONE"];
_agent setposASL (_char select 2);
_agent setDir (_char select 3);
// _agent setVectorDirAndUp [_dir,_up];

// Player stats
{ _agent setVariable[(_x select 0),(_x select 1)] } forEach (_char select 5);


// Hands
if ( count (_char select 7) != 0 ) then {

	_hand = _agent createInHands ((_char select 7) select 0);
	
	_hand setDamage ((_char select 7) select 1);
		
	if (_hand isKindOf "MagazineBase") then {
		_hand setMagazineAmmo ((_char select 7) select 2);
	} else {
		_hand setQuantity ((_char select 7) select 2);
	};	
		
	if ( count ((_char select 7) select 3) != 0 ) then {
		[_hand, ((_char select 7) select 3)] call fnc_addInvItems;
	};
	
	_hand setVariable ["wet",((_hand select 7) select 4)];
	
};


// Inventory Items
[_agent, (_char select 4)] call fnc_addInvItems;


if (DB_DEBUG) then {
	diag_log format ["dbLoadFromProfile: %1",_char];
};

_agent
