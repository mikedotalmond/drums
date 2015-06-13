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

	static var filenames:Array<String> = ['Kick01', 'Snare01', 'Snare01', 'Rim01', 'Rim02', 'Clave01', 'Clave02', 'Cowbell'];
	static inline var tickLength:Float = 1/4;
	static inline var stepCount:Int = 16;

	var loadCount:Int;
	var tickIndex:Int = -1;
	var lastTick:Int = 0;
	var timeTrack:AudioBase;
	var _bpm:Float;

	public var bpm(get, set):Float;
	public var tracks(default, null):Array<Track>;
	public var tick(default, null):Signal<Int->Void>;
	public var outGain(default, null):GainNode;
	public var context(default, null):AudioContext;
	public var ready(default, null):Signal<Void->Void>;
	public var playing(default, null):Bool;


	public function new(audioContext:AudioContext=null, destination:AudioNode=null) {

		bpm = 120;
		playing = false;

		context = (audioContext == null ? AudioBase.createContext() : audioContext);

		outGain = context.createGain();
		outGain.connect(destination == null ? context.destination : destination);

		ready = new Signal<Void->Void>();
		tick = new Signal<Int->Void>();
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

		tracks[index] = new Track(buffer, context, outGain);
		loadCount++;

		if (loadCount == 1) {
			timeTrack = tracks[0].source;
			timeTrack.timedEvent.connect(onTrackTick);
		} else if (loadCount == filenames.length) {
			ready.emit();
		}
	}


	function onTrackTick(id:Int, time:Float) {

		if (!playing) return;

		if (time < context.currentTime) time = context.currentTime;

		var nextTick = time + TimeUtil.stepTime(tickLength, bpm);

		timeTrack.addTimedEvent(nextTick);

		tick.emit(tickIndex);

		tickIndex++;
		if (tickIndex == stepCount) tickIndex = 0;

		playTick(tickIndex, nextTick);
	}


	function playTick(index:Int, time:Float) {
		for (track in tracks) {
			var event = track.events[index];
			if (event.active) {
				var s = track.source;
				s.volume = event.volume;
				s.playbackRate = event.rate;
				s.release = event.release;
				track.pan = event.pan;
				s.playSample(null, time - context.currentTime);
			}
		}
	}


	inline function get_bpm():Float return _bpm;
	function set_bpm(value:Float):Float {
		if (value < 1) value = 1;
		else if (value > 300) value = 300;
		return _bpm = value;
	}
}


class Track {

	static inline var HALFPI = 1.5707963267948966;
	static inline var stepCount = 16;

	public var events(default, null):Array<TrackEvent>;
	public var source(default, null):Samples;

	public var pan(get, set):Float;

	var _pan:Float = 0;
	var panNode:PannerNode;

	public function new(buffer:AudioBuffer,context:AudioContext, destination:AudioNode) {

		//pan
		panNode = context.createPanner();
		panNode.panningModel = PanningModelType.EQUALPOWER;
		panNode.connect(destination);

		//other fx

		// source
		source = new Samples(context, panNode);
		source.attack = 0;
		source.buffer = buffer;

		events = [for (i in 0...stepCount) { active:false, volume:1, pan:0, rate:1, release:buffer.duration } ];

		//randomise();
	}


	public function randomise() {

		var buffer = source.buffer;

		for (i in 0...stepCount) {
			var rate = 1.1 - ((1 + Math.random()*i) / stepCount);
			if (Math.random() < .5) rate = 2 - rate;
			var e = events[i];
			e.active = Std.int(16 * Math.random()) % Std.int(Math.random() * 16) == 0;
			e.volume = .7 + Math.random() * .3;
			e.pan = Math.random() * ( -.5 + (i / (stepCount * 2)));
			e.rate = rate;
			e.release = buffer.duration / rate;
		}
	}


	public function setEvent(index:Int, active:Bool, ?volume:Float, ?pan:Float, ?rate:Float, ?release:Float) {
		var e = events[index];
		if ((e.active = active)) {
			e.volume = volume;
			e.pan = pan;
			e.rate = rate;
			e.release = release;
		}
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
	var active:Bool;
	var volume:Float;
	var pan:Float;
	var rate:Float;
	var release:Float;
}