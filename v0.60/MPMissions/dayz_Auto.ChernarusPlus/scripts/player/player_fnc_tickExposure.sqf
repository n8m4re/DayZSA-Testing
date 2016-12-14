private["_wci","_result","_items","_situations","_situation"];
/*
	Calculates how much exposure should change
*/	
_result = 0;

_items = itemsInInventory _agent;
_damper = 0;
_situations = ["heatReduction","coldReduction"];
_situation = switch true do
{
	case (windChill <= DZ_COOLING_POINT):	{1};		//cooling
	case (windChill):	{0};		//warming
};

//tally up damper based on clothing
{
	private["_isClothing","_wetness","_change"];
	_isClothing = _x isKindOf "ClothingBase";
	if (_isClothing) then
	{
		_wetness = _x getVariable ["wet",0];
		
		_change = getNumber(configFile >> "cfgVehicles" >> typeOf _x >> (_situations select _situation));
		_damper = _damper + _change;
	};
} forEach _items;

_damper = 1 - ((_damper min 1) max 0);

_wci = (windChill * _damper);

_result
