package drums;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import tones.utils.TimeUtil;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class BeatLines extends Container {

	inline static var stepCount:Int = 16;

	var lines:Array<Graphics>;
	var xStep:Float;

	public var displayWidth:Int;
	public var displayHeight:Int;

	public function new(displayWidth:Int, displayHeight:Int) {
		super();

		interactive = false;
		interactiveChildren = false;

		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		xStep = displayWidth / stepCount;
		lines = [];

		var g;
		for (i in 0...stepCount) {
			g = new Graphics();
			g.position.x = Math.round(xStep * i);
			lines.push(cast addChild(g));
		}

		for (i in 0...stepCount) tick(i);

		TimeUtil.frameTick.connect(update);
	}

	public function tick(index:Int) {
		if (index < 0) return;
		drawLine(lines[index], lineWidthForStep(index) * 3);
	}


	function update(dt:Float) {
		for (i in 0...stepCount) {
			var gfx = lines[i];
			var currentWidth = gfx.width;
			var targetWidth = lineWidthForStep(i);
			if (currentWidth > targetWidth) {
				var w = currentWidth - (currentWidth - targetWidth) * .2;
				drawLine(gfx, w);
			}
		}
	}


	function drawLine(g:Graphics, w:Float) {
		g.clear();
		g.beginFill(0x00FFBE, 1);
		g.drawRect((-w/2), 0, w, displayHeight);
		g.endFill();
	}


	function lineWidthForStep(index:Int) {
		return 	(index % 4 == 0) ? 6 :
				(index % 2 == 0) ? 3 :
				1;
	}
}