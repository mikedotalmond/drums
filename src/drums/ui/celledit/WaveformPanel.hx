package drums.ui.celledit;
import drums.Waveform;
import js.html.audio.AudioBuffer;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class WaveformPanel extends UIElement {

	var display:Waveform;

	public function new(seq:DrumSequencer, ?buffer:AudioBuffer = null) {
		super(510, 198);

		display = new Waveform(510, 198);
		if (buffer != null) setBuffer(buffer);

		addChildAt(display, 1);
	}

	inline public function setBuffer(buffer) {
		display.drawBuffer(buffer);
	}

	override function drawBg(w, h) {
		super.drawBg(w, h);
		bg.lineStyle(1, 0x60CEFF);
		bg.moveTo(0, h/2);
		bg.lineTo(509, h/2);
	}
}