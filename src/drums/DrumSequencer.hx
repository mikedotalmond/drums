package drums;

import hxsignal.Signal;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;
import js.html.audio.PannerNode;
import js.html.audio.PanningModelType;
import js.html.XMLHttpRequestResponseType;
import tones.AudioBase;
import tones.data.ItemData;

import tones.Samples;
import tones.utils.NoteFrequencyUtil;
import tones.utils.TimeUtil;
import tones.data.OscillatorType;

import js.html.XMLHttpRequest;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class DrumSequencer {

	static var filenames:Array<String> = ['Kick01', 'Snare01', 'Snare02', 'Rim01', 'Rim02', 'Clave01', 'Clave02', 'Cowbell'];
	static var trackNames:Array<String> = ['Kick', 'Snare 1', 'Snare 2', 'Rim 1', 'Rim 2', 'Clave 1', 'Clave 2', 'Cowbell'];

	static inline var tickLength:Float = 1/4;
	static inline var stepCount:Int = 16;

	var loadCount:Int;
	var tickIndex:Int = -1;
	var lastTick:Int = 0;
	var timeTrack:AudioBase;
	var _bpm:Float;
	var _swing:Float;

	public var bpm(get, set):Float;
	public var swing(get, set):Float;
	public var tracks(default, null):Array<Track>;
	public var tick(default, null):Signal<Int->Float->Void>;
	public var output(default, null):GainNode;
	public var context(default, null):AudioContext;
	public var ready(default, null):Signal<Void->Void>;
	public var playing(default, null):Bool;


	public function new(audioContext:AudioContext=null, destination:AudioNode=null) {

		bpm = 120;
		swing = 0;

		playing = false;

		context = (audioContext == null ? AudioBase.createContext() : audioContext);

		output = context.createGain();
		output.connect(destination == null ? context.destination : destination);

		ready = new Signal<Void->Void>();
		tick = new Signal<Int->Float->Void>();
		tracks = [];

		loadSamples();
	}


	public function play(tick:Int = 0) {
		playing = true;
		tickIndex = tick - 1;
		timeTrack.removeAllTimedEvents();
		timeTrack.addTimedEvent(context.currentTime + 1/120);
	}


	public function stop() {
		playing = false;
		tickIndex = -1;
		timeTrack.removeAllTimedEvents();
	}


	public function toggleEvent(trackIndex:Int, tickIndex:Int) {
		var track = tracks[trackIndex];
		
		var e = track.events[tickIndex];
		e.active = !e.active;
		
		if (!e.active && e.id != -1) track.source.doStop(e.id);
	}


	function loadSamples() {
		loadCount = 0;
		for (i in 0...filenames.length) {
			tracks.push(null);
			var request = new XMLHttpRequest();
			request.open("GET", 'data/samples/808_${filenames[i]}.wav', true);
			request.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
			request.onload = function(_) context.decodeAudioData(_.currentTarget.response, sampleDecoded.bind(_,i));
			request.send();
		}
	}


	function sampleDecoded(buffer:AudioBuffer, index:Int) {

		tracks[index] = new Track(trackNames[index], buffer, context, output);
		loadCount++;

		if (index == 0) {
			timeTrack = tracks[0].source;
			timeTrack.timedEvent.connect(onTrackTick);
		} else if (loadCount == filenames.length) {
			ready.emit();
		}
	}


	function onTrackTick(id:Int, time:Float) {

		if (!playing) return;

		if (time < context.currentTime) time = context.currentTime;

		// apply swing
		var offset = .0;
		if (swing > 0) {
			if (tickIndex & 1 == 1) {
				offset = (0.25 + swing) * tickLength;
			} else {
				offset = (0.25 - swing) * tickLength;
			}
		}

		var nextTick = time + TimeUtil.stepTime(tickLength + offset, bpm);

		timeTrack.addTimedEvent(nextTick);

		tick.emit(tickIndex, time);

		tickIndex++;
		if (tickIndex == stepCount) tickIndex = 0;

		playTick(tickIndex, nextTick);
	}


	/**
	 * Play the selected Cell, using the current parameters for that cell.
	 * @param	trackIndex
	 * @param	cellIndex
	 */
	public function playTrackCellNow(trackIndex:Int, cellIndex:Int) {

		var track = tracks[trackIndex];
		var event = track.events[cellIndex];
		var s = track.source;

		track.pan = event.pan;

		s.volume = event.volume;
		s.attack = event.attack;
		//s.release = event.release;
		s.offset = event.offset;
		s.duration = event.duration;
		s.playbackRate = event.rate;

		s.playSample(null, 0);
	}


	public function isPlaying(trackIndex:Int) {
		return tracks[trackIndex].events[tickIndex].active;
	}


	function playTick(index:Int, time:Float) {

		for (track in tracks) {
			var event = track.events[index];
			if (event.active) {
				var s = track.source;
				s.volume = event.volume;
				s.attack = event.attack;
				//s.release = event.release;
				s.offset = event.offset;
				s.duration = event.duration;
				s.playbackRate = event.rate;
				track.pan = event.pan;
				event.id = s.playSample(null, time - context.currentTime);
			}
		}
	}


	inline function get_bpm():Float return _bpm;
	function set_bpm(value:Float):Float {
		if (value < 1) value = 1;
		else if (value > 300) value = 300;
		return _bpm = value;
	}

	inline function get_swing():Float return _swing;
	function set_swing(value:Float):Float {
		if (value < 0) value = 0;
		else if (value >= 1) value = 0;
		return _swing = value;
	}
}


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
			var rate = 1.1 - ((1 + Math.random()*i) / stepCount);
			if (Math.random() < .5) rate = 2 - rate;
			if (rate <= 0) rate = 1;
			
			var e = events[i];
			e.active = Std.int(16 * Math.random()) % Std.int(Math.random() * 16) == 0;
			e.volume = .5 + Math.random() * 2;
			e.pan = Math.random() * ( -.5 + (i / (stepCount * 2)));
			e.rate = rate;
			e.duration = source.buffer.duration * Math.random();
			e.offset = e.duration * Math.random() * .01;
			e.attack = .01 * Math.random();
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


typedef TrackEvent = {
	var id:Int;
	var active:Bool;
	var volume:Float;
	var pan:Float;
	var rate:Float;
	var attack:Float;
	//var release:Float;
	var offset:Float;
	var duration:Float;
}