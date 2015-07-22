package drums.ui;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class UIElement extends Container {

	var bg:Graphics;

	public function new(width:Int, height:Int) {
		super();
		interactive = false;
		bg = new Graphics();
		drawBg(width, height);
		addChild(bg);
	}

	function drawBg(w:Int, h:Int):Void {
		bg.clear();
		bg.beginFill(0x2196f3);
		bg.drawRect(0, 0, w, h);
		bg.endFill();
	}
}