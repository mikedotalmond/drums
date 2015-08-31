package drums.view.sequencer;
import hxsignal.Signal;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */

class CellUI extends Graphics {

	static inline var cellSize = CellGrid.cellSize;

	public var toggleEvent:Signal<Int->Int->Void>;
	public var editEvent:Signal<Int->Int->Void>;

	var fading:Bool = false;
	var isDown:Bool = false;

	public function new(pointer:Pointer) {
		super();

		toggleEvent = new Signal<Int->Int->Void>();
		editEvent 	= new Signal<Int->Int->Void>();

		pointer.click.connect(onClick);
		pointer.down.connect(onDown);
		pointer.up.connect(onPressCancel);
		pointer.longPress.connect(onLongPress);
		pointer.pressCancel.connect(onPressCancel);
		pointer.pressProgress.connect(onPressProgress);
	}

	function onClick(target:DisplayObject) {
		if (target.parent != parent) return;

		var values:Array<String> = target.name.split(',');
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
		toggleEvent.emit(trackIndex, tickIndex);
	}

	function onDown(target:DisplayObject) {
		if (target.parent != parent) return;

		clear();
		x = target.x;
		y = target.y;

		beginFill(0x2196f3, 0.25);
		drawRect(-cellSize/2, -cellSize/2, cellSize, cellSize);
		endFill();

		alpha = 0;
		isDown = true;
		fading = false;
	}

	function onPressProgress(target:DisplayObject, p:Float) {
		if (target.parent != parent) return;

		x = target.x;
		y = target.y;

		clear();
		alpha = 1;

		var pp = p * p;
		var ppp = pp * p;

		beginFill(0x2196f3, .25+ppp*.25);
		drawRect(-cellSize/2, -cellSize/2, cellSize, cellSize);
		endFill();

		beginFill(0x2196f3, pp);
		drawRect(-cellSize/2, -cellSize/2, pp * cellSize, cellSize);
		endFill();
	}

	function onLongPress(target:DisplayObject) {
		if (target.parent != parent) return;

		isDown = false;

		beginFill(0x2196f3, 1);
		drawRect(-cellSize/2, -cellSize/2, cellSize, cellSize);
		endFill();

		var values:Array<String> = target.name.split(',');
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
		editEvent.emit(trackIndex, tickIndex);
	}

	
	function onPressCancel(target:DisplayObject) {
		if (target != null && target.parent != parent) return;
		fading = true;
		isDown = false;
	}


	public function update() {
		if (fading) {
			if (alpha > 0.001) {
				alpha *= .75;
			} else {
				clear();
				alpha = 1;
				fading = false;
			}
		} else if (isDown) {
			if (alpha < 1) {
				alpha += .05;
			}
		}
	}
}