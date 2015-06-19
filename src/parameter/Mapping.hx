package parameter;

/**
 * ...
 * @author Mike Almond
 */

interface Interpolation { }
interface InterpolationNone extends Interpolation { }
interface InterpolationLinear extends Interpolation { }
interface InterpolationExponential extends Interpolation { }

interface IMapping<T,I> {

	var min(default, null):T;
	var max(default, null):T;
	var range(get, never):T;

	function setMinMax(min:T, max:T):Void;

	/**
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	function map(normalisedValue:Float):T;

	/**
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	function mapInverse(value:T):Float;

	/**
	 *
	 * @return
	 */
	function toString():String;
}


@:multiType
@:forward(min, max, setMinMax, range, map, mapInverse, toString)
abstract Mapping<T,I>(IMapping<T,I>) {

	public function new(minValue:T, maxValue:T);

	@:to static inline function toMapBool<T,I>(t:IMapping<Bool, InterpolationNone>, minValue:Bool, maxValue:Bool):MapBool {
		return new MapBool(minValue, maxValue);
	}
	@:to static inline function toMapIntLinear<T,I>(t:IMapping<Int, InterpolationLinear>, minValue:Int, maxValue:Int):MapIntLinear {
        return new MapIntLinear(minValue, maxValue);
    }
	@:to static inline function toMapIntExponential<T,I>(t:IMapping<Int, InterpolationExponential>, minValue:Int, maxValue:Int):MapIntExponential {
        return new MapIntExponential(minValue, maxValue);
    }
	@:to static inline function toMapFloatLinear<T,I>(t:IMapping<Float, InterpolationLinear>, minValue:Float, maxValue:Float):MapFloatLinear {
        return new MapFloatLinear(minValue, maxValue);
    }
	@:to static inline function toMapFloatExponential<T,I>(t:IMapping<Float, InterpolationExponential>, minValue:Float, maxValue:Float):MapFloatExponential {
        return new MapFloatExponential(minValue, maxValue);
    }
}


class MapBool implements IMapping<Bool, InterpolationNone> {

	public var min(default, null):Bool;
	public var max(default, null):Bool;

	public var range(get,never):Bool;
	inline function get_range() return max != min;

	public function new(min, max) {
		setMinMax(min, max);
	}

	inline public function setMinMax(min, max) {
		this.min = min;
		this.max = max;
	}

	inline public function map(normalizedValue:Float) return normalizedValue == 1.0 ? max : min;
	inline public function mapInverse(value:Bool) return value == max ? 1.0 : .0;

	inline public function toString() return '[MapBool]';
}


class MapIntExponential implements IMapping<Int, InterpolationExponential> {

	public var min(default, null):Int;
	public var max(default, null):Int;

	public var range(get , never):Int;
	inline function get_range() return max - min;

	var _min:Float;
	var _max:Float;
	var _t0	:Float;
	var _t1	:Float;
	var _t2	:Float;

	public function new(min = -1, max = 1){
		setMinMax(min, max);
	}

	public function setMinMax(min,max) {
		this.min = min;
		this.max = max;

		_t2 = 0;
		if (min <= 0) _t2 = 1 + min * -1;

		_min = min + _t2;
		_max = max + _t2;

		_t0 = Math.log(_max / _min);
		_t1 = 1.0 / _t0;
	}

	/**
	 *
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	inline public function map(normalisedValue:Float) return Math.round(_min * Math.exp( (normalisedValue) * _t0 ) - _t2);

	/**
	 *
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	inline public function mapInverse(value:Int) return Math.log((value + _t2) / _min) * _t1;

	inline public function toString() return '[MapIntExponential] min:${min}, max:${max}';
}


class MapIntLinear implements IMapping<Int, InterpolationLinear> {

	public var min(default, null):Int;
	public var max(default, null):Int;

	public var range(get , never):Int;
	inline function get_range() return max - min;

	public function new(min:Int = 0, max:Int = 1 ){
		setMinMax(min, max);
	}

	inline public function setMinMax(min, max) {
		this.min = min;
		this.max = max;
	}

	inline public function map(normalisedValue:Float) return Math.round(min + normalisedValue * range);

	inline public function mapInverse(value:Int) return (value - min) / range;

	inline public function toString() return '[MapIntLinear] min:${min}, max:${max}';
}


class MapFloatLinear implements IMapping<Float, InterpolationLinear> {

	public var min:Float;
	public var max:Float;

	public var range(get , never):Float;
	inline function get_range() return max - min;

	public function new(min:Float = 0, max:Float = 1) {
		setMinMax(min, max);
	}

	inline public function setMinMax(min:Float, max:Float) {
		this.min = min;
		this.max = max;
	}

	/**
	 *
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	public inline function map(normalisedValue:Float) return min + normalisedValue * range;

	/**
	 *
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	public inline function mapInverse(value:Float) return ( value - min ) / range;

	public inline function toString() return '[MapFloatLinear] min:' + min + ', max:' + max;
}


class MapFloatExponential implements IMapping<Float, InterpolationExponential> {

	public var min(default, null):Float;
	public var max(default, null):Float;

	public var range(get, never):Float;
	inline function get_range() return max - min;

	var _min:Float;
	var _max:Float;
	var _t0	:Float;
	var _t1	:Float;
	var _t2	:Float;

	public function new(min = .0, max = 1.0 ){
		setMinMax(min, max);
	}

	public function setMinMax(min,max) {
		this.min = min;
		this.max = max;

		_t2 = 0;
		if (min <= 0) _t2 = 1 + min * -1;

		_min = min + _t2;
		_max = max + _t2;

		_t0 = Math.log(_max / _min);
		_t1 = 1.0 / _t0;
	}

	/**
	 *
	 * @param	normalisedValue (0-1)
	 * @return	A mapped value in the range of min-max
	 */
	inline public function map(normalisedValue:Float) return _min * Math.exp( (normalisedValue) * _t0 ) - _t2;

	/**
	 *
	 * @param	value	A value in the range of min-max
	 * @return	Normalised value (0-1)
	 */
	inline public function mapInverse(value:Float) return Math.log((value + _t2) / _min) * _t1;

	inline public function toString() return '[MapFloatExponential] min:${min}, max:${max}';

}