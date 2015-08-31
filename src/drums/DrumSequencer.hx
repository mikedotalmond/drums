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
	public var playing(default, null):Signal<Bool->Void>;
	public var isPlaying(default, null):Bool;


	public function new(audioContext:AudioContext=null, destination:AudioNode=null) {

		bpm = 120;
		swing = 0;

		playing = new Signal<Bool->Void>();
		isPlaying = false;

		context = (audioContext == null ? AudioBase.createContext() : audioContext);

		output = context.createGain();
		output.connect(destination == null ? context.destination : destination);

		ready = new Signal<Void->Void>();
		tick = new Signal<Int->Float->Void>();
		tracks = [];

		loadSamples();
	}


	public function play(tick:Int = 0) {
		isPlaying = true;
		tickIndex = tick - 1;
		timeTrack.removeAllTimedEvents();
		timeTrack.addTimedEvent(context.currentTime + 1 / 120);
		playing.emit(true);
	}


	public function stop() {
		isPlaying = false;
		tickIndex = -1;
		timeTrack.removeAllTimedEvents();
		playing.emit(false);
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

		if (!isPlaying) return;

		if (time < context.currentTime) time = context.currentTime;
		
		// apply swing
		var offset = .0;
		if (swing > 0) {
			if (tickIndex & 1 == 1) {
				offset = swing * tickLength;
			} else {
				offset = -swing * tickLength;
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


	public function isPlayingIndex(trackIndex:Int) {
		return tracks[trackIndex].events[tickIndex].active;
	}


	function playTick(index:Int, time:Float) {

		for (track in tracks) {
			var event = track.events[index];
			if (event.active) {
				var s = track.source;
				s.volume = event.volume;
				s.attack = event.attack;
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