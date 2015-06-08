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

		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		xStep = displayWidth / stepCount;
		lines = [for (i in 0...stepCount) cast addChild(new Graphics())];

		for (i in 0...stepCount) tick(i);

		TimeUtil.frameTick.connect(update);
	}

	public function tick(index:Int) {
		if (index < 0) return;

		var gfx = lines[index];

		var w = lineWidthForStep(index) * 4;
		var x = Std.int(index * xStep - w / 2);

		gfx.clear();
		gfx.beginFill(0x00FFBE, 1);
		gfx.drawRect(x, 0, w, displayHeight);
		gfx.endFill();
	}

	function update(dt:Float) {
		for (i in 0...stepCount) {
			var gfx = lines[i];
			var currentWidth = gfx.width;
			var targetWidth = lineWidthForStep(i);
			if (currentWidth > targetWidth) {

				var w = currentWidth - (currentWidth - targetWidth) * .2;
				var x = Std.int(i * xStep - w / 2);

				gfx.clear();
				gfx.beginFill(0x00FFBE, 1);
				gfx.drawRect(x, 0, Std.int(w), displayHeight);
				gfx.endFill();
			}
		}
	}

	function lineWidthForStep(index:Int) {
		return 	(index % 4 == 0) ? 6 :
				(index % 2 == 0) ? 3 :
				1;
	}
}