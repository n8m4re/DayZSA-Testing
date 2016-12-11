private ["_uid","_char","_key","_agent","_state","_hands","_slots","_quickbar"];

_uid = _this;

_char = _uid call fnc_dbFindInProfile;

_key = format["UID_%1",_uid];

if !(_char select 0) exitWith {objNull};

_state = call compile callFunction ["DataBaseRead","STATE",_key];

_hands = call compile callFunction ["DataBaseRead","HANDS",_key];

_slots = call compile callFunction ["DataBaseRead","SLOTS",_key];

_quickbar = call compile callFunction ["DataBaseRead","QUICKBAR",_key];

_agent = createAgent [(_char select 1),(_char select 2),[],0,"NONE"];

_agent setPosATL (_char select 2); // _agent setPos (_char select 2);	_agent setposASL (_char select 2);

_agent setDir (_char select 3);

_agent switchMove (_char select 6); 

// _agent setVectorUp (_char select 4);

// _agent setVectorDir (_char select 5);

// null = _agent moveToHands objNull;

// STATE
{
	private ["_name","_value"];
	
	_name = _x select 0;
	
	_value =  _x select 1;
	
	if (_name == "bleedingsources" ) then 
	{	
		_value = str(_x select 1);
	};

	_agent setVariable[_name,_value];

} forEach _state;


// HANDS
null = [_agent,_hands] call fnc_addHandsItem;


// INVENTORY
_inventory = [];
{
	_re = call compile callFunction ["DataBaseRead",_x,_key];
	_inventory set [(count _inventory),_re];
} forEach _slots;
null = [_agent,_inventory] call fnc_addInvItems;



// QUICKBAR
null = [_agent,_quickbar] call fnc_addQuickBarItems;

			
if (DB_DEBUG) then {diag_log format[":::: dbLoadFromProfile: %1",_char]};

_agent
