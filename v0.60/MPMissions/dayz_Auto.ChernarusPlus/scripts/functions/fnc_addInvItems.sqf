private ["_arr","_item","_agent"];

_agent = _this select 0;
_arr = [];
_item = objNull;
{
	_class = _x select 0;
	_state = _x select 1;
	_inv = _x select 2;
	
	if ( _class isKindOf "BaseAttachments") then
	{	
			_item = _agent createAsAttachment _class;
		// diag_log format ["createAsAttachment: %1 | %2 ",_class,_item ];
		
	} else {
		_item = _agent createInInventory _class;
	};
	
	// diag_log format ["INVENTORY: %1 | %2 | %3",_class,_item,_inv];
	
	null = [_item, _state] call fnc_addItemState;

	if ( (count _inv) > 0 ) then {
		null = [_item, _inv] call fnc_addInvItems;
	};
		
} count (_this select 1);

true
