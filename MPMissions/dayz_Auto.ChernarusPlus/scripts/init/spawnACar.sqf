_vehicle = createVehicle ["OffroadHatchback", _this, [], 0, "CAN_COLLIDE"];	
_vehicle setDir 0;
_parts = [	
"HatchbackWheel",
"HatchbackWheel",
"HatchbackWheel",
"HatchbackWheel",
"HatchbackWheel",
"HatchbackDoors_Driver",
"HatchbackDoors_CoDriver",
"HatchbackHood",
"HatchbackTrunk",
"CarRadiator",
"CarBattery",
"SparkPlug",
"HeadlightH7",
"EngineBelt",
"TireRepairKit",
"Tool_LugWrench"
]; 
	
{ null = _vehicle createInInventory _x;} forEach _parts;	

true