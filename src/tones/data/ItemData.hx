package tones.data;

/**
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import js.html.audio.GainNode;

import js.html.audio.AudioNode;
import js.html.audio.OscillatorNode;
import js.html.audio.AudioBufferSourceNode;

typedef ItemData = {
	var id:Int;
	var src:haxe.extern.EitherType<AudioBufferSourceNode, OscillatorNode>;
	var env:GainNode;
	var triggerTime:Float;
	var attack:Float;
	var release:Float;
	var volume:Float;
}