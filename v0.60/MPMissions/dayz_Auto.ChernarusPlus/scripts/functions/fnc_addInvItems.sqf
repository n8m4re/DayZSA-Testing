private ["_item","_agent"];
_agent = _this select 0;
_item = objNull;
{
	// _class = _x select 0; _state = _x select 1; _inv = _x select 2;
	
	if ( (_x select 0) isKindOf "AttachmentBase" || (_x select 0) isKindOf "MagazineBase" ) then
	{
		_item = _agent createWeaponAttachment (_x select 0);
		 // diag_log format ["createWeaponAttachment: %1 | %2",(_x select 0) ,itemParent _item];
	} else {	
	
		_item = _agent createInInventory (_x select 0);
		// diag_log format ["createInInventory: %1 | %2",(_x select 0),itemParent _item];
	};
	
	// diag_log format ["INVENTORY: %1 | %2 | %3",_class,_item,(_x select 2)];
	
	[_item, (_x select 1)] call fnc_addItemState;
	
	if ( (count (_x select 2)) > 0 ) then {[_item, (_x select 2)] call fnc_addInvItems;};
		
} forEach (_this select 1);

true
