package drums.ui.celledit;
import drums.DrumSequencer;
import drums.Waveform;
import js.html.audio.AudioBuffer;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class WaveformPanel extends UIElement {

	var waveform:Waveform;

	public function new() {
		super(840, 198);

		waveform = new Waveform(840, 198);
		
		addChildAt(waveform, 1);
	}


	public function setup(drums:DrumSequencer, trackIndex:Int, tickIndex:Int) {
		var buffer = drums.tracks[trackIndex].source.buffer;
		waveform.drawBuffer(buffer);
	}

	public function updateOverlay(offset:Float, duration:Float, rate:Float) {

	}
	
	public function play(event:TrackEvent) {
		
	}

	override function drawBg(w, h) {
		super.drawBg(w, h);
		bg.lineStyle(1, 0x60CEFF);
		bg.moveTo(0, h/2);
		bg.lineTo(840,h/2);
	}
}