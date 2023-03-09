package egames.bitmapfontGenerator
{
	import flash.text.TextFormat;

	/**
	 * Corresponds a set of glyphs to a font style.
	 * @author Ehsan
	 * 
	 */
	public class GlyphSetFont
	{
		private var _textFormat:TextFormat;
		private var _allCharacters:IntegerIntervalsSet;
		private var _metaSize:Number;
		
		public function GlyphSetFont(textFormat:TextFormat, metaSize:Number)
		{
			_textFormat = textFormat;
			_allCharacters = new IntegerIntervalsSet();
			_metaSize = metaSize;
		}
		
		public function get textFormat():TextFormat { return _textFormat; } 
		public function get characters():IntegerIntervalsSet { return _allCharacters; }
		public function get metaSize():Number { return _metaSize; }
	}
}