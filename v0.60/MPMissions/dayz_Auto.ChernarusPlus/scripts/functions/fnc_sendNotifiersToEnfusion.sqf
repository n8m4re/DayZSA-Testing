private["_myNtfrs","_name","_added"];

_myNtfrs = [];

_added = [];

_myNtfrs = _this getVariable ["myNotifiers",[]];

{
	if !( isNil "_x" ) then 
	{	
		if (typeName _x == "ARRAY") then
		{
			if ( count _x > 0 ) then
			{	
				
				_name = _x select 0;
				_color = _x select 1;
				_alpha = 0.5;
				null = _this callMethod ["SQF_PlayerNotifierAdd", _name, _forEachIndex, _color select 0, _color select 1, _color select 2, _alpha];
				_added set [count  _added, 1];
			};
		};
	};
} forEach _myNtfrs;


if ( count _added > 0 ) then
{
	null = _this callMethod ["SQF_PlayerNotifierSend"];
	_added = [];
};

true
