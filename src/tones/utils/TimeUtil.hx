package tones.utils;
import hxsignal.Signal;
import js.Browser;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class TimeUtil {

	static public inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static public inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;

	public inline static function stepTime(beats:Float, bpm:Float = 120):Float return beats / (bpm / 60);


	static public var frameTick(get, never):Signal<Float->Void>;

	static var _frameTick:Signal<Float->Void> = null;
	static function get_frameTick() return _frameTick;

	static function onFrame(_) {
		_frameTick.emit(_);
		Browser.window.requestAnimationFrame(onFrame);
	}

	static function __init__() {
		_frameTick = new Signal<Float->Void>();
		Browser.window.requestAnimationFrame(onFrame);
	}
}