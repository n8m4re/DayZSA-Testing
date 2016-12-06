private ["_itemState","_itemVars","_storeVariables"];

_itemState = [];

_itemVars = [];

if (isNull _this) exitWith {true};

_storeVariables = ["power","wet","internalenergy","butane","liquidType","fire","modifiers","note","ropemat","lidopen","busy","filledWith","color","message","ison","food_stage","temperature","used","state"];

{
	_var = _this getVariable _x;
	 if !(isNil "_var") then 
	 {
		if ( _x == "message") then 
		{
			_var = toArray _var;
		};
		
		_itemVars set [(count _itemVars),[_x,_var]];
	 };
} forEach _storeVariables;


_itemState set [0,(damage _this)];
	
	null = call 
	{
		if (_this isKindOf "MagazineBase") exitWith 
		{
			_itemState set [1,(magazineAmmo _this)];
		};
	
		_itemState set [1,(quantity _this)];
	};

_itemState set [2,_itemVars];


_itemState
