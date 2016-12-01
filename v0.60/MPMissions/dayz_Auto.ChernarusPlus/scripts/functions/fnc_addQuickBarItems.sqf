private ["_arr"];
if (typeName(_this select 1) == "ARRAY") then 
{
	_arr = [];
	{
		_in = (_this select 1) find (typeOf _x);
		if !( (typeOf _x) in _arr ) then
		{
			if ( _in > -1) then 
			{
				null = (_this select 0) setEntityToQuickBarIndex [_x,_in];
				_arr set [count _arr, (typeOf _x)];
			};
		};
	} count (itemsInInventory (_this select 0));
	
};

true
