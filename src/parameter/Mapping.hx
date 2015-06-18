package parameter;

/**
 * ...
 * @author Mike Almond
 */
interface IMapping<T> {

	var min:T;
	var max:T;
	var range(get,never):T;

	/**
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	function map(normalisedValue:T):T;

	/**
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	function mapInverse(value:T):T;

	/**
	 *
	 * @return
	 */
	function toString():String;
}


@:multiType
@:forward(min, max, range, map, mapInverse, toString)
abstract Mapping<T>(IMapping<T>) {

	public function new(minValue:T, maxValue:T);

	@:to static inline function toMapBool<T>(t:IMapping<Bool>, minValue:Bool, maxValue:Bool):MapBool {
		return new MapBool(minValue, maxValue);
	}

	@:to static inline function toMapInt<T>(t:IMapping<Int>, minValue:Int, maxValue:Int):MapInt {
        return new MapInt(minValue, maxValue);
    }

	@:to static inline function toMapFloat<T>(t:IMapping<Float>, minValue:Float, maxValue:Float):MapFloat {
        return new MapFloat(minValue, maxValue);
    }
}


class MapBool implements IMapping<Bool> {

	public var min:Bool;
	public var max:Bool;
	public var range(get,never):Bool;
	inline function get_range() return max != min;

	public function new(min, max) {
		this.min = min;
		this.max = max;
	}


	inline public function map(normalizedValue:Bool) return normalizedValue;
	inline public function mapInverse(value:Bool) return !value;

	inline public function toString() return '[MapBool]';
}


class MapInt implements IMapping<Int> {

	public var min:Int;
	public var max:Int;

	public var range(get , never):Int;
	inline function get_range() return max - min;


	public function new(min:Int = 0, max:Int = 1 ){
		this.min = min;
		this.max = max;
	}

	inline public function map(normalisedValue:Int)
		return Math.round(min + normalisedValue * range);


	inline public function mapInverse(value:Int)
		return Math.round((value - min) / range);


	inline public function toString()
		return '[MapInt] min:${min}, max:${max}';
}


class MapFloat implements IMapping<Float> {

	public var min:Float;
	public var max:Float;

	public var range(get , never):Float;
	inline function get_range() return max - min;

	public function new(min:Float = 0, max:Float = 1){
		this.min = min;
		this.max = max;
	}

	/**
	 *
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	public inline function map(normalisedValue:Float)
		return min + normalisedValue * range;


	/**
	 *
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	public inline function mapInverse(value:Float)
		return ( value - min ) / range;


	/**
	 *
	 */
	public inline function toString()
		return '[MapFloat] min:' + min + ', max:' + max;
}