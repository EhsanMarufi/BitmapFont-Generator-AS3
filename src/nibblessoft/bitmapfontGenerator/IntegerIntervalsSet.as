package egames.bitmapfontGenerator
{
	// TODO: Document the class: The class only supports the Proper and bounded integer intervals
	// Currently, only Closed intervals are accepted, improve to support other types of intervals:
	// Open, Left-closed, right-open, Left-open, right-closed
	// https://en.wikipedia.org/wiki/Interval_(mathematics)#Integer_intervals
	public class IntegerIntervalsSet
	{
		private var _arrIncludeIntervals:Vector.<IntegerInterval>;
		private var _arrExcludeIntervals:Vector.<IntegerInterval>;
		private var _intervalsCount:uint = 0;
		private var _valuesCount:uint = 0;
		private var _requiresUpdate:Boolean = false;
		
		private var _intervalsSetIndex:uint, _currentIntervalIndex:uint, _valuesReadCount:uint; 
		
		public function IntegerIntervalsSet()
		{
			_arrIncludeIntervals = new Vector.<IntegerInterval>();
			_arrExcludeIntervals = new Vector.<IntegerInterval>();
		}
		
		public function addIntervalSet(intervalSet:IntegerIntervalsSet):IntegerIntervalsSet
		{
			intervalSet.update();
			
			const LEN:uint = intervalSet._arrIncludeIntervals.length;
			for (var i:uint = 0; i<LEN; ++i)
				_arrIncludeIntervals.push( intervalSet._arrIncludeIntervals[i] );
			
			_requiresUpdate = true;
			return this;
		}
		
		public function addInterval(lower:uint, upper:uint):IntegerIntervalsSet
		{
			_arrIncludeIntervals.push(new IntegerInterval(lower, upper));
			_requiresUpdate = true;
			return this;
		}
		
		public function addSingleValue(value:uint):IntegerIntervalsSet
		{
			return addInterval(value, value);
		}
		
		
		public function excludeIntervalSet(intervalSet:IntegerIntervalsSet):IntegerIntervalsSet
		{
			intervalSet.update();
			
			const LEN:uint = intervalSet._arrIncludeIntervals.length;
			for (var i:uint = 0; i<LEN; ++i)
				_arrExcludeIntervals.push( intervalSet._arrIncludeIntervals[i] );
			
			_requiresUpdate = true;
			return this;
		}
		
		public function exclueInterval(lower:uint, upper:uint):IntegerIntervalsSet
		{
			_arrExcludeIntervals.push(new IntegerInterval(lower, upper));
			_requiresUpdate = true;
			return this;
		}
		
		public function exclueSingleValue(value:uint):IntegerIntervalsSet
		{
			return exclueInterval(value, value);
		}
		
		public function get intervalsCount():uint
		{
			return _intervalsCount;
		}
		
		public function get valuesCount():uint
		{
			return _valuesCount;
		}
		
		// TODO: SEEMS REDUNDANT!
		public function get valuesReadCount():uint
		{
			return _valuesReadCount;
		}
		
		public function get nextValueAvailable():Boolean
		{
			return _valuesReadCount < _valuesCount;
		}
		
		public function getNextValue():uint
		{
			if (_currentIntervalIndex >= _arrIncludeIntervals[_intervalsSetIndex].width)
			{
				_intervalsSetIndex++;
				_currentIntervalIndex = 0;
			}
			
			if (_intervalsSetIndex >= _intervalsCount)
			{
				_intervalsSetIndex = _intervalsCount-1;
				_currentIntervalIndex = _arrIncludeIntervals[_intervalsSetIndex].width()-1;
			}
			else
				_valuesReadCount++;
			
			
			return _arrIncludeIntervals[_intervalsSetIndex].getValue(_currentIntervalIndex++);
		}
		
		public function resetTraverseParameters():void
		{
			_valuesReadCount = 0;
			_intervalsSetIndex = 0;
			_currentIntervalIndex = 0;
		}
		
		/**
		 * TODO: Document! <br>
		 * The method carries on only when the object is invalidated (i.e: has not already been updated),
		 * to avoid any redundant re-updating. 
		 */
		public function update():void
		{
			if (!_requiresUpdate)
				return;
			
			resetTraverseParameters();
			
			mergeOverlappingIntervals(_arrIncludeIntervals);
			mergeOverlappingIntervals(_arrExcludeIntervals);
			
			// To apply the excluded intervals, a 'sweep line algorithm' is being used.
			// Let's consider the lower and upper bounds of the intervals to be event points,
			// or 'points' for short.
			// The 'points' will be put in a priority 'queue'. The algorithm moves from 
			// left to right, and stops at every 'point', and updates the current status 
			// according to that point.
			
			// First, annotate all points and put them in a list
			const INCLUDE_INTERVALS_COUNT:uint = _arrIncludeIntervals.length;
			const EXCLUDE_INTERVALS_COUNT:uint = _arrExcludeIntervals.length;
			const QUEUE_LEN:uint = 2*INCLUDE_INTERVALS_COUNT + 2*EXCLUDE_INTERVALS_COUNT;
			var queue:Vector.<AnnotatedPoint> = new Vector.<AnnotatedPoint>(QUEUE_LEN);
			var i:uint, queueIndex:uint = 0;
			for (i=0; i<INCLUDE_INTERVALS_COUNT; ++i)
			{
				queue[queueIndex++] = new AnnotatedPoint(_arrIncludeIntervals[i].lower, AnnotatedPoint.PointType_Start);
				queue[queueIndex++] = new AnnotatedPoint(_arrIncludeIntervals[i].upper, AnnotatedPoint.PointType_End);
			}
			
			for (i=0; i<EXCLUDE_INTERVALS_COUNT; ++i)
			{
				queue[queueIndex++] = new AnnotatedPoint(_arrExcludeIntervals[i].lower, AnnotatedPoint.PointType_GapStart);
				queue[queueIndex++] = new AnnotatedPoint(_arrExcludeIntervals[i].upper, AnnotatedPoint.PointType_GapEnd);
			}
			
			// sort the queue
			queue.sort(AnnotatedPoint.compareFn);
			
			// Do the actuall sweep
			var result:Vector.<IntegerInterval> = new Vector.<IntegerInterval>();

	        // iterate over the queue       
	        var isInterval:Boolean = false; // isInterval: #Start seen > #End seen
	        var isGap:Boolean = false;      // isGap:      #GapStart seen > #GapEnd seen
	        var intervalStart:int = 0;
			var point:AnnotatedPoint;
	        for (i=0; i<QUEUE_LEN; ++i)
			{
				point = queue[i];
	            switch (point.type)
				{
		            case AnnotatedPoint.PointType_Start:
		                if (!isGap)
		                    intervalStart = point.value;
		                isInterval = true;
		                break;
					
		            case AnnotatedPoint.PointType_End:
		                if (!isGap)                   
		                    result.push(new IntegerInterval(intervalStart, point.value));
		                isInterval = false;
		                break;
					
		            case AnnotatedPoint.PointType_GapStart:
		                if (isInterval)     
		                    result.push(new IntegerInterval(intervalStart, point.value-1));
		                isGap = true;
		                break;
					
		            case AnnotatedPoint.PointType_GapEnd:
		                if (isInterval)
		                    intervalStart = point.value+1;
		                isGap = false;
		                break;
	            }
	        }
	
	        _arrIncludeIntervals = result;
			_intervalsCount = _arrIncludeIntervals.length;
			
			_valuesCount = 0;
			for (i=0; i<_intervalsCount; ++i)
				_valuesCount += _arrIncludeIntervals[i].width;
			
			// The 'excluded intervals' should now be discarded
			_arrExcludeIntervals = new Vector.<IntegerInterval>();
			
			_requiresUpdate = false;
		}
		
		private function mergeOverlappingIntervals(arr:Vector.<IntegerInterval>):void
		{
			// The method uses an efficient approach to do the task. It first, sorts the intervals 
			// according to the 'start' value of the Intervals. Once the intervals get sorted, all 
			// the intervals can be combined in a linear traversal. The idea is, in sorted array of
			// intervals, if 'interval[i]' doesn’t overlap with 'interval[i-1]', then 'interval[i+1]'
			// cannot overlap with 'interval[i-1]'; because the 'starting' of 'interval[i+1]' must 
			// be greater than or equal to interval[i].
			
			// Sort Intervals in decreasing order of 'start'
			arr.sort(IntegerInterval.compareFnDesc);
			
			var index:uint = 0, len:uint = arr.length;
			
			// Traverse all input Intervals
			for (var i:uint = 0; i<len; i++)
			{
				// If this is not first Interval and overlaps with the previous one
				if (index != 0 && arr[index-1].lower <= arr[i].upper)
				{
					while (index != 0 && arr[index-1].lower <= arr[i].upper)
					{
						// Merge previous and current Intervals
						arr[index-1].reset( 
							Math.min(arr[index-1].lower, arr[i].lower), // lower
							Math.max(arr[index-1].upper, arr[i].upper)  // upper
						);
						index--;
					}
				}
				else
					// Doesn't overlap with previous, add to solution
					arr[index] = arr[i];
				
				index++;
			}
			
			// Delete the redundant Intervals
			arr.splice(index, arr.length - index);
		}
	}
}

internal class IntegerInterval
{
	private var _lower:uint, _upper:uint;
	private var _width:uint;
	
	public function IntegerInterval(lower:uint, uppper:uint)
	{
		reset(lower, uppper);
	}
	
	/** The lower bound of the Interval.*/
	public function get lower():uint { return _lower; }
	
	/** The upper bound of the Interval.*/
	public function get upper():uint { return _upper; }
	
	/** The count of the integers contained in the interval.*/
	public function get width():uint { return _width; }
	
	public function reset(lower:uint, uppper:uint):void
	{
		_lower = Math.min(lower, uppper);
		_upper = Math.max(lower, uppper);
		_width = upper - lower + 1;
	}

	public static function compareFnDesc(a:IntegerInterval, b:IntegerInterval):int
	{
		if (a.lower < b.lower)
		{
			// A positive return value specifies that A appears after B in the sorted sequence.
			return 1;
		} 
		else if (a.lower > b.lower)
		{
			// A negative return value specifies that A appears before B in the sorted sequence.
			return -1;
		}
		else
		{
			// A return value of 0 specifies that A and B have the same sort order.
			return 0;
		}
	}
	
	
	public function getValue(index:uint):uint
	{
		return lower + index;
	}
	
	public function toString():String
	{
		return "["+lower+", "+upper+"]";
	}
}

internal class AnnotatedPoint
{
	// The numerical order of the AnnotatedPoint types, determine the priority of a point
	// over another, when they happen at a same time.
	public static const PointType_End:uint      = 0;
	public static const PointType_GapStart:uint = 1;
	public static const PointType_Start:uint    = 2;
	public static const PointType_GapEnd:uint   = 3;
	
	public var value:uint;
	public var type:uint;
	
	public function AnnotatedPoint(value:uint, type:uint)
	{
		this.value = value;
		this.type = type;
	}
	
	public static function compareFn(a:AnnotatedPoint, b:AnnotatedPoint):int
	{
		if (a.value == b.value)
		{
			// If multiple events happen at the same point,
			// the type of the AnnotatedPoint determines the final order
			if (a.type < b.type) return -1;
			else if (a.type > b.type) return 1;
			else return 0;
		}
		else
		{
			if (a.value < b.value) return -1;
			else if (a.value > b.value) return 1;
			else return 0;
		}
	}
}