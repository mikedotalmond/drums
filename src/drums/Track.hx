package drums;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;
import js.html.audio.PannerNode;
import js.html.audio.PanningModelType;
import tones.Samples;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */

class Track {

	static inline var HALFPI = 1.5707963267948966;
	static inline var stepCount = 16;

	var _pan:Float = 0;
	var panNode:PannerNode;
	var outGain:Float = 1;
	var gainNode:GainNode;
	
	public var name		(default, null):String;
	public var events	(default, null):Array<TrackEvent>;
	public var source	(default, null):Samples;

	public var isMuted	(default, null):Bool = false;
	
	public var isSolo	:Bool = false;
	public var otherSolo:Bool = false;
	
	public var pan(get, set):Float;

	
	public function new(name:String, buffer:AudioBuffer,context:AudioContext, destination:AudioNode) {

		this.name = name;

		// output level
		outGain = 1.0;
		gainNode = context.createGain();
		gainNode.gain.value = outGain;
		gainNode.connect(destination);
		
		//pan
		panNode = context.createPanner();
		panNode.panningModel = PanningModelType.EQUALPOWER;
		panNode.connect(gainNode);
		
		//other fx

		// source
		source = new Samples(context, panNode);
		source.attack = 0;
		source.buffer = buffer;

		events = [for (i in 0...stepCount)
			{ active:false, id:-1, volume:1, pan:0, rate:1, attack:0, offset:0, duration:buffer.duration }
		];
	}


	public function randomise() {

		var buffer = source.buffer;

		for (i in 0...stepCount) {			
			var e = events[i];
			var active = Std.int(16 * Math.random()) % Std.int(Math.random() * 16) == 0;
			if (active) {
				e.active = true;
				var rate = 1.1 - ((1 + Math.random()*i) / stepCount);
				if (Math.random() < .5) rate = 2 - rate;
				if (rate <= 0) rate = 1;
				e.rate = rate;
				e.volume = .5 + Math.random() * 2;
				e.pan = Math.random() * ( -.5 + (i / (stepCount * 2)));
				e.duration = source.buffer.duration * .1 + Math.random() * .9;
				e.offset = Math.random() > .5 ? 0 : e.duration * Math.random() * .1;
				e.attack = Math.random() > .5 ? 0 : .1 * Math.random();
			} else {
				e.active = false;
			}
		}
	}
	
	public function mute(state:Bool) {
		isMuted = state;
		updateOutputState();
	}
	
	public function solo(state:Bool) {
		isSolo = state;
		updateOutputState();
	}
	
	public function updateOutputState() {
		var val = isMuted ? 0 : ((!otherSolo || isSolo) ? outGain : 0);
		gainNode.gain.setValueAtTime(val, 0);	
	}
	

	inline function get_pan() return _pan;
	function set_pan(value:Float) {
		setPan(value, panNode);
		return _pan = value;
	}

	static inline function setPan(value:Float=0, node:PannerNode):Void {
		var x = value * HALFPI;
		var z = x + HALFPI;
		if (z > HALFPI) z = Math.PI - z;
		node.setPosition(Math.sin(x), 0, Math.sin(z));
	}
}

