package egames.bitmapfontGenerator
{
import egames.rbp.MaxRectsBinPack;
import egames.rbp.Rect;

import flash.display.BitmapData;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.text.TextFormat;

[Event(name="progress", type="egames.bitmapfontGenerator.BitmapFontGeneratorEvent")]
	[Event(name="glyphSetFontStarted", type="egames.bitmapfontGenerator.BitmapFontGeneratorEvent")]
	[Event(name="glyphSetFontCompleted", type="egames.bitmapfontGenerator.BitmapFontGeneratorEvent")]
	[Event(name="complete", type="egames.bitmapfontGenerator.BitmapFontGeneratorEvent")]
	
	/**
	 *TODO: DOCUMENTATIONS!!<br>
	 *TO PROMOTE: THE MODIFICATION METHODS SHOULD NOT WORK WHEN IT'S BEING DRAWING GLYPHS, UNLESS A
	 * 'stop()' method is called! 
	 */
	public class BitmapFontGenerator extends EventDispatcher
	{
		public static const PROGRESS:String = "progress";
		public static const GLYPHSETFONT_STARTED:String = "glyphSetFontStarted";
		public static const GLYPHSETFONT_COMPLETED:String = "glyphSetFontCompleted";
		
		/** The maximum allowed <code>draw()</code> operations per each frame.*/
		public static var drawLimit:uint = 5;//uint.MAX_VALUE;
		
		private var _stage:Stage;
		
		private var _spriteSheetWidth:uint;
		private var _spriteSheetHeight:uint;
		private var _arrRasterGlyphSheets:Vector.<RasterGlyphSheet>;
		private var _arrXMLs:Vector.<XML>;
		private var _arrMaxRectBinPacks:Vector.<MaxRectsBinPack>;
		
		private var _matrix1:Matrix, _matrix2:Matrix;
		
		private var _busyDrawing:Boolean = false;
		
		private var _drawQuality:String;
		
		private var _subTexturesGap:uint;
		
		private var _totalToDrawItems:uint;
		private var _totalFramesInserted:uint;
		private var _progress:Number = 0.0;

		private var _arrGlyphSetFonts:Vector.<GlyphSetFont>;
		
		private var _totalImageSheetsCount:uint = 0;

		private var _totalGlyphsCount2BeDrawn:uint;

		private var _totalGlyphsCountDrawn:uint;

		private var _currentGlyphSetFont:GlyphSetFont;

		private var _currentGlyphSetFontIndex:uint;

		private var _xmlPages:XML;

		private var _xmlCommon:XML;
		
		private var _xmlChars:XML;
		
		
		public function get XMLs():Vector.<XML> { return _arrXMLs; }

		private var _pageIDs:Vector.<uint>;

		

		private var _commonNodeNeedsToBeFilled:Boolean;
		public function get rasterGlyphSheets():Vector.<RasterGlyphSheet> { return _arrRasterGlyphSheets; }
		public function get maxRectBinPacks():Vector.<MaxRectsBinPack> { return _arrMaxRectBinPacks; }
		public function get progress():Number { return _progress; }
		public function get totalToDrawItems():uint { return _totalToDrawItems; }
		public function get totalFramesInserted():uint { return _totalFramesInserted; }
		
		public function BitmapFontGenerator(
			bitmapFontImageWidth:uint,
			bitmapFontImageHeight:uint,
			drawQuality:String = StageQuality.BEST,
			scaleFilters:Boolean = true,
			subTexturesGap:uint = 4,
			debugging:Boolean = true
		)
		{
			_arrGlyphSetFonts = new Vector.<GlyphSetFont>();
			
			_drawQuality = drawQuality;
			_subTexturesGap = subTexturesGap;
			
			_spriteSheetWidth = bitmapFontImageWidth;
			_spriteSheetHeight = bitmapFontImageHeight;
			
			_arrRasterGlyphSheets = new Vector.<RasterGlyphSheet>();
			_arrXMLs = new Vector.<XML>();
			_arrMaxRectBinPacks = new Vector.<MaxRectsBinPack>();
			
			
			addImageSheet();
			
			_matrix1 = new Matrix(1, 0,  0, 1, 0, 0);
			_matrix2 = new Matrix(0, 1, -1, 0, 0, 0); // rotated 90 degrees
		}
		
		public function addGlyphSetFont(obj:GlyphSetFont):void
		{
			_arrGlyphSetFonts.push(obj);
		}
		
		public function removeGlyphSetFont(obj:GlyphSetFont):void
		{
			for(var i:uint = _arrGlyphSetFonts.length - 1; i >= 0; --i)
			{
				if (_arrGlyphSetFonts[i] == obj)
				{
					_arrGlyphSetFonts.splice(i, 1);
					break;
				}
			}
		}
		
		private static var sSheetsCounter:uint = 0;
		
		private function addImageSheet():void 
		{
			_arrRasterGlyphSheets.push(
				new RasterGlyphSheet(
					(sSheetsCounter++) + "-" + (new Date()).time.toString(16),
					new BitmapData(_spriteSheetWidth, _spriteSheetHeight, true, 0)
				)
			);
			
			_arrMaxRectBinPacks.push(new MaxRectsBinPack(_spriteSheetWidth, _spriteSheetHeight));
			
			_totalImageSheetsCount++;
		}
		
		/**
		 * TODOCUMENT: mention that the character set will 'update()' automatically :)
		 * @param stage
		 * 
		 */
		public function beginBatchDraw(stage:Stage):void
		{
			_stage = stage;
			
			// Reset counters
			_totalGlyphsCount2BeDrawn = 0;
			_totalGlyphsCountDrawn = 0;
			_currentGlyphSetFont = null;
			_currentGlyphSetFontIndex = 0;
			
			// Update the character intervals
			const LEN:uint = _arrGlyphSetFonts.length;
			var currCharSet:IntegerIntervalsSet;
			for (var i:uint = 0; i < LEN; ++i)
			{
				currCharSet = _arrGlyphSetFonts[i].characters;
				currCharSet.update();
				_totalGlyphsCount2BeDrawn += currCharSet.valuesCount;
			}
			
			// Start only when there are things to do!
			if (LEN > 0)
			{
				// Begin drawing at the next frame-exit event!
				_stage.addEventListener(Event.EXIT_FRAME, onExitFrame);
			}
		}
		
		private function onExitFrame(e:Event):void 
		{
			if (!_busyDrawing)
			{
				draw();
				_progress = _totalGlyphsCountDrawn / _totalGlyphsCount2BeDrawn;
				dispatchEvent(new BitmapFontGeneratorEvent(PROGRESS, this, _currentGlyphSetFont));
			}
		}
		
		private function draw():void
		{
			_busyDrawing = true;
			for (var i:uint = 0; i < drawLimit; ++i)
			{
				if (_currentGlyphSetFont && _currentGlyphSetFont.characters.nextValueAvailable)
				{
					// A glyph is ready to get drawn
					drawGlyph(
						_currentGlyphSetFont.characters.getNextValue(), 
						_currentGlyphSetFont.textFormat
					);
					_totalGlyphsCountDrawn++;
				}
				else if (_currentGlyphSetFontIndex < _arrGlyphSetFonts.length)
				{
					if (_currentGlyphSetFont)
						dispatchEvent( new BitmapFontGeneratorEvent(GLYPHSETFONT_COMPLETED, this, _currentGlyphSetFont) );
					
					_currentGlyphSetFont = _arrGlyphSetFonts[ _currentGlyphSetFontIndex++ ];
					
					// Each GlyphSetFont has its own XML file (while may have shared spritesheet images)
					// TODO: ADD THE '<?xml version="1"?>' to the header!
					var xml:XML = new XML(<font></font>);
					_arrXMLs.push(xml);
					
					var info:XML = new XML(<info />);
					var tf:TextFormat = _currentGlyphSetFont.textFormat;
					info.@face = tf.font;
					info.@size = tf.size;
					info.@bold = tf.bold;
					info.@italic = tf.italic;
					info.@uincode = "1"; // It's always using unicode codepoints
					// Currently, both of the vertical- and horizontal-spacing are identical
					info.@spacing = _subTexturesGap+", "+_subTexturesGap;
                    info.@metaSize = _currentGlyphSetFont.metaSize;
					xml.appendChild(info);
					
					_commonNodeNeedsToBeFilled = true;
					_xmlCommon = new XML(<common />);
					xml.appendChild(_xmlCommon);
					
					_pageIDs = new Vector.<uint>();
					_xmlPages = new XML(<pages></pages>);
					xml.appendChild(_xmlPages);
					
					_xmlChars = new XML(<chars></chars>);
					xml.appendChild(_xmlChars);
					
					dispatchEvent(new BitmapFontGeneratorEvent(GLYPHSETFONT_STARTED, this, _currentGlyphSetFont)); 
				}
				else
				{
					// When there's no more objects to draw
					_stage.removeEventListener(Event.EXIT_FRAME, onExitFrame);
					
					// dispatch the complete event
					dispatchEvent(new BitmapFontGeneratorEvent(Event.COMPLETE, this, null));
					
					break;
				}
			}
			
			_busyDrawing = false;
		}
		
		
		private function drawGlyph(unicode:uint, textFormat:TextFormat):void 
		{
			var rasterGlyph:RasterGlyph = new RasterGlyph(String.fromCharCode(unicode), textFormat);
			
			var charXML:XML = new XML(<char />);
			if (rasterGlyph.bitmapData == null)
			{
				charXML.@id = unicode;
				charXML.@x = 0;
				charXML.@y = 0;
				charXML.@width = 0;
				charXML.@height = 0;
				charXML.@rotated = "false";
				charXML.@xoffset = rasterGlyph.xOffset;
				charXML.@yoffset = rasterGlyph.yOffset;
				charXML.@xadvance = rasterGlyph.xAdvance;
				charXML.@page = -1;
				charXML.@chnl = 15;
				
				_xmlChars.appendChild(charXML);
				
				return;
			}
			
			if (_commonNodeNeedsToBeFilled)
			{
				_xmlCommon.@lineHeight = rasterGlyph.lineHeight;
				_xmlCommon.@baseLine = rasterGlyph.ascent;
				_xmlCommon.@descent = rasterGlyph.descent;
			}
			
			var gap:uint = _subTexturesGap;
			var w:int = Math.round(rasterGlyph.bitmapData.width),
				h:int = Math.round(rasterGlyph.bitmapData.height);
			
			// The Full-Width (FW) & Full-Height (FH)
			const FW:uint = w + gap, FH:uint = h + gap;
			
			if ((FW > _spriteSheetWidth && FW > _spriteSheetHeight) ||
				(FH > _spriteSheetHeight && FH > _spriteSheetWidth))
			{
				// The required rectangular space is bigger than the specified size of spreadsheets 
				// and thus will not be fitted inside any one of them!
				trace("The input rectangle of (w: "+FW+", h:"+FH+") cannot be fitted inside any " +
					"rectangular bin of (w: "+_spriteSheetWidth+", h: "+_spriteSheetHeight+")");
				return;
			}
			
			var insertedRect:Rect, i:int;
			
			// Iterate through all the available atlases to find the first atlas that has the required
			// rectangular space available for the display object to be drawn on.
			for (i = 0; i < _totalImageSheetsCount; ++i)
			{
				insertedRect = _arrMaxRectBinPacks[i].insert(
					FW,
					FH,
					MaxRectsBinPack.FRCH_RectBestShortSideFit
				);
				
				// The first non-degenerate rectangle indicates the insertion was successful at finding
				// an appropriate location for the required space.
				if (insertedRect.height > 0)
					break;
			}
			
			// If the required space has not been found on any of the available spreadsheets, then
			// add an extra atlas and retry brand new!
			if (i == _totalImageSheetsCount)
			{
				addImageSheet();
				drawGlyph(unicode, textFormat);
				return;
			}
			
			var rasterGlyphSheet:RasterGlyphSheet = _arrRasterGlyphSheets[i];
			
			//xml = _arrXMLs[i];
			if (_pageIDs.indexOf(i) == -1)
			{
				_pageIDs.push(i);
				var newPageNode:XML = new XML(<page />);
				newPageNode.@id = i;
				newPageNode.@uniqueID = rasterGlyphSheet.uniqueID;
				_xmlPages.appendChild(newPageNode);
				_xmlPages.@count = _xmlPages.children().length();
			}
			
			insertedRect.width -= gap;
			insertedRect.height -= gap;
			
			// Check if the inserted rect is rotated
			var isRotated:Boolean = w != h 
				&& insertedRect.width  == h 
				&& insertedRect.height == w;
			
			var matrix:Matrix = getMatrix(
				isRotated,
				insertedRect.x + (isRotated ? rasterGlyph.bitmapData.height : 0),
				insertedRect.y
			);
			
			/*
			_currentItem.transformFilters(isRotated);
			
			if (_debugging) {
				_BBRectSprite.graphics.clear();
				_BBRectSprite.graphics.beginFill(isRotated ? 0xFFFF00 : 0x00FF00, 0.65);
				_BBRectSprite.graphics.drawRect(0, 0, insertedRect.width, insertedRect.height);
				_BBRectSprite.graphics.endFill();
				_matBB.tx = insertedRect.x;
				_matBB.ty = insertedRect.y;
				spriteSheet.draw(_BBRectSprite, _matBB);
			}
			*/
			
			// The main draw operation
			// TO-IMPROVE: if the rasterGlyph is not rotated, then a more performance friendly method
			// of 'copyPixels()' may be used to draw the rasterGlyph
			rasterGlyphSheet.bitmapData.drawWithQuality(
				rasterGlyph.bitmapData,
				matrix,
				null,  // colorTransform
				null,  // blendMode
				null,  // clipRect
				false, // smoothing
				_drawQuality
			);
			
			charXML.@id = unicode;
			charXML.@x = insertedRect.x;
			charXML.@y = insertedRect.y;
			charXML.@width = insertedRect.width;
			charXML.@height = insertedRect.height;
			// TO-IMPROVE: "0" & "1", or; "true" & "false"? Seems like, the the "0"s and "1"s are more efficient!
			charXML.@rotated = isRotated ? "true" : "false";
			charXML.@xoffset = rasterGlyph.xOffset;
			charXML.@yoffset = rasterGlyph.yOffset;
			charXML.@xadvance = rasterGlyph.xAdvance;
			charXML.@page = i;
			charXML.@chnl = 15;
			
			_xmlChars.appendChild(charXML);
		}
		
		private function getMatrix(isRotated90Degrees:Boolean, tx:int, ty:int):Matrix
		{
			var matrix:Matrix = isRotated90Degrees ? _matrix2 : _matrix1;
			matrix.tx = tx;
			matrix.ty = ty;
			return matrix;
		}
		

	}
}