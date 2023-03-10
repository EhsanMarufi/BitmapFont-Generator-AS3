# BitmapFont Generator ActionScript3
A powerful and flexible API to generate Bitmap Fonts

![BitmapFont Generator ActionScript3](bitmap-font-generator.gif)

A bitmap font is one that stores each glyph as an array of pixels (that is, a bitmap). It is less commonly known as a raster font or a pixel font. Bitmap fonts are simply collections of raster images of glyphs. For each variant of the font, there is a complete set of glyph images, with each set containing an image for each character. For example, if a font has three sizes, and any combination of bold and italic, then there must be 12 complete sets of images. The ActionScript BitmapFont Generator API provides a convinient and flexable facility to create such images. 
The font generator API also have some utilities to ease the integration with the [Starling Framework](https://github.com/Gamua/Starling-Framework) (e.g. `RasterGlyphSheet` & `BitmapFontPreparator`). Also, some handy Unicode Intervals are provided to be used as a base to integrate your custome character ranges. The API is dependent upon [Rectangle Bin Pack](https://github.com/EhsanMarufi/Rectangle-Bin-Pack-AS3) (just another nibblesSoft package).

Additionally, the repository includes a sample BitmapFont generated only from capital letters (A to Z) and numbers (0-9) using this API, demonstrating an optimal method for character arrangement:

![BitmapFont Generator ActionScript3](sample/ArialBold_AZ09.png)

```xml
<?xml version="1.0"?>
<font>
  <info face="Arial" size="30" bold="1" italic="0" charset="" unicode="1" stretchH="100" smooth="1" aa="1" padding="0,0,0,0" spacing="1,1" outline="0"/>
  <common lineHeight="30" base="24" scaleW="128" scaleH="128" pages="1" packed="0" alphaChnl="0" redChnl="4" greenChnl="4" blueChnl="4"/>
  <pages>
    <page id="0" file="ArialBold_AZ09.png" />
  </pages>
  <chars count="37">
    <char id="-1" x="99" y="76" width="15" height="16" xoffset="2" yoffset="8" xadvance="19" page="0" chnl="15" />
    <char id="48" x="45" y="77" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="49" x="88" y="76" width="10" height="18" xoffset="1" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="50" x="0" y="77" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="51" x="107" y="57" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="52" x="92" y="57" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="53" x="77" y="57" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="54" x="62" y="57" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="55" x="47" y="58" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="56" x="32" y="58" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="57" x="30" y="77" width="14" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="65" x="105" y="0" width="18" height="18" xoffset="-1" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="66" x="37" y="19" width="17" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="67" x="55" y="19" width="17" height="18" xoffset="0" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="68" x="73" y="19" width="17" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="69" x="103" y="38" width="16" height="18" xoffset="1" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="70" x="74" y="76" width="13" height="18" xoffset="1" yoffset="6" xadvance="15" page="0" chnl="15" />
    <char id="71" x="0" y="20" width="18" height="18" xoffset="0" yoffset="6" xadvance="19" page="0" chnl="15" />
    <char id="72" x="18" y="39" width="16" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="73" x="120" y="38" width="5" height="18" xoffset="1" yoffset="6" xadvance="7" page="0" chnl="15" />
    <char id="74" x="60" y="77" width="13" height="18" xoffset="0" yoffset="6" xadvance="14" page="0" chnl="15" />
    <char id="75" x="91" y="19" width="17" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="76" x="15" y="77" width="14" height="18" xoffset="1" yoffset="6" xadvance="15" page="0" chnl="15" />
    <char id="77" x="66" y="0" width="19" height="18" xoffset="1" yoffset="6" xadvance="21" page="0" chnl="15" />
    <char id="78" x="86" y="38" width="16" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="79" x="46" y="0" width="19" height="18" xoffset="0" yoffset="6" xadvance="19" page="0" chnl="15" />
    <char id="80" x="69" y="38" width="16" height="18" xoffset="1" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="81" x="0" y="0" width="19" height="19" xoffset="0" yoffset="6" xadvance="19" page="0" chnl="15" />
    <char id="82" x="19" y="20" width="17" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="83" x="52" y="38" width="16" height="18" xoffset="0" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="84" x="0" y="58" width="15" height="18" xoffset="1" yoffset="6" xadvance="15" page="0" chnl="15" />
    <char id="85" x="35" y="39" width="16" height="18" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
    <char id="86" x="86" y="0" width="18" height="18" xoffset="-1" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="87" x="20" y="0" width="25" height="18" xoffset="-1" yoffset="6" xadvance="23" page="0" chnl="15" />
    <char id="88" x="109" y="19" width="17" height="18" xoffset="0" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="89" x="0" y="39" width="17" height="18" xoffset="0" yoffset="6" xadvance="17" page="0" chnl="15" />
    <char id="90" x="16" y="58" width="15" height="18" xoffset="-1" yoffset="6" xadvance="14" page="0" chnl="15" />
  </chars>
  <kernings count="16">
    <kerning first="89" second="65" amount="-2" />
    <kerning first="87" second="65" amount="-1" />
    <kerning first="86" second="65" amount="-2" />
    <kerning first="84" second="65" amount="-2" />
    <kerning first="82" second="89" amount="-1" />
    <kerning first="80" second="65" amount="-2" />
    <kerning first="76" second="89" amount="-2" />
    <kerning first="76" second="87" amount="-1" />
    <kerning first="49" second="49" amount="-1" />
    <kerning first="76" second="86" amount="-2" />
    <kerning first="65" second="84" amount="-2" />
    <kerning first="65" second="86" amount="-2" />
    <kerning first="65" second="87" amount="-1" />
    <kerning first="65" second="89" amount="-2" />
    <kerning first="76" second="84" amount="-2" />
    <kerning first="70" second="65" amount="-1" />
  </kernings>
</font>
```

A GlyphInspector UI is also provided with the repository to help with the details on each glyph.

All the code is released to Public Domain. Patches and comments are welcome.
It makes me happy to hear if someone finds the algorithms and the implementations useful.

Ehsan Marufi<br />
<sup>December 2016</sup>