package drums;
import js.html.audio.AudioBuffer;
import js.html.Float32Array;
import pixi.core.graphics.Graphics;

using Lambda;
/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class Waveform extends Graphics {

	var displayWidth:Int;
	var displayHeight:Int;
	var lastPeaks:Float32Array;
	var lastBuffer:AudioBuffer;

	public function new(width:Int, height:Int) {
		super();
		displayWidth = width - 16;
		displayHeight = height;
		x = 8;
	}

	public function drawBuffer(buffer:AudioBuffer, normalise:Bool = true) {

		var peaks = (buffer == lastBuffer) ? lastPeaks : getPeaks((displayWidth >> 1) , buffer);

		drawPeaks(peaks, normalise);

		lastPeaks = peaks;
		lastBuffer = buffer;
	}


	function drawPeaks(peaks:Float32Array, normalise:Bool) {

		var h;
		var halfH = displayHeight / 2;

		clear();
		lineStyle(1.25, 0x15EAB5, 1);
		moveTo(0, halfH);

		var max = normalise ? getMax(peaks) : 1.0;
		var scale = displayWidth / peaks.length;
		var n = peaks.length;

		max *= 1.05;

		for (i in 0...n) {
			h = Math.fround(peaks[i] / max * halfH);
			moveTo(i * scale, halfH - h);
			lineTo(i * scale, halfH + h);
		}
	}


	function getMax(peaks:Float32Array) {
		var max = .0;
		for (v in peaks) if (v > max) max = v;
		return max;
	}


	function getPeaks(length:Int, buffer:AudioBuffer):Float32Array {

		var sampleSize = buffer.length / length;
        var sampleStep = sampleSize / 10;
        var channels = buffer.numberOfChannels;
        var mergedPeaks = [];

        for (c in 0...channels) {
            var peaks = [];
            var chan = buffer.getChannelData(c);

            for (i in 0...length) {
                var start = (i * sampleSize);
                var end = start + sampleSize;
                var max = .0;
				var j = start;
                while (j < end) {
                    var value = chan[Std.int(j)];
                    if (value > max) {
                        max = value;
                    } else if (-value > max) {
                        max = -value;
                    }
					j += sampleStep;
                }

                peaks[i] = max;

                if (c == 0 || max > mergedPeaks[i]) {
                    mergedPeaks[i] = max;
                }
            }
        }

        return new Float32Array(mergedPeaks);
    }
}