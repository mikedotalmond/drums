package drums;
import drums.DrumSequencer;
import drums.Pointer;
import js.html.Point;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import tones.utils.TimeUtil;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class SequenceGrid extends Container {

	static inline var trackCount = 8;
	static inline var stepCount = 16;
	static inline var cellSize = 52;


	public var displayWidth:Int;
	public var displayHeight:Int;

	var xStep:Float;
	var yStep:Float;
	var cells:Array<Array<Graphics>>;
	var drums:DrumSequencer;
	var pointer:Pointer;

	public function new(displayWidth:Int, displayHeight:Int, drums:DrumSequencer) {
		super();

		this.drums = drums;
		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		xStep = displayWidth / stepCount;
		yStep = displayHeight / trackCount;
		cells = [];

		pointer = new Pointer();
		pointer.click.connect(onClick);
		pointer.longPress.connect(onLongPress);
		pointer.pressCancel.connect(onPressCancel);
		pointer.pressProgress.connect(onPressProgress);

		createCells();
	}

	function createCells() {
		var g;
		var background:Container = new Container();

		for (i in 0...trackCount) {
			for (j in 0...stepCount) {
				g = new Graphics();
				g.position.x = Math.round(j * xStep);
				g.position.y = Math.round(i * yStep);
				drawCell(g, cellSize, 0);
				background.addChild(g);
			}
		}

		background.interactive = false;
		background.interactiveChildren = false;
		background.cacheAsBitmap = true;
		addChild(background);

		uiHint = new Graphics();
		addChild(uiHint);

		for (i in 0...trackCount) {
			cells.push([]);
			for (j in 0...stepCount) {
				g = new Graphics();
				g.position.x = Math.round(j * xStep);
				g.position.y = Math.round(i * yStep);
				g.interactive = true;
				g.name = '$i,$j';
				pointer.watch(g);
				cells[i].push(cast addChild(g));
			}
		}
	}


	function onClick(target:DisplayObject) {
		var values:Array<String> = target.name.split(',');
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
		var event = drums.tracks[trackIndex].events[tickIndex];
		event.active = !event.active;
	}


	var uiHint:Graphics;
	function onPressProgress(target:DisplayObject, p:Float) {
		// grow...
		uiHint.x = target.x;
		uiHint.y = target.y;
		uiHint.clear();
		uiHint.beginFill(0x66ffbe, 1);
		uiHint.drawRect(-cellSize/2, -cellSize/2, (p*p) * cellSize, cellSize);
		uiHint.endFill();
	}


	function onPressCancel(target:DisplayObject) {
		uiHint.clear();
	}


	function onLongPress(target:DisplayObject) {
		trace('longPress');
		//trace(target.name);

		// edit cell - ui popup
		var values:Array<String> = target.name.split(',');
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
	}


	function drawCell(g:Graphics, size:Float, color:Int) {
		g.clear();
		g.beginFill(color, 1);
		g.drawRect(-(size/2), -(size/2), size, size);
		g.endFill();
	}



	public function tick(index:Int) {
		if (index < 0) return;

		var cell;
		var event;
		var tracks = drums.tracks;

		for (i in 0...trackCount) {
			event = tracks[i].events[index];
			if (event.active) {
				cell = cells[i][index];
				cell.lineColor = 0xffffff;
				drawCell(cell, cellSize, 0xffffff);
			}
		}
	}


	public function update(dt) {
		var c;
		var cell;
		var tracks = drums.tracks;
		var targetSize = cellSize / 1.25;

		for (i in 0...trackCount) {
			for (j in 0...stepCount) {
				cell = cells[i][j];
				if (cell.width > targetSize) {
					var size = Std.int(cell.width - (cell.width-targetSize) * .15);
					drawCell(cell, size, 0xffffff);
				} else {
					c = (tracks[i].events[j].active) ? 0xffffff : 0x121212;
					if (cell.lineColor != c) {
						cell.lineColor = c; // use to store the colour once set - prevent drawing the same thing again and again
						drawCell(cell, targetSize, c);
					}
				}
			}
		}
	}
}