private ["_itemState","_itemVars"];

_itemState = [];
_itemVars = [];

_itemState set [0, (damage _this)];

if (_this isKindOf "MagazineBase") then {
	_itemState set [1,(magazineAmmo _this)];
} else {
	_itemState set [1,(quantity _this)];
};


{
	_var = _this getVariable _x;
	
	 if !(isNil "_var") then {
		_itemVars set [(count _itemVars),[_x,_var]];
	 };
 
} forEach ["power","wet","internalenergy","butane","liquidType","fire","modifiers"];


_itemState set [2,_itemVars];

_itemState
