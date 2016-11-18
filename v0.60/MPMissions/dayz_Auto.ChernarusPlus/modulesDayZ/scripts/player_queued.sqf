player_queued_isrunning = true;

_queueTime = _this select 0;
_newChar = _this select 1;

if (_queueTime < 0) then
{
	while {_queueTime < 0} do
	{
		titleText [format["Spawning in %1 seconds... Please wait...",-_queueTime],"BLACK FADED",10e10];
		_queueTime = _queueTime + 1;
		sleep 1;
	};
};

titleText ["Please wait...","BLACK FADED",10e10];

if (_newChar) then
{
	//load data
	_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
	_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
	_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe"); 
	_format = getText(configFile >> "cfgCharacterCreation" >> "format");

	//find selected skin
	_charType = profileNamespace getVariable ["defaultCharacter",""];
	char_type_n = DZ_SkinsArray find _charType;
	if (char_type_n < 0) then {char_type_n = floor random (count DZ_SkinsArray)};
	 
	//generate inventory array
	top_n = floor random (count _top); 
	bottom_n = floor random (count _bottom); 
	shoe_n = floor random (count _shoe);
	_array = profileNamespace getVariable ["defaultInventory",[]];
	{
		switch true do
		{
			case (_x isKindOf "TopwearBase"): {
				top_n = (_top find _x);
			};
			case (_x isKindOf "BottomwearBase"): { 
				bottom_n = (_bottom find _x);
			};
			case (_x isKindOf "FootwearBase"): {
				shoe_n = (_shoe find _x);
			};
		};
	} forEach _array;
};

player_queued_isrunning = false;
