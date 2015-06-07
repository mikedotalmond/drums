package tones.examples;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;
import js.html.XMLHttpRequestResponseType;

import tones.Samples;
import tones.utils.NoteFrequencyUtil;
import tones.utils.TimeUtil;
import tones.data.OscillatorType;

import js.html.XMLHttpRequest;
/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class SamplesBasic {

	var tones:Tones;
	var samples:Samples;

	var restartId:Int;
	public var buffer(default, null):AudioBuffer;
	public var outGain(default, null):GainNode;
	public var context(default, null):AudioContext;

	public function new(audioContext:AudioContext=null, destination:AudioNode=null) {

		context = (audioContext == null ? AudioBase.createContext() : audioContext);

		outGain = context.createGain();
		outGain.connect(destination == null ? context.destination : destination);

		tones = new Tones(context, outGain);
		tones.type = OscillatorType.SQUARE;
		tones.attack = 0.01;
		tones.release = .5;
		tones.volume = 1;

		samples = new Samples(context, outGain);
		samples.itemBegin.connect(onSampleBegin);

		var request = new XMLHttpRequest();
		request.open("GET", 'data/samples/kick.wav', true);
		request.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
		request.onload = function(_) samples.context.decodeAudioData(_.currentTarget.response, sampleDecoded);
		request.send();

	}

	function sampleDecoded(buffer:AudioBuffer) {
		this.buffer = buffer;

		samples.attack = 0;

		// play it pitched up a bit (5 tones)
		var rate = NoteFrequencyUtil.rateFromNote(5, 0, 0);

		samples.release = buffer.duration / rate;
		samples.playbackRate = rate;

		restartId = samples.lastId;
		samples.playSample(buffer, .5);
	}

	function onSampleBegin(id:Int, time:Float) {

		#if debug
		trace('sample $id starts at $time (in ${time - context.currentTime})');
		#end

		if (id == restartId) {
			var delay = time - context.currentTime;
			if (delay < 0) delay = 0;
			playSequence(delay);
		}
	}

	function playSequence(delay:Float=0) {

		tones.volume = .8;
		tones.playFrequency(55, delay+TimeUtil.stepTime(1.5));
		tones.playFrequency(110, delay+TimeUtil.stepTime(4));
		tones.playFrequency(55, delay+TimeUtil.stepTime(4.5));
		tones.playFrequency(110, delay+TimeUtil.stepTime(6));
		tones.playFrequency(55, delay+TimeUtil.stepTime(7.5));

		samples.volume = 1;
		samples.playSample(buffer, delay + TimeUtil.stepTime(1));
		samples.playSample(buffer, delay + TimeUtil.stepTime(2));
		samples.playSample(buffer, delay + TimeUtil.stepTime(3));
		samples.playSample(buffer, delay + TimeUtil.stepTime(4));
		samples.playSample(buffer, delay + TimeUtil.stepTime(5));
		samples.playSample(buffer, delay + TimeUtil.stepTime(6));
		samples.playSample(buffer, delay + TimeUtil.stepTime(6.25));
		samples.playSample(buffer, delay + TimeUtil.stepTime(6.5));
		samples.playSample(buffer, delay + TimeUtil.stepTime(6.75));
		samples.playSample(buffer, delay + TimeUtil.stepTime(7));
		samples.playSample(buffer, delay + TimeUtil.stepTime(7.25));
		samples.playSample(buffer, delay + TimeUtil.stepTime(7.5));
		samples.playSample(buffer, delay + TimeUtil.stepTime(7.75));
		restartId = samples.playSample(buffer, delay + TimeUtil.stepTime(8));
	}
}