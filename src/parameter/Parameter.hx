package parameter;
/**
 * ...
 * @author Mike Almond
 */

import hxsignal.Signal;
import parameter.Mapping;


class ParameterBase<T,I> {

	public var name(default, null):String;

	public var defaultValue(default, null):T;

	public var normalisedValue(default, null):Float;
	public var normalisedDefaultValue(default, null):Float;

	public var mapping(default, null):Mapping<T,I>;
	public var change(default, null):Signal<Parameter<T,I>->Void>;

	@:allow(parameter.Parameter)
	private function new(name:String, mapping:Mapping<T,I>) {

		this.name = name;
		this.mapping = mapping;

		change = new Signal<Parameter<T,I>->Void>();

		setDefault(mapping.min);
	}

	public function setDefault(value:T, normalised:Bool = false) {

		var normValue;

		if (normalised) {
			normValue = cast value;
			value = mapping.map(normValue);
		} else {
			normValue = mapping.mapInverse(value);
		}

		normalisedDefaultValue = normValue;
		defaultValue = value;

		setValue(cast normValue, true);
	}

	public function setValue(value:T, normalised:Bool = false, forced:Bool = false):Void {

		var normValue;

		if (normalised) normValue = cast value;
		else normValue = mapping.mapInverse(value);

		if (forced || normValue != normalisedValue) {
			normalisedValue = normValue;
			change.emit(cast this);
		}
	}

	public function setToDefault() {
		setValue(cast normalisedDefaultValue, true);
	}

	public function getValue(normalised:Bool = false):T {
		if (normalised) return cast normalisedValue;
		return mapping.map(normalisedValue);
	}

	public function addObservers(observers:Array<Parameter<T,I>->Void>, triggerImmediately = false, once = false) {
		for (observer in observers) {
			addObserver(observer, triggerImmediately, once);
		}
	}

	public function addObserver(callback:Parameter<T,I>->Void, triggerImmediately = false, once = false) {
		if (!change.isConnected(callback)) {
			change.connect(callback, once ? ConnectionTimes.Once : ConnectionTimes.Forever);
		}
		if (triggerImmediately) change.emit(cast this);
	}

	public function removeObserver(callback:Parameter<T,I>->Void) {
		if (change.isConnected(callback)) {
			change.disconnect(callback);
		}
	}

	public function toString():String {
		return '[Parameter] ${name}, defaultValue:${defaultValue}, mapping:${mapping.toString()}';
	}
}

typedef BoolParameter = ParameterBase<Bool,Interpolation>
typedef IntParameter = ParameterBase<Int,Interpolation>
typedef FloatParameter = ParameterBase<Float,Interpolation>

@:multiType
@:forward(name, defaultValue, normalisedValue, normalisedDefaultValue, mapping, change, setValue, getValue, setDefault, setToDefault, invert, addObservers, addObserver, removeObserver, toString)
abstract Parameter<T,I>(ParameterBase<T,I>) {

    public function new(name:String, min:T, max:T);

	@:to static inline function toBoolParameter<T,I>(t:ParameterBase<Bool,Interpolation>, name:String, min:Bool, max:Bool):BoolParameter {
		return new BoolParameter(name, getBool(min, max));
    }

    @:to static inline function toIntParameter<T,I>(t:ParameterBase<Int,InterpolationLinear>, name:String, min:Int, max:Int):IntParameter {
		return new IntParameter(name, getIntExponential(min, max));
    }
	@:to static inline function toIntParameterExpo<T,I>(t:ParameterBase<Int,InterpolationExponential>, name:String, min:Int, max:Int):IntParameter {
		return new IntParameter(name, getInt(min, max));
    }

	@:to static inline function toFloatParameter<T,I>(t:ParameterBase<Float,InterpolationLinear>, name:String, min:Float, max:Float):FloatParameter {
		return new FloatParameter(name, getFloat(min,max));
    }
	@:to static inline function toFloatParameterExpo<T,I>(t:ParameterBase<Float,InterpolationExponential>, name:String, min:Float, max:Float):FloatParameter {
		return new FloatParameter(name, getFloatExponential(min,max));
    }

	static function getBool(min,max) return cast new Mapping<Bool,Interpolation>(min, max);

	static function getFloat(min,max) return cast new Mapping<Float,InterpolationLinear>(min, max);
	static function getFloatExponential(min,max) return cast new Mapping<Float,InterpolationExponential>(min, max);

	static function getInt(min,max) return cast new Mapping<Int,InterpolationLinear>(min, max);
	static function getIntExponential(min,max) return cast new Mapping<Int,InterpolationExponential>(min, max);
}