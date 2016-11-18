private ["_arr","_item","_agent"];

_agent = _this select 0;
_arr = [];
{
	_class = _x select 0;
	_dmg = _x select 1;
	_qty = _x select 2;
	_inv = _x select 3;
	_wet = _x select 4;
	
	/*
	if ( _class isKindOf "AttachmentBase" ) then {	
		_item = _agent createAsAttachment _class;
	} else {
		_item = _agent createInInventory _class;
	};
	*/
	
	_item = _agent createInInventory _class;
	
	_item setDamage _dmg;
	
	_item setVariable ["wet", _wet];
	
	if (_item isKindOf "MagazineBase") then {
		_item setMagazineAmmo _qty;
	} else {
		_item setQuantity _qty;
	};	
	
	if ( count _inv != 0 ) then {
		null = [_item, _inv] call fnc_addInvItems;
	};
		
} forEach (_this select 1);

true
