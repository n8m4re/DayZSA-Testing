private ["_player","_state","_params"];

/*
	Manage fireplace actions.
	
	Usage:
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

_duplicate_item = 
{
	_item = _this select 0;
	_duplicate_item_type = _this select 1;
	
	_item_duplicated = _duplicate_item_type createVehicle position _item;
	
	//transfer modifiers
	_item_duplicated setDamage (damage _item);
	_item_duplicated setQuantity (quantity _item);
	
	//transfer attachments
	{
		_item_duplicated movetoInventory _x;
		
		//[_player, format['Item %1 attached to %2 [total : %3].', _x, _item_duplicated, itemsInInventory _item_duplicated],'colorAction'] call fnc_playerMessage;
	} foreach itemsInInventory _item; 
	
	//transfer cargo items
	{
		_item_duplicated moveToCargo _x;
		
		//[_player, format['Item %1 moved to cargo %2[total : %3].', _x, _item_duplicated, itemsInCargo _item_duplicated],'colorAction'] call fnc_playerMessage;
	} foreach itemsInCargo _item;
	
	_item_duplicated
};

switch _state do
{	
	//craft fireplace
	case 0:
	{
		_tool1 = _params select 0; //fuel item
		_tool2 = _params select 1; //kindling item
		
		//create in inventory
		_fireplace = ["Fireplace", _player] call player_addInventory;
		
		//split and move stick, kindling into created fireplace (moveToInventory)
		//tool1
		_tool1_new = _fireplace createAsAttachment (typeOf _tool1);
		_use_quantity = 0;
		if ( quantity _tool1 > 0 && quantity _tool1 < 1 ) then 
		{
			_use_quantity = quantity _tool1; 	//item with % quantity
		}
		else
		{
			_use_quantity = 1; 					//item with pcs quantity
		};
		_tool1_new setDamage (damage _tool1);
		_tool1_new setQuantity _use_quantity;
		[_tool1, -_use_quantity] call fnc_addQuantity;  //remove quantity only if the new tool is created

		_tool2_new = _fireplace createAsAttachment (typeOf _tool2);
		_use_quantity = 0;
		if ( quantity _tool2 > 0 && quantity _tool2 < 1 ) then 
		{
			_use_quantity = quantity _tool2;	//item with % quantity
		}
		else
		{
			_use_quantity = 1;					//item with pcs quantity
		};
		_tool2_new setDamage (damage _tool2);
		_tool2_new setQuantity _use_quantity;
		[_tool2, -_use_quantity] call fnc_addQuantity; //remove quantity only if the new tool is created
		
		//player message
		[_player, format['I made a fireplace.'],'colorAction'] call fnc_playerMessage;
	};
	
	//place on the ground - START
	case 1:
	{
		_fireplace = _params select 0;
		
		//set distance according to direction
		_dist = 0.2;
        _dir = direction _player;
		_player_pos = getPosASL _player;
        _xPos = (_player_pos select 0) + (sin _dir * _dist);
        _yPos = (_player_pos select 1) + (cos _dir * _dist);
		_zPos = _player_pos select 2;
		_fireplace_pos_new = [_xPos, _yPos, _zPos];
				
		//PREREQUISITIES
		_xPos = _fireplace_pos_new select 0;
		_yPos = _fireplace_pos_new select 1;
		_zPos = _fireplace_pos_new select 2;
		//test collision
		_bbox = (collisionBox [[_xPos, _yPos, _zPos], [2,2,4] ,[[1,0,0], [0,0,1]], players]);
		if ( _bbox ) exitWith
		{
			[_player,format['I cannot place the fireplace here.'],'colorAction'] call fnc_playerMessage;
		};	
		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_sur = surfaceTypeASL [_xPos, _yPos, _zPos];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot place the fireplace into the water.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//store parameters
		_player setVariable ['play_action_params', [_fireplace, _fireplace_pos_new]];
		_player playAction ['ItemUseShort', {[11, _this, []] call fireplace_manageActions;}];
	};
	
	//place on the ground - END
	case 11:
	{
		_play_action_params = _player getVariable 'play_action_params';
		_fireplace = _play_action_params select 0;
		_fireplace_pos_new = _play_action_params select 1;
		
		moveToGround _fireplace;
		_fireplace setPosASL _fireplace_pos_new;
	};
	
	//start posing towards fireplace
	case 7:
	{
		_player playAction ['fishingStart',{}];
	};
	
	//bury ashes START
	case 8:
	{
		_fireplace = _params select 0;
		_tool = itemInHands _player;
		
		//conditions - not empty
		if (count (itemsInCargo _fireplace) > 0 or 
			count (itemsInInventory _fireplace) > 0) exitWith
		{
			[_player, format['There is still something left in the ashes.'],'colorAction'] call fnc_playerMessage;
		};
		
		//conditions - not soft surface
		_surface = surfaceTypeASL (getPosASL _fireplace);
		if !(_surface call fnc_isSoftSurface) exitWith
		{
			[_player, format['You cannot bury the ashes here.'],'colorAction'] call fnc_playerMessage;
		};
		
		//action name
		_action_name = "PlayerCraft";
		switch (true) do
		{
			case (_tool isKindOf "Tool_Shovel"): { _action_name = "digShovel"; };
			case (_tool isKindOf "FarmingHoe"): { _action_name = "digHoe"; };
			case (_tool isKindOf "Pickaxe"): { _action_name = "digHoe"; };
			case (_tool isKindOf "Tool_Iceaxe"): { _action_name = "PlayerCraft"; };
		
			default{};
		};
		
		//set player 
		_player setVariable ['isUsingSomething', 1];
		_fireplace setVariable ['is_in_use', true];
		//action
		_player setVariable ['play_action_params', [_fireplace]];
		_player playAction [_action_name, {[81, _this, []] call fireplace_manageActions}];
	};
	
	//bury ashes END
	case 81:
	{
		_params = _player getVariable 'play_action_params';
		_fireplace = _params select 0;
		
		//remove fireplace (ashes)
		deleteVehicle _fireplace;
		
		//set player 
		_player setVariable ['isUsingSomething', 0];
		_fireplace setVariable ['is_in_use', false];
		
		//clear clutter cutter
		deleteVehicle nearestobject [_fireplace, "Fireplace_ClutterCutter"]; //remove clutter cutter

		[_player, format['I have buried the ashes.'],'colorAction'] call fnc_playerMessage;
	};
	
	//barel - open lid
	case 2:
	{
		_fireplace = _params select 0;
		
		_fireplace animate ['LidOff',0]; 
		_fireplace animate ['LidOn',1];
		
		//set parameters
		_fireplace setVariable ["temperature_loss_mp", 1]; 
		_fireplace setVariable ["fuel_burn_rate_mp", 1]; 
	};
	
	//barrel - close lid
	case 3:
	{
		_fireplace = _params select 0;
		
		_fireplace animate ['LidOff',1]; 
		_fireplace animate ['LidOn',0];
		
		//set parameters
		_fireplace setVariable ["temperature_loss_mp", 0.5]; 
		_fireplace setVariable ["fuel_burn_rate_mp", 0.7]; 
	};
	
	//place fireplace into house
	case 9:
	{
		_fireplace_point_source = _params select 0;
		_fireplace_inhands = itemInHands _player;
		_fireplace_point_name = _params select 1;
		_fireplace_smoke_name = _params select 2;
		_fireplace_slot_name = _params select 3;
		
		//get smoke point for fire particles
		_fireplace_point_pos = _fireplace_point_source selectionPosition _fireplace_point_name;
		_fireplace_point_pos_world = _fireplace_point_source modelToWorld _fireplace_point_pos;
		
		//duplicate item (transfer attachments and cargo)
		_fireplace_indoor = [_fireplace_inhands, "FireplaceIndoor"] call _duplicate_item;
		
		//correct position and delete object in hands
		_fireplace_indoor setPosATL _fireplace_point_pos_world;
		deleteVehicle _fireplace_inhands;
		
		_fireplace_indoor setVariable ['smoke_particle_point', _fireplace_smoke_name];
		_fireplace_indoor setVariable ['indoor_slot_name', _fireplace_slot_name];
		_fireplace_point_source setVariable [_fireplace_slot_name, 1];
	};	

	//take fireplace from the fireplace point (indoor)
	case 10:
	{
		_fireplace = _params select 0;
		_fireplace_slot_name = _fireplace getVariable ['indoor_slot_name', nil];
		
		//duplicate item (transfer attachments and cargo)
		_fireplace_inhands = [_fireplace, "Fireplace"] call _duplicate_item;
		
		//free fireplace indoor slot
		_fireplace_point_source = [_fireplace, "HouseWithFireplace", [], 20] call fnc_getNearestObject;
		_fireplace_point_source setVariable [_fireplace_slot_name, 0];
		
		//take into hands 
		_player moveToHands _fireplace_inhands;
		deleteVehicle _fireplace;
	};	
	
	default {};
};
