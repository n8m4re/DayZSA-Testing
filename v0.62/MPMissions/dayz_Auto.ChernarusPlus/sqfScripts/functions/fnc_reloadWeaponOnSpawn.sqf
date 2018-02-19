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
				_a = moveToGround _x; 
				_b = moveToGround _parent;
				waitUntil {_a && _b};
				null = _parent moveToInventory _x;
				null = _agent moveToInventory _parent;
				// _agent playAction 'ReloadMagazine';
			};		
		};

	} forEach  _itemsInInventory;
