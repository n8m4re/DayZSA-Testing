private ["_arr","_item","_agent"];

_agent = _this select 0;
_arr = [];
{

	_item = _agent createInInventory (_x select 0);
	
	_item setDamage (_x select 1);	
	
	if (_item isKindOf "MagazineBase") then {
		// _item = _agent createAsAttachment (_x select 0);
		_item setMagazineAmmo (_x select 2);
	} else {
		_item setQuantity (_x select 2);
	};	
	
	if ( count (_x select 3) != 0 ) then {
		[_item, (_x select 3)] call fnc_addInvItems;
	};
	
	_item setVariable ["wet",(_x select 4)];
	
} forEach (_this select 1);

true
