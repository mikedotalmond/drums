package parameter;
/**
 * ...
 * @author Mike Almond
 */

import hxsignal.Signal;
import parameter.Mapping;

/**/
class ParameterBase<T> {

	public var name(default, null):String;

	public var defaultValue(default, null):T;
	public var normalisedValue(default, null):T;
	public var normalisedDefaultValue(default, null):T;

	public var mapping(default, null):Mapping<T>;
	public var change(default, null):Signal<Parameter<T>->Void>;

	private function new(name:String, mapping:Mapping<T>) {

		this.name = name;
		this.mapping = mapping;

		change = new Signal<Parameter<T>->Void>();

		setDefault(mapping.min);
	}

	public function setDefault(value:T, normalised:Bool = false) {
		var normValue:T;

		if (normalised) {
			normValue = value;
			value = mapping.map(normValue);
		} else {
			normValue = mapping.mapInverse(value);
		}

		normalisedDefaultValue = normValue;
		defaultValue = value;

		setValue(normValue, true);
	}

	public function setValue(value:T, normalised:Bool = false, forced:Bool = false):Void {

		var normValue:T;

		if (normalised) normValue = value;
		else normValue = mapping.mapInverse(value);

		if (forced || normValue != normalisedValue) {
			normalisedValue = normValue;
			change.emit(cast this);
		}
	}

	public function setToDefault() {
		setValue(normalisedDefaultValue, true);
	}

	public function getValue(normalised:Bool = false):T {
		if (normalised) return normalisedValue;
		return mapping.map(normalisedValue);
	}

	public function invert() {
		throw 'Error - not implemented';
	}

	public function addObservers(observers:Array<Parameter<T>->Void>, triggerImmediately = false, once = false) {
		for (observer in observers) {
			addObserver(observer, triggerImmediately, once);
		}
	}

	public function addObserver(callback:Parameter<T>->Void, triggerImmediately = false, once = false) {
		if (!change.isConnected(callback)) {
			change.connect(callback, once ? ConnectionTimes.Once : ConnectionTimes.Forever);
		}
		if (triggerImmediately) change.emit(cast this);
	}

	public function removeObserver(callback:Parameter<T>->Void) {
		if (change.isConnected(callback)) {
			change.disconnect(callback);
		}
	}

	public function toString():String {
		return '[Parameter] ${name}, defaultValue:${defaultValue}, mapping:${mapping.toString()}';
	}
}


class BoolParameter extends ParameterBase<Bool> {
	public function new(name, mapping:Mapping<Bool>) {
		super(name, mapping);
	}

	override public function invert() {
		setValue(!getValue());
	}
}

class IntParameter extends ParameterBase<Int> {
	public function new(name, mapping:Mapping<Int>) {
		super(name, mapping);
	}

	override public function invert() {
		setValue(-getValue());
	}
}

class FloatParameter extends ParameterBase<Float> {
    public function new(name, mapping:Mapping<Float>) {
		super(name, mapping);
	}

	override public function invert() {
		setValue(-getValue());
	}
}


@:multiType
@:forward(name, defaultValue, normalisedValue, normalisedDefaultValue, mapping, change,
setValue, getValue, setDefault, setToDefault, invert, addObservers, addObserver, removeObserver, toString)
abstract Parameter<T>(ParameterBase<T>) {

    public function new(name:String, mapping:Mapping<T>);

	@:to static inline function
		toBoolParameter<T>(t:ParameterBase<Bool>, name:String, mapping:Mapping<Bool>):BoolParameter {
			return new BoolParameter(name, mapping);
    }

    @:to static inline function
		toIntParameter<T>(t:ParameterBase<Int>, name:String, mapping:Mapping<Int>):IntParameter {
			return new IntParameter(name, mapping);
    }

	@:to static inline function
		toFloatParameter<T>(t:ParameterBase<Float>, name:String, mapping:Mapping<Float>):FloatParameter {
			return new FloatParameter(name, mapping);
    }
}