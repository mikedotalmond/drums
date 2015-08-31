package drums.view.displays;

import js.html.audio.AnalyserNode;
import js.html.audio.AudioContext;
import js.html.Uint8Array;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class Oscilliscope extends Graphics {

	public var analyser(default, null):AnalyserNode;
	public var analyserData(default, null):Uint8Array;

	public var displayWidth:Float;
	public var displayHeight:Float;

	public function new(audioContext:AudioContext, width:Int, height:Int) {
		super();

		displayWidth = width;
		displayHeight = height;

		analyser = audioContext.createAnalyser();
		analyser.smoothingTimeConstant = .8; // the default
		analyser.fftSize = 512;
		analyserData = new Uint8Array(analyser.frequencyBinCount);
	}


	public function update(dt:Float) {

		clear();

		var data = analyserData;

		var n = data.length;
		var xStep = displayWidth / n;
		var yScale = displayHeight / 256;

		//analyser.getByteFrequencyData(data);
		analyser.getByteTimeDomainData(data);

		lineStyle(2, 0x747474);
		moveTo(0, displayHeight - data[0] * yScale);

		for (i in 0...n) lineTo(i * xStep, (displayHeight - data[i] * yScale));
	}
}