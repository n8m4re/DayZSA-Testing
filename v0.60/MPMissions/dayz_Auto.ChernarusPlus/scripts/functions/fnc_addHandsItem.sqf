private ["_agent","_itemInHand","_hand"];

_agent = _this select 0;

_itemInHand = _this select 1;

if (isNull _agent) exitWith {true};

if !(typeName _itemInHand == "ARRAY") exitWith {true}; 


_hand = _agent createInHands (_itemInHand select 0);

if ( _agent isKindOf "SurvivorBase" ) then 
{
	if (isNull _hand) then
	{
		_hand = (_itemInHand select 0) createVehicle (getPosATL _agent);
		_hand setPosATL (getPosATL _agent);
	};	
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
