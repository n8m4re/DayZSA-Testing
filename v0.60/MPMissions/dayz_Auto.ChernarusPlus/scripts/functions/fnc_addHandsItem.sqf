private ["_obj","_itemInHand","_hand"];

_obj = _this select 0;

_itemInHand = _this select 1;

if (isNull _obj) exitWith {true};

if !(typeName _itemInHand == "ARRAY") exitWith {true}; 

if !( count _itemInHand > 0 ) exitWith {true}; 

_hand = _obj createInHands (_itemInHand select 0);

if (isNull _hand) then
{
	_hand = (_itemInHand select 0) createVehicle (getPosATL _agent);
	_hand setPosATL (getPosATL _agent);
};	


if !(isNull _hand) then 
{	

	if ( count (_itemInHand select 1) > 0 ) then 
	{ 
		[_hand, (_itemInHand select 1)] call fnc_addItemState;
	};
	
	if ( count (_itemInHand select 2) > 0 ) then 
	{ 
		[_hand, (_itemInHand select 2)] call fnc_addInvItems;
	};
};


true
