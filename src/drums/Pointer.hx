package drums;
import hxsignal.Signal;
import js.html.Event;
import pixi.core.display.DisplayObject;
import tones.utils.TimeUtil;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class Pointer {

	static inline var clickTime:Float = 250;
	static inline var longPressTime:Float = 400;

	public var up(default, null):Signal<DisplayObject->Void>;
	public var down(default, null):Signal<DisplayObject->Void>;
	//public var move(default, null):Signal<DisplayObject->Void>;
	public var click(default, null):Signal<DisplayObject->Void>;
	public var longPress(default, null):Signal<DisplayObject->Void>;
	public var pressProgress(default, null):Signal<DisplayObject->Float->Void>;
	public var pressCancel(default, null):Signal<DisplayObject->Void>;

	var moved:Bool = false;
	var isDown:Bool = false;
	var timeDown:Float = 0;
	var currentTarget:DisplayObject;

	public function new() {
		up = new Signal<DisplayObject->Void>();
		down = new Signal<DisplayObject->Void>();
		//move = new Signal<DisplayObject->Void>();
		click = new Signal<DisplayObject->Void>();
		longPress = new Signal<DisplayObject->Void>();
		pressCancel = new Signal<DisplayObject->Void>();
		pressProgress = new Signal<DisplayObject->Float->Void>();
		TimeUtil.frameTick.connect(update);
	}

	public function watch(target:DisplayObject) {
		target.on('mousemove', onMove);
		target.on('mousedown', onDown);
		target.on('mouseup', onUp);
		target.on('touchmove', onMove);
		target.on('touchstart', onDown);
		target.on('touchend', onUp);
	}

	public function unwatch(target:DisplayObject) {
		target.off('mousemove', onMove);
		target.off('mousedown', onDown);
		target.off('mouseup', onUp);
		target.off('touchmove', onMove);
		target.off('touchstart', onDown);
		target.off('touchend', onUp);
	}

	var lastTime:Float = 0;

	function update(t:Float):Void {
		var dt = t - lastTime;
		lastTime = t;

		if (isDown) {
			timeDown += dt;
			if (timeDown-clickTime > longPressTime) {
				longPress.emit(currentTarget);
				isDown = false;
				timeDown = 0;
			} else if (timeDown > clickTime) {
				pressProgress.emit(currentTarget, (timeDown-clickTime)/longPressTime);
			}
		} else if(timeDown > 0){
			if (timeDown < clickTime) {
				click.emit(currentTarget);
			}
			pressCancel.emit(currentTarget);
			timeDown = 0;
		}

		moved = false;
	}

	function onDown(e:Event) {
		isDown = true;
		timeDown = 0;
		down.emit(currentTarget = cast e.target);
	}

	function onUp(e:Event) {
		isDown = false;
		up.emit(currentTarget);
	}

	function onMove(e:Event) {
		moved = true;
		//move.emit(currentTarget);
	}
}