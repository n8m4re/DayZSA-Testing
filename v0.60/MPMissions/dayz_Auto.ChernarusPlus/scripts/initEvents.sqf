/*
	SERVER EVENTS
*/
DEBUGME = true;
if (isServer) then
{
	"actionReleased"  addPublicVariableEventHandler
	{
		private["_agent"];
		_agent = _this select 1;
		[_agent,"You have broken free of your restraints!","ColorFriendly"] call fnc_playerMessage;	//empty message
		_agent setCaptive false;
		_agent playAction 'PlayerRestrainOut';
		if (count _this > 2) then
		{
			null = (_this select 2) call player_addInventory;
		};
	};
	/*"dropItems"	addPublicVariableEventHandler
	{
		private["_agent"];
		_agent = _this select 1;
		_agent moveToHands objNull;
	};*/
	"playerWet"	addPublicVariableEventHandler
	{
		private["_agent"];
		_array = _this select 1;
		_agent = _array select 0;
		_state = _array select 1;
		if (_state) then
		{
			//[_agent,"You are getting wet",""] call fnc_playerMessage;	//empty message
			_agent setVariable ["gettingWet",true];
		}
		else
		{
			//[_agent,"You are no longer getting wet",""] call fnc_playerMessage;	//empty message
			_agent setVariable ["gettingWet",false];
		};
	};
	"writeNote" addPublicVariableEventHandler
	{
		_array = _this select 1;
		_paper = _array select 0;
		_text = _array select 1;		
		_color = _array select 2;
		_message = _paper getVariable ["message",""];
		
		//make the message
		if (((strlen _message) + (strlen _text)) < 250) then
		{
			_messageAdd = format["%3<BR/><BR/><t color='%2'>%1</t>",_text,_color,_message];	
			_paper setVariable ["message",_messageAdd];
		};
	};
	"authIn" addPublicVariableEventHandler
	{
		diag_log "... authIn event handler called ...";
		{
			statusChat ['... authIn event handler called ...',''];
		} forEach players;
/*
		_array = _this select 1;
		_id = _array select 2;
		diag_log format ["CLIENT %1 request to spawn %2",_id,_this];
		_id spawnForClient {statusChat ['testing 1 2 3','']};
			
		_charType = _array select 0;
		_charInv = _array select 1;
		_pos = [3590.96,8492.23,0]; //[2515.14,2632.52,0]
		
		//load data
		_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
		_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
		_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");
		
		_myTop = _top select (_charInv select 0);
		_myBottom = _bottom select (_charInv select 1);
		_myShoe = _shoe select (_charInv select 2);
		_mySkin = DZ_SkinsArray select _charType;
		
		_agent = createAgent [_mySkin,  _pos, [], 0, "NONE"];
		{null = _agent createInInventory _x} forEach [_myTop,_myBottom,_myShoe];
		_agent call init_newPlayer;
		call init_newBody;
*/
	};
};
