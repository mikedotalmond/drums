package drums;
import js.html.audio.AudioBuffer;
import pixi.core.graphics.Graphics;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class Waveform extends Graphics {

	var displayWidth:Int;
	var displayHeight:Int;

	public function new(width:Int, height:Int) {
		super();
		displayWidth = width - 16;
		displayHeight = height;
		x = 8;
	}

	public function drawBuffer(buffer:AudioBuffer) {
		drawPeaks(getPeaks((displayWidth >> 1) , buffer));
	}

	function drawPeaks(peaks:Array<Float>) {

		var h;
		var halfH = displayHeight / 2;

		clear();
		lineStyle(1.25, 0x15EAB5, 1);
		moveTo(0, halfH);

		var max = 1;
		var scale = displayWidth / peaks.length;

		for (i in 0...peaks.length) {
			h = Math.fround(peaks[i] / max * halfH);
			moveTo(i * scale, halfH - h);
			lineTo(i * scale, halfH + h);
		}
	}


	function getPeaks(length:Int, buffer:AudioBuffer):Array<Float> {

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

        return mergedPeaks;
    }
}