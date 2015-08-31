package drums.view.sequencer;
import drums.DrumSequencer;
import drums.view.edit.CellEditPanel;
import drums.view.Pointer;
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
class CellGrid extends Container {

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