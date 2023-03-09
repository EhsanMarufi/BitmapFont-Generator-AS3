package egames.bitmapfontGenerator
{
	import flash.events.Event;
	
	public class BitmapFontGeneratorEvent extends Event
	{
		private var _bitmapFontGenerator:BitmapFontGenerator;
		private var _currentGlyphSetFont:GlyphSetFont;
		
		public function BitmapFontGeneratorEvent(
			type:String, 
			bitmapFontGenerator:BitmapFontGenerator,
			currentGlyphSetFont:GlyphSetFont,
			bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_bitmapFontGenerator = bitmapFontGenerator;
			_currentGlyphSetFont = currentGlyphSetFont;
		}
		
		public function get bitmapFontGenerator():BitmapFontGenerator { return _bitmapFontGenerator; }
		public function get currentGlyphSetFont():GlyphSetFont { return _currentGlyphSetFont; }
	}
}