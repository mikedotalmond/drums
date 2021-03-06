package drums.view.sequencer;
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
		//visible = false;
	}

	public function tick(index:Int) {
		if (index < 0) return;
		drawLine(lines[index], 4 * 4);// lineWidthForStep(index) * 4);
	}


	function update(dt:Float) {
		for (i in 0...stepCount) {
			var gfx = lines[i];
			var currentWidth = gfx.width;
			var targetWidth = 1;// lineWidthForStep(i);
			if (currentWidth > targetWidth) {
				var w = currentWidth - (currentWidth - targetWidth) * .15;
				drawLine(gfx, w);
			}
		}
	}


	function drawLine(g:Graphics, w:Float) {
		g.clear();
		g.beginFill(0x2196f3, 1);
		g.drawRect((-w/2), 0, w, displayHeight);
		g.endFill();
	}


	function lineWidthForStep(index:Int) {
		return 	(index % 4 == 0) ? 12 :
				(index % 2 == 0) ? 6 :
				3;
	}
}