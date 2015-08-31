package drums.view.edit;
import drums.DrumSequencer;
import drums.view.displays.Waveform;
import drums.view.UIElement;
import js.html.audio.AudioBuffer;
import pixi.core.graphics.Graphics;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class WaveformPanel extends UIElement {

	var waveform:Waveform;
	var overlay:Graphics;
	
	static inline var Width = 840;
	static inline var Height = 198;

	public function new() {
		super(Width, 198);

		waveform = new Waveform(Width, Height);
		
		overlay = new Graphics();
		addChildAt(overlay, 1);
		
		addChildAt(waveform, 2);
		
		updateOverlay(0, 1);
	}
	

	public function setup(drums:DrumSequencer, trackIndex:Int, tickIndex:Int) {
		var buffer = drums.tracks[trackIndex].source.buffer;
		var e = drums.tracks[trackIndex].events[tickIndex];
		
		waveform.drawBuffer(buffer);
	}
	

	public function updateOverlay(offset:Float, duration:Float) {
		
		duration = duration - offset;
		
		var x = Width * offset;
		var w = x + Width * duration;
		
		w = Math.min(Width - x, w);
		
		overlay.clear();
		overlay.beginFill(0,.1);
		overlay.drawRect(x, 0, w, Height);
		overlay.endFill();
	}
	
	override function drawBg(w, h) {
		super.drawBg(w, h);
		bg.lineStyle(1, 0x60CEFF);
		bg.moveTo(0, h/2);
		bg.lineTo(Width,h/2);
	}
}