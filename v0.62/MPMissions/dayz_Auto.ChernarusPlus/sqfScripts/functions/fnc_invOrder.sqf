private["_inv","_arrSizes","_sizeLow","_sizeMed","_sizeHigh","_return"];

_inv = _this; 
_arrSizes = [];
_return = [];
_sizeLow = [];
_sizeMed = [];
_sizeHigh = [];

{
	
	_itemSize = (_x select 0) call fnc_getItemSize;
	
	if !( count _itemSize <= 0 ) then 
	{
		_itemSize = (_itemSize select 0) * (_itemSize select 1);
	} else {
		_itemSize = 1;
	};
			
	_arrSizes set [ (count _arrSizes), [_itemSize,_forEachIndex] ];
		
} forEach _inv;



if ( typeName _arrSizes == "ARRAY" ) then 
{
	if !( count _arrSizes <= 0 ) then 
	{ 
		{
			_size = _x select 0;
			_index = _x select 1;
							
			if ( _size >  1 ) then 
			{
				_sizeHigh set [ (count _sizeHigh), _inv select _index];
			} else {
				_sizeLow set [ (count _sizeLow), _inv select _index];
			};
				
		} forEach _arrSizes;
									
		_return =  _sizeHigh + _sizeLow;
	};			
};			

_return
