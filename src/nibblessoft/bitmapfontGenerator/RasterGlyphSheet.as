package egames.bitmapfontGenerator
{
	import flash.display.BitmapData;
	
	import starling.textures.Texture;

	public class RasterGlyphSheet
	{
		private var _uniqueID:String;
		private var _bitmapData:BitmapData;
		private var _texture:Texture;
		
		public function RasterGlyphSheet(uniqueID:String, bitmapData:BitmapData)
		{
			_uniqueID = uniqueID;
			_bitmapData = bitmapData;
		}
		
		public function get uniqueID():String { return _uniqueID; }
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		public function get texture():Texture { return _texture; }
		
		public function genTextureFromBitmapData(
			generateMipMaps:Boolean=false,
			optimizeForRenderToTexture:Boolean=false,
			scale:Number=1, format:String="bgra",
			forcePotTexture:Boolean=false,
			async:Function=null):void
		{
			if (_texture == null)
			{
				_texture = Texture.fromBitmapData(
					_bitmapData,
					generateMipMaps,
					optimizeForRenderToTexture,
					scale,
					format,
					forcePotTexture,
					async
				);
			}
		}
		
		public function disposeBitmapData():void
		{
			if (_bitmapData)
			{
				_bitmapData.dispose();
				_bitmapData = null;
			}
		}
		
		public function disposeTexture():void
		{
			if (_texture)
			{
				_texture.dispose();
				_texture = null;
			}
		}
	}
}