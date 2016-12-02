private ["_item","_state","_itemVars"];

_item = _this select 0;

_state = _this select 1;

_itemVars = _state select 2;

_item setDamage (_state select 0);

if (_item isKindOf "MagazineBase" ) then 
{
	_item setMagazineAmmo (_state select 1);
} else {
	_item setQuantity (_state select 1);
};	

if ( typeName _itemVars == "ARRAY" ) then
{
	{ _item setVariable [(_x select 0),(_x select 1)] } forEach _itemVars;
};


true
