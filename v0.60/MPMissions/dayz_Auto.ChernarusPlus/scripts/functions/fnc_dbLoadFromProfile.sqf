private ["_char","_agent","_vars","_state","_items","_inventory","_hand","_itemInHands","_qb"];

_char = [];
_agent = objNull;
_state = [];
_vars = [];
_items = [];
_inventory = [];
_hand = [];
_itemInHands = [];
_qb = [];

_char = _this call fnc_dbFindInProfile;

if ( (_char select 0) ) then 
{	

	_agent = createAgent [(_char select 1),(_char select 2),[],0, "NONE"];

	_agent setposASL (_char select 2);

	_agent setDir (_char select 3);

	// _agent setVectorDirAndUp [_dir,_up];
	
	
	
	_state = call compile callFunction ["Enf_DbRead",format["%1_STATE",_this]];
	
	// Player state
	_vars = _state select 0;
	
	//Quickbar 
	_qb = _state select 1;
	
	if ( (count _vars) > 0 ) then {
		{ _agent setVariable[(_x select 0),(_x select 1)] } forEach _vars;
	};
	
	/*
		// break Legs 
		
		if ( _agent getVariable ["falldamage",false] ) then {
			null = breakLegs _agent;
		};
	*/
	

	_items = call compile callFunction ["Enf_DbRead",format["%1_ITEMS",_this]];
	
	// Inventory Items
	_inventory = _items select 0;
	null = [_agent, _inventory] call fnc_addInvItems;
		

	// Hands
	_itemInHands = _items select 1;
	
	if ( (count _itemInHands) > 0 ) then 
	{
		_hand = _agent createInHands (_itemInHands select 0);
		
		[_hand, (_itemInHands select 1)] call fnc_addItemState;	
	
		if ( count (_itemInHands select 2) > 0 ) then {
			null = [_hand, (_itemInHands select 2)] call fnc_addInvItems;
		};
	};
	

	if ( (count _qb) > 0 ) then {
		{
			_itemInInv = _x;
			{
				if ( (typeOf _itemInInv) == _x ) exitWith {
					
					null = _agent setEntityToQuickBarIndex [_itemInInv, _forEachIndex];
				};
			} forEach _qb;	
			
		} forEach (itemsInInventory _agent);
	};
	

	
	
};


if (DB_DEBUG) then {
	diag_log format ["dbLoadFromProfile: %1",_char];
	diag_log format ["::::: %1",_agent getVariable "myNotifiers"];
};

_agent
