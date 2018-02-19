private["_myNtfrs","_color","_item","_i","_name"];
_myNtfrs = [];
_color = [];
_myNtfrs = _this getVariable ["myNotifiers",[]];	
for [{_i=0},{ _i < count _myNtfrs},{_i=_i+1}] do
{
	_item = _myNtfrs select _i;		
	
	if !( isNil "_item" ) then
	{		
		if (typeName _item == "ARRAY") then
		{
			_name = "";
			_color = [0,0,0];
			_alpha = 0;
		
			if ( count _item > 0 ) then
			{	
				_name = _item select 0;
				_color = _item select 1;
				_alpha = 0.5;
			};
			
			_this callMethod ["SQF_PlayerNotifierAdd", _name, _i, _color select 0, _color select 1, _color select 2, _alpha];				
		};
	};
};

_this callMethod ["SQF_PlayerNotifierSend"];
