package drums.ui.celledit;
import drums.DrumSequencer;
import drums.ui.UIElement;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class OscilliscopePanel extends UIElement {

	public function new(drums:DrumSequencer, trackIndex:Int, tickIndex:Int) {
		super(315, 100);
	}

	override function drawBg(w:Int, h:Int):Void {
		super.drawBg(w, h);
		bg.lineStyle(1, 0x60CEFF);
		bg.moveTo(0, h/2);
		bg.lineTo(314, h/2);
	}
}