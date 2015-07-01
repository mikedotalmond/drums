package drums.ui;
import pixi.core.text.Text;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */

class Button extends UIElement {
	public function new(width:Int, height:Int) {
		super(width,height);
		buttonMode = true;
		interactive = true;
	}
}

class LabelButton extends Button {

	var label:Text;
	// bg blue - 0x2DBEFF
	// lighter blue - 60CEFF

	public function new(width:Int, height:Int, text:String) {
		super(width, height);

		// Ubuntu - 300,400,700
		label = new Text(text,
		{
			font : '400 20px Ubuntu', fill : 'white', align : 'center',
			dropShadow:true, dropShadowAngle:0, dropShadowDistance:1, dropShadowColor:'#008ECC'
		});

		addChild(label);
		label.position.set(Math.fround(90 / 2 - label.width / 2), Math.fround(84 / 2 - label.height / 2));
	}
}