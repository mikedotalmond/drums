package tones.data;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
@:native("window.OscillatorTypeShim")
extern enum OscillatorType {
	SINE; 
	SQUARE; 
	TRIANGLE; 
	SAWTOOTH; 
	CUSTOM;
}

@:keep @:noCompletion class OscillatorTypeShim {	
	static function __init__() {
		// init shim -- fix for differences in current browser versions
		var node:Dynamic = untyped __js__('window.OscillatorNode');
		if (node != null) {
			if (Reflect.hasField(node, "SINE")) {
				// older chrome/webkit
				untyped __js__('window.OscillatorTypeShim = {SINE:node.SINE, SQUARE:node.SQUARE, TRIANGLE:node.TRIANGLE, SAWTOOTH:node.SAWTOOTH, CUSTOM:node.CUSTOM}');
			} else {
				untyped __js__('window.OscillatorTypeShim = {SINE:"sine", SQUARE:"square", TRIANGLE:"triangle", SAWTOOTH:"sawtooth", CUSTOM:"custom"}');
			}
		}
	}
}