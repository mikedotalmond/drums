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

	static inline var clickTime:Float = 200;
	static inline var longPressTime:Float = 600;

	public var click:Signal<DisplayObject->Void>;
	public var longPress:Signal<DisplayObject->Void>;
	public var pressProgress:Signal<DisplayObject->Float->Void>;
	public var pressCancel:Signal<DisplayObject->Void>;

	var moved:Bool = false;
	var isDown:Bool = false;
	var timeDown:Float = 0;
	var currentTarget:DisplayObject;

	public function new() {
		click = new Signal<DisplayObject->Void>();
		longPress = new Signal<DisplayObject->Void>();
		pressCancel = new Signal<DisplayObject->Void>();
		pressProgress = new Signal<DisplayObject->Float->Void>();
		TimeUtil.frameTick.connect(update);
	}

	public function watch(target:DisplayObject) {
		target.on('mousemove', move);
		target.on('mousedown', down);
		target.on('mouseup', up);
		target.on('touchmove', move);
		target.on('touchstart', down);
		target.on('touchend', up);
	}

	public function unwatch(target:DisplayObject) {
		target.off('mousemove', move);
		target.off('mousedown', down);
		target.off('mouseup', up);
		target.off('touchmove', move);
		target.off('touchstart', down);
		target.off('touchend', up);
	}

	var lastTime:Float = 0;

	function update(t:Float):Void {
		var dt = t - lastTime;
		lastTime = t;

		if (isDown) {
			if (dt < 250) timeDown += dt;
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

	function down(e:Event) {
		currentTarget = cast e.target;
		isDown = true;
		timeDown = 0;
	}

	function up(e:Event) {
		isDown = false;
	}

	function move(e:Event) {
		moved = true;
	}
}