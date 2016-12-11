private ["_itemInHands","_itemsInInventory"];

_agent = _this;

_itemInHands = itemInHands _agent;

_itemsInInventory = itemsInInventory _agent;

{

	if(isClass(configFile >> "CfgMagazines" >> typeOf _x)) then 
	{	
		_parent = itemParent _x;
		
		if(isClass(configFile >> "cfgWeapons" >> typeOf _parent)) then 
		{
			moveToGround _parent;
			moveToGround _x;
			_parent moveToInventory _x;
			_agent moveToInventory _parent;
			//_agent moveToHands _parent;
			// _agent playAction 'ReloadMagazine';
			// _agent moveItemFromHandsToInventory _parent;
		};		
	};

} forEach  _itemsInInventory;

/*
if !(isNull _itemInHands) then 
{
		if !(isClass(configFile >> "cfgWeapons" >> typeOf _itemInHands))exitWith{};	
	
		{
			if(isClass(configFile >> "CfgMagazines" >> typeOf _x)) then 
			{	
				_parent = itemParent _x;
				moveToGround _parent;
				moveToGround _x;
				_parent moveToInventory _x;
				_agent playAction 'ReloadMagazine';
				
				// _agent moveToHands _parent;
				// _agent takeInHands _parent;
				
			};
		} forEach (itemsInInventory _itemInHands);
};	
*/