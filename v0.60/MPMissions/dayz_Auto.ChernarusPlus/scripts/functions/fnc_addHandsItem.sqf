private ["_agent","_hand","_itemInHand"];

_agent = _this select 0;
_itemInHand = _this select 1;

if ( (count _itemInHand) > 0 ) then 
{
	_hand = _agent createInHands (_itemInHand select 0);	
	
	[_hand, (_itemInHand select 1)] call fnc_addItemState;	

	if ( count (_itemInHand select 2) > 0 ) then {
		[_hand, (_itemInHand select 2)] call fnc_addInvItems;
	};
};
 
true
