private ["_char","_agent","_hand","_hands","_qb"];

_char = [];
_char = _this call fnc_dbFindInProfile;
_agent = createAgent [(_char select 1),(_char select 2),[],0, "NONE"];
_agent setposASL (_char select 2);
_agent setDir (_char select 3);
// _agent setVectorDirAndUp [_dir,_up];

// Player stats
{ _agent setVariable[(_x select 0),(_x select 1)] } forEach (_char select 5);


// Inventory Items
[_agent, (_char select 4)] call fnc_addInvItems;


// Hands
_hands = _char select 7;
if ( (count _hands) > 0 ) then {

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
	
	_hand setVariable ["wet",((_char select 7) select 4)];
	
	/*
	if ( _hand isKindOf "Pistol" || _hand isKindOf "MilitaryRifle" ) then {
		 // _ammo = weaponRemoveBullet _hand;
		  _ammoList = weaponAmmoEx _hand;
		 diag_log format ["HANDS: ammolist: %1",_ammoList];
	};
	*/
};

//Quickbar 
_qb = _char select 6;
if ( (count _qb) > 0 ) then {
	{
		_item = _x;
		{
			if ( (typeOf _item) == (_x select 1) ) exitWith {
				null = _agent setEntityToQuickBarIndex [_item,(_x select 0)];
			};
		} forEach _qb;	
	} forEach (itemsInInventory _agent);
};



if (DB_DEBUG) then {
	diag_log format ["dbLoadFromProfile: %1",_char];
};

_agent
