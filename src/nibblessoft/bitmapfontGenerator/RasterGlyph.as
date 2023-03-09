package nibblessoft.bitmapfontGenerator
{
import nibblessoft.Game;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;

public class RasterGlyph
	{
		private var _char:String;
		private var _textFormat:TextFormat;
		private var _bitmapData:BitmapData;
		private var _xOffset:Number, _yOffset:Number,
					_xAdvance:Number, _lineHeight:Number,
					_ascent:Number, _descent:Number;
		
		
		public function RasterGlyph(character:String, textFormat:TextFormat)
		{
			_textFormat = textFormat;
			this.character = character;
		}
		
		/** The rasterized bitmap data that only encompasses the outline of the glyph, no extra white space is included.
		  * The values of <code>xOffset</code>, <code>yOffset</code> determine the exact coordinate of the rasterized 
		  * glyph relative to the top-left corner of the character boundaries. The width of the rasterized glyph is usually
		  * different from the width of the character. To get the 'width' of the character, use the property of the 
		  * <code>xAdvance</code>.
		  */
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		/** A horizontal offset amount to exactly coincident the rasterized glyph on to the character's outline.*/
		public function get xOffset()   :Number     { return _xOffset;    }
		
		/** A vertical offset amount to exactly coincident the rasterized glyph on to the character's outline.*/
		public function get yOffset()   :Number     { return _yOffset;    }
		
		/** The width of the character that will be used to advance the horizontal position to get reached to 
		  * the next character in a text line.
		  */
		public function get xAdvance()  :Number     { return _xAdvance;   }
		
		/** The height of a single text line in pixels*/
		public function get lineHeight():Number     { return _lineHeight; }
		
		/** The length from the baseline to the top of the text line height, in pixels.*/
		public function get ascent()    :Number     { return _ascent;     }
		
		/** The length from the baseline to the bottom depth of the text line, in pixels.*/
		public function get descent()   :Number     { return _descent;    }
		
		public function get textFormat():TextFormat { return _textFormat; }
		public function set textFormat(tf:TextFormat):void 
		{
			_textFormat = tf;
			
			// force update
			character = _char;
		}
		
		public function get character() :String { return _char; }
		public function set character(char: String): void
		{
			var textField: TextField = new TextField();
			textField.embedFonts = true;
			textField.defaultTextFormat = _textFormat;

			// Only one character is allowed, so choose the first character
			textField.text = _char = char.charAt(0);
			textField.autoSize = TextFieldAutoSize.LEFT;

			var charBoundaries: Rectangle = textField.getCharBoundaries(0);
			var lineMetrics: TextLineMetrics = textField.getLineMetrics(0);

			// Insert the sprite into an Sprite to be able to extract the outline data of the glyph
			// to reproduce the outline on another Sprite to get the outline boundaries of the glyph.
			var sp0: Sprite = new Sprite();
			sp0.addChild(textField); 
			
			// Due to a strange bug in AIR (currently on v28), for some specific characters, e.g: 0xFEB1,
			// the AIR app crashes! unless the container is on the stage!
			Game.instance.stage.addChild(sp0);
			
			var sp1: Sprite = new Sprite();
			sp1.graphics.drawGraphicsData( sp0.graphics.readGraphicsData(true) );
			
			// Remove the container added onto the stage, due to the aforementioned bug
			Game.instance.stage.removeChild(sp0);

			var glyphBounds: Rectangle = sp1.getBounds(null);

			// I don't know why the boundaries of the graphics data extracted from the text field
			// is five times smaller than the boundaries of the very same text field!
			var s: Number = 5;
			glyphBounds.x *= s;
			glyphBounds.y *= s;
			glyphBounds.width = Math.ceil(glyphBounds.width *= s);
			glyphBounds.height = Math.ceil(glyphBounds.height *= s);


			_xOffset = glyphBounds.left;
			_yOffset = glyphBounds.top;
			_xAdvance = lineMetrics.width;
			_lineHeight = lineMetrics.height;
			_ascent = lineMetrics.ascent;
			_descent = lineMetrics.descent;
			
			if (glyphBounds.width == 0 || glyphBounds.height == 0)
				return;
			
			_bitmapData = new BitmapData(
				glyphBounds.width,
				glyphBounds.height,
				true, // transparent
				0 // fill color
			);
			
			// The textField does have a gutter of two pixels around the boundaries of the character, but
			// the translation amounts to be embeded in the following matrix, the 'tx' and 'ty', will have 
			// a 'relative' affect on the transformatin, that will also componsate the gutters.
			var matrix: Matrix = new Matrix(
				1, 0, 0, 1, // a, b, c, d -- intact
				-glyphBounds.left, // tx
				-glyphBounds.top // ty
			);

			_bitmapData.draw(
				textField, // source
				matrix, // matrix
				null, // colorTransform
				null, // blendMode
				null, // clipRect
				true // smoothing
			);
		}
	}
}