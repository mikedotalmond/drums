package drums.ui;
import drums.DrumSequencer;
import drums.Pointer;
import drums.ui.CellEditPanel;
import hxsignal.Signal;
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

	public static inline var trackCount = 8;
	public static inline var stepCount = 16;
	public static inline var cellSize = 52;
	public static inline var xStep = Main.displayWidth / stepCount;
	public static inline var yStep = Main.displayHeight / trackCount;

	public var displayHeight:Int;

	var cells:Array<Array<Graphics>>;
	var drums:DrumSequencer;
	var pointer:Pointer;
	var cellUI:CellUI;
	var cellEditPanel:CellEditPanel;

	public function new(drums:DrumSequencer) {
		super();

		this.drums = drums;
		this.displayHeight = Main.displayHeight;

		cells = [];
		pointer = new Pointer();

		cellEditPanel = new CellEditPanel(drums, pointer, Main.displayWidth, Main.displayHeight);

		cellUI = new CellUI(pointer);
		cellUI.editEvent.connect(cellEditPanel.edit);
		cellUI.toggleEvent.connect(drums.toggleEvent);

		createCells();

		cellEditPanel.closed.connect(cellUI.clear);
		addChild(cellEditPanel);
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

		addChild(cellUI);

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

		cellEditPanel.tick(index);
	}


	public function update(dt) {
		var c;
		var cell;
		var active;
		var tracks = drums.tracks;
		var targetSize = cellSize / 1.25;

		for (i in 0...trackCount) {
			for (j in 0...stepCount) {
				
				cell = cells[i][j];
				active = tracks[i].events[j].active;
				
				var w = cell.width;
				if (active && w > targetSize) {
					
					var p = ((w / targetSize) - 1) * 4;
					
					var targetIntensity = 0x30;
					var intensity = targetIntensity + Std.int((0xff-targetIntensity) * p);
					
					var size = (w - (w - targetSize) * .1);
					if (p < .001) size = targetSize;
					
					drawCell(cell, size, intensity | intensity << 8 | intensity << 16 );
					
				} else {
					c = (active) ? 0x303030: 0x121212;
					if (cell.lineColor != c) {
						cell.lineColor = c; // use to store the colour once set - prevent drawing the same thing again and again
						drawCell(cell, targetSize, c);
					}
				}
			}
		}

		cellUI.update();
		cellEditPanel.update();
	}
}


class CellUI extends Graphics {

	static inline var cellSize = SequenceGrid.cellSize;

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
		if (target.parent != parent) return;
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