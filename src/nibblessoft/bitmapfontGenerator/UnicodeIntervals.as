package egames.bitmapfontGenerator
{
	public class UnicodeIntervals
	{
		public static const ArabicScripts:IntegerIntervalsSet = 
			(new IntegerIntervalsSet())
			// The full Arabic script in Unicode is contained in the following blocks:
				.addInterval(0x0600, 0x06FF) // Arabic: 255 characters
				.addInterval(0x0750, 0x077F) // Arabic Supplement: 48 characters
				.addInterval(0x08A0, 0x08FF) // Arabic Extended-A: 73 characters
				.addInterval(0x0750, 0x077F) // Arabic Presentation Forms-A: 611 characters
				.addInterval(0xFB50, 0xFDFF) // Arabic Presentation Forms-B: 141 characters
				.addInterval(0xFE70, 0xFEFF);// Rumi Numeral Symbols: 31 characters
				//.addInterval(0x1EE00, 0x1EEFF);// Arabic Mathematical Alphabetic Symbols: 143 characters

        /**
         * Basic Latin
         * 128 codePoints (0x00-0x7F):
         * Latin (52 characters), Common (76 characters)
         */
		public static const BasicLatin:IntegerIntervalsSet = (new IntegerIntervalsSet()).addInterval(0x0000, 0x007F);

        /**
         * Latin-1 Supplement
         * 128 codePoints (0x80-0xFF):
         * Latin (64 characters), Common (64 characters)
         */
        public static const Latin1Supplement:IntegerIntervalsSet = (new IntegerIntervalsSet()).addInterval(0x0080, 0x00FF);

        /**
         * Latin Extended-A
         * 128 codePoints (0x100-0x17F):
         * Latin
         */
        public static const LatinExtendedA:IntegerIntervalsSet = (new IntegerIntervalsSet()).addInterval(0x0100, 0x017F);

        /**
         * Latin Extended-B
         * 128 codePoints (0x180-0x24F):
         * Latin
         */
        public static const LatinExtendedB:IntegerIntervalsSet = (new IntegerIntervalsSet()).addInterval(0x0180, 0x024F);



		// To complete other language scripts, use 'https://en.wikipedia.org/wiki/Unicode_block'
		
		public function UnicodeIntervals()
		{
		}
	}
}