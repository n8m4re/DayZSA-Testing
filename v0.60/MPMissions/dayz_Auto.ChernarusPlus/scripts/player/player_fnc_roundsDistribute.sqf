	/*
	Used when distributing rounds amongst piles
	uses the _quantity , _person , _ammo, _parent parent variables
	*/
	private["_pile","_receiverQty","_exchanged","_max"];
	/*
	_max = 	getNumber (configFile >> "CfgVehicles" >> _ammo >> "count");
	if (_quantity <= 0) exitWith {};
	_pile = objNull;
	{
		if (_x isKindOf _ammo) then
		{
			//has a pile
			if (!(_x call fnc_isMaxQuantity)) then
			{
				_pile = _x;
				_receiverQty = quantity _pile;
				//process changes
				_exchanged = ((_receiverQty + _quantity) min _max) - _receiverQty;
				_receiverQty = _receiverQty + _exchanged;
				
				_pile addQuantity _exchanged;				
			};
		};
	} forEach itemsInCargo _parent;
	if (_quantity > 0) then 
	{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setMagazineAmmo _quantity;
	};
	*/
	_magdmg = _this;
	
	 _max = getNumber (configFile >> "CfgMagazines" >> _ammo >> "count");
	_sound = getText (configFile >> "CfgMagazines" >> _ammo >> "emptySound");
	
	// _max =  getNumber (configFile >> "CfgVehicles" >> _ammo >> "count");
	 // _sound = getText (configFile >> "CfgVehicles" >> _ammo >> "emptySound");
	
	if (_quantity > _max)then{
		_amam = floor (_quantity/_max);
		if(_amam < 8)then{
			for [{_x=0},{_x<_amam},{_x=_x+1}] do{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setMagazineAmmo _max;
			};
			if(_amam*_max != _quantity)then{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setMagazineAmmo (_quantity-(_amam*_max));
			};
			[_person,_sound] call event_saySound;
		};
	}else{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setMagazineAmmo _quantity;
		[_person,_sound] call event_saySound;
	};
	//if unpacked ammo box is damaged pass it to ammo
	if(_magdmg != 0)then{
		_pile setDamage _magdmg;
	};
	

true
