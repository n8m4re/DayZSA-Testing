private["_myNtfrs","_color","_item","_i","_name"];

_myNtfrs = [];

_color = [];

_myNtfrs = _this getVariable ["myNotifiers",[]];
	
{
	if !( isNil "_x" ) then 
	{		
		if (typeName _x == "ARRAY") then
		{
			_name = "";
			_color = [0,0,0];
			_alpha = 0;
			if ( count _x > 0 ) then
			{	
				_name = _x select 0;
				_color = _x select 1;
				_alpha = 0.5;
			};
			_this callMethod ["SQF_PlayerNotifierAdd", _name, _forEachIndex, _color select 0, _color select 1, _color select 2, _alpha];
		};
	};

} forEach _myNtfrs;


_this callMethod ["SQF_PlayerNotifierSend"];