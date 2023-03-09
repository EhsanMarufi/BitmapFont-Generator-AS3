package nibblessoft.bitmapfontGenerator {
import com.adobe.images.PNGEncoder;

import nibblessoft.exBitmapFont.ExBitmapFont;
import nibblessoft.gravity.Scaler;
import nibblessoft.gravity.assets.Fonts;
import nibblessoft.gravity.assets.VectorFontPool;

import flash.display.Bitmap;

import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import starling.text.TextField;
import starling.text.TextFormat;

public class BitmapFontPreparator {
    /** The data will be stored and retrieved to/from the typical storage-device of the machine. */
    public static const DATA_RESIDENCY_STORAGE:uint = 1;

    /** The data will be stored and retrieved to/from a database. */
    public static const DATA_RESIDENCY_DATABASE:uint = 2;

    private var _dataResidency:uint;

    public function BitmapFontPreparator(dataResidency:uint) {
        _dataResidency = dataResidency;
    }

    public function generateBitmapFonts():BitmapFontGenerator {
        const BITMAP_SIZE:uint = 2048;
        VectorFontPool.loadFonts();
        var bitmapFontGenerator:BitmapFontGenerator = new BitmapFontGenerator(
                BITMAP_SIZE,
                BITMAP_SIZE
        );

        var gameScaleFactor:Number = Scaler.gameScaleFactor;
        var arrTypeFaces:Array = [
            Fonts.TYPEFACE_SEGAON_HEAVY,
            Fonts.TYPEFACE_SEGAON_HEAVY_ITALIC
        ];

        var arrSizes:Array = [
            // index #0: Sizes for 'Fonts.TYPEFACE_SEGAON_HEAVY' (which is at index 0)
            [Fonts.FONTSIZE_12, Fonts.FONTSIZE_14, Fonts.FONTSIZE_18, Fonts.FONTSIZE_24, Fonts.FONTSIZE_26, Fonts.FONTSIZE_28],

            // index #1: Sizes for 'Fonts.TYPEFACE_SEGAON_HEAVY_ITALIC' (which is at index 1)
            [Fonts.FONTSIZE_12, Fonts.FONTSIZE_14, Fonts.FONTSIZE_18, Fonts.FONTSIZE_24, Fonts.FONTSIZE_36]
        ];

        for (var j:uint = 0; j < arrTypeFaces.length; ++j) {
            var typeFace:String = arrTypeFaces[j];
            var arrCurrentTypeFaceSizes:Array = arrSizes[j];

            for (var k:uint = 0; k < arrCurrentTypeFaceSizes.length; ++k) {
                var fontSize:int = parseInt(arrCurrentTypeFaceSizes[k]);
                var glyphSetFont:GlyphSetFont = new GlyphSetFont(
                        new flash.text.TextFormat(
                                VectorFontPool.getFont(typeFace).fontName,
                                fontSize * gameScaleFactor, // the size used for the generated bitmaps
                                0xFFFFFF // a white color is used for the generated bitmaps
                        ),
                        fontSize
                );

                glyphSetFont.characters.addIntervalSet(UnicodeIntervals.BasicLatin);
                glyphSetFont.characters.addIntervalSet(UnicodeIntervals.Latin1Supplement);
//                glyphSetFont.characters.addIntervalSet(UnicodeIntervals.ArabicScripts);
                bitmapFontGenerator.addGlyphSetFont(glyphSetFont);
            }
        }

        return bitmapFontGenerator;
    }

    public function registerFontsFromGenerator(bitmapFontGenerator:BitmapFontGenerator):Dictionary {
        return registerFonts(bitmapFontGenerator.XMLs, bitmapFontGenerator.rasterGlyphSheets);
    }

    private function registerFonts(XMLs:Vector.<XML>, rasterGlyphSheets:Vector.<RasterGlyphSheet>):Dictionary {
        var dicFormats:Dictionary = new Dictionary();
        var XMLsCount:uint = XMLs.length;

        for (var i:uint = 0; i < XMLsCount; ++i) {
            var xml:XML = XMLs[i];
            var fontMetaSize:int = parseInt(xml.info.@metaSize);

            var fnt:ExBitmapFont = new ExBitmapFont(
                    xml,
                    rasterGlyphSheets
            );

            var fontName:String = fnt.name + "_" + fontMetaSize.toString();
            TextField.registerCompositor(fnt, fontName);

            var fmt:starling.text.TextFormat = new starling.text.TextFormat(fontName, -1, 0);
            if (!dicFormats[fnt.name])
                dicFormats[fnt.name] = new Dictionary();

            dicFormats[fnt.name][fontMetaSize] = fmt;
        }

        return dicFormats;
    }

    public function saveInStorage(bitmapFontGenerator:BitmapFontGenerator, destinationDirectoryPath:String):void {
        var i:uint;
        var byteArray:ByteArray;
        var fs:FileStream = new FileStream();

        var spriteSheetsCount:uint = bitmapFontGenerator.rasterGlyphSheets.length;
        for (i = 0; i < spriteSheetsCount; ++i) {
            var rasterGlyphSheet:RasterGlyphSheet = bitmapFontGenerator.rasterGlyphSheets[i];
            byteArray = PNGEncoder.encode(rasterGlyphSheet.bitmapData);
            var pngFile:File = new File(destinationDirectoryPath + rasterGlyphSheet.uniqueID + ".png"); // "spritesheet-" + i
            fs.open(pngFile, FileMode.WRITE);
            fs.writeBytes(byteArray);
            fs.close();
        }

        var XMLsCount:uint = bitmapFontGenerator.XMLs.length;
        for (i = 0; i < XMLsCount; ++i) {
            var xmlFile:File = new File(destinationDirectoryPath + "xml-" + i + ".xml");
            fs.open(xmlFile, FileMode.WRITE);
            fs.writeUTFBytes(bitmapFontGenerator.XMLs[i]);
            fs.close();
        }
    }

    private var _busyLoadingBitmapFont:Boolean = false;
    private var _imageFilesCountToBeLoaded:int = 0;
    private var _imageFilesCountLoaded:int = 0;
    private var _bitmapFontsLoadingProgressCallback:Function;
    private var _bitmapFontsLoadingCompleteCallback:Function;

    private var _retrievedXMLs:Vector.<XML>;
    private var _rasterGlyphSheets:Vector.<RasterGlyphSheet>;

    public function retrieveFromStorage(directoryPath:String, onProgressCallback:Function, onCompleteCallback:Function):void {
        if (_busyLoadingBitmapFont)
            return;

        _bitmapFontsLoadingProgressCallback = onProgressCallback;
        _bitmapFontsLoadingCompleteCallback = onCompleteCallback;

        _retrievedXMLs = new Vector.<XML>();
        _rasterGlyphSheets = new Vector.<RasterGlyphSheet>();

        var directory:File = new File(directoryPath);
        var files:Array = directory.getDirectoryListing();
        var filesCount:uint = files.length;

        var fs:FileStream = new FileStream();
        var uniquePages:Dictionary = new Dictionary();

        var i:uint;
        for (i = 0; i < filesCount; ++i) {
            var currentFile:File = files[i];
            if (currentFile.extension == "xml") {
                fs.open(currentFile, FileMode.READ);
                var xml:XML = new XML(fs.readUTFBytes(fs.bytesAvailable));

                for each (var pageNode:XML in xml.pages.page) {
                    var unqID:String = pageNode.@uniqueID;
                    uniquePages[unqID] = true;
                }

                _retrievedXMLs.push(xml);
                fs.close();
            }
        }

        // load the rasterGlyphSheets
        var imageFile:File;
        var imageFiles:Vector.<File> = new Vector.<File>();

        for (var pageUniqueID:String in uniquePages) {
            imageFile = new File(directoryPath + "\\" + pageUniqueID + ".png");
            if (!imageFile.exists)
                continue;
            imageFiles.push(imageFile);
        }

        _imageFilesCountToBeLoaded = imageFiles.length;
        _imageFilesCountLoaded = 0;

        for (i = 0; i < _imageFilesCountToBeLoaded; ++i) {
            imageFile = imageFiles[i];
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageFileLoaded);
            loader.load(new URLRequest(imageFile.url));
        }
    }

    private function onImageFileLoaded(e:Event):void {
        function getFileName(url:String):String {
            return new File(url).name;
        }
        var loaderInfo:LoaderInfo = e.target as LoaderInfo;
        var bmp:Bitmap = loaderInfo.content as Bitmap;
        _imageFilesCountLoaded++;
        var fileName:String = getFileName(loaderInfo.url);
        var uniqueID:String = fileName.substring(0, fileName.lastIndexOf("."));
        var rasterGlyphSheet:RasterGlyphSheet = new RasterGlyphSheet(uniqueID, bmp.bitmapData);
        _rasterGlyphSheets.push(rasterGlyphSheet);

        _bitmapFontsLoadingProgressCallback(_imageFilesCountLoaded / _imageFilesCountToBeLoaded);

        if (_imageFilesCountLoaded == _imageFilesCountToBeLoaded) {
            _busyLoadingBitmapFont = false;
            _bitmapFontsLoadingCompleteCallback(registerFonts(_retrievedXMLs, _rasterGlyphSheets));
        }
    }
}
}
