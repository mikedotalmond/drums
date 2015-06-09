package drums;
import drums.DrumSequencer;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import tones.utils.TimeUtil;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class SequenceGrid extends Container {

	static inline var trackCount = 8;
	static inline var stepCount = 16;
	static inline var cellSize = 34;


	public var displayWidth:Int;
	public var displayHeight:Int;

	var xStep:Float;
	var yStep:Float;
	var cells:Array<Array<Graphics>>;
	var drums:DrumSequencer;

	public function new(displayWidth:Int, displayHeight:Int, drums:DrumSequencer) {
		super();

		this.drums = drums;
		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		xStep = displayWidth / stepCount;
		yStep = displayHeight / trackCount;
		cells = [];

		createCells();


		TimeUtil.frameTick.connect(update);
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
		//background.alpha = .96;
		addChild(background);

		for (i in 0...trackCount) {
			cells.push([]);
			for (j in 0...stepCount) {
				g = new Graphics();
				g.position.x = Math.round(j * xStep);
				g.position.y = Math.round(i * yStep);
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
			event =  tracks[i].events[index];
			if (event.active) {
				cell = cells[i][index];
				drawCell(cell, cellSize, 0xffffff);
			}
		}
	}

	function update(dt) {

		var cell;
		var targetSize = cellSize / 2;
		for (i in 0...trackCount) {
			for (j in 0...stepCount) {
				cell = cells[i][j];
				if (cell.width > targetSize) {
					var size = Std.int(cell.width - (cell.width-targetSize) * .15);
					drawCell(cell, size, 0xffffff);
				}
			}
		}

	}
}