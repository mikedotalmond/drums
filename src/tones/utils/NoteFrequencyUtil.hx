package tones.utils;

import js.html.Float32Array;

/**
* ...
* @author Mike Almond 
*/
class NoteFrequencyUtil {
	
	static inline var defaultTuning	:Float = 440.0; // a440
	
	static inline var LOG2E			:Float = 1.4426950408889634; //Math.LOG2E
	
	static inline var Twelveth		:Float = 1 / 12;
	static inline var centExp		:Float = 1 / 1200;
	
	public static var pitchNames	(default, null):Array<String>;
	public static var altPitchNames	(default, null):Array<String>;
	
	var noteFrequencies		:Float32Array;
	var noteNames			:Array<String>;
	var invTuningBase		:Float;
	
	public function new() {
		
		if (pitchNames == null) {
			pitchNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
			altPitchNames = [null, 'Db', null, 'Eb', null, null, 'Gb', null, 'Ab', null, 'Bb', null];
		}
		
		noteFrequencies	= new Float32Array(128);
		noteNames = [];

		_octaveMiddleC = 3;
		tuningBase = defaultTuning;
	}
	
	
	function reset() {
		for(i in 0...128) {
			noteNames[i] 		= indexToName(i);
			noteFrequencies[i] 	= indexToFrequency(i);
		}
	}
	
	/**
	 * 
	 * @param	index [0-127]
	 * @return
	 */
	public inline function noteIndexToFrequency(index:Int):Float {
		if (index >= 0 && index < 128) return noteFrequencies[index];
		return Math.NaN;
	}
	
	public function noteIndexToFrequencyWithDetune(index:Int, cents:Int = 0):Float {
		if (index >= 0 && index < 128) {
			if (cents == 0) return noteFrequencies[index];				
			else if (cents < 0) return noteFrequencies[index] / Math.pow(2, -cents * centExp);
			else return noteFrequencies[index] * Math.pow(2, cents * centExp);
		}
		return Math.NaN;
	}
	
	public inline function frequencyToNoteIndex(frequency:Float):Int {
		return Std.int(frequencyToNote(frequency));
	}
	
	/**
	 * 
	 * @param	index [0-127]
	 * @return
	 */
	public inline function noteIndexToName(index:Int):String {
		if (index>=0 && index < 128) return noteNames[index];
		return null;
	}
	
	/**
	 * 
	 * @param	name - Note name eg : 'A3' 'C#3' 'Gb1' 'C#-2'
	 * 					Lowest is  'C-2' (C minus-two)
	 * @return
	 */
	public function noteNameToIndex(name:String):Int{
		var hasAlternate = name.indexOf("/");
		if (hasAlternate != -1) name = name.substring(0, hasAlternate);
		var s;
		var i = noteNames.length;
		while(--i > -1){
			s = noteNames[i];
			if (s.indexOf(name) > -1) return i;
		}
		return -1;
	}
	
	/**
	 * 
	 * @param	name
	 * @return
	 */
	public function noteNameToFrequency(name:String):Float {
		var i = noteNameToIndex(name);
		return i > -1 ? indexToFrequency(i) : Math.NaN;
	}

	
	
	/**
	 * conversion functions
	 * */
	inline function indexToFrequency(index:Int):Float {
		//(index - 69.0) == distance in tones to A440 / A3 -- taking note index-zero to be the lowest note, C-2
		return tuningBase * Math.pow(2, (index - 69.0) * Twelveth);
	}
	
	inline function frequencyToNote(frequency:Float):Float {
		return 12 * (Math.log(frequency * invTuningBase) * LOG2E) + 57;
	}
	
	function indexToName(index:Int):String{
		var	pitch	:Int 	= index % 12;
		var octave	:Int 	= (Std.int(index * Twelveth) - (5 - octaveMiddleC));
		var noteName:String = pitchNames[pitch] + octave;
		if (altPitchNames[pitch]!=null) noteName += "/" + altPitchNames[pitch] + octave;
		return noteName;
	}
	
	
	
	/**
	 * Get/Set the base frequency for tuning - defaults to 440Hz (A440)
	 */
	var _tuningBase:Float;
	public var tuningBase(get_tuningBase,set_tuningBase):Float;
	function get_tuningBase():Float { return _tuningBase; }
	function set_tuningBase(value:Float):Float {
		_tuningBase 	= value;
		invTuningBase 	= 1.0 / (_tuningBase * 0.5);
		reset();
		return _tuningBase;
	}
	
	/**
	 * 
	 */
	var _octaveMiddleC:Int;
	public var octaveMiddleC(get_octaveMiddleC, set_octaveMiddleC):Int;
	function get_octaveMiddleC():Int { return _octaveMiddleC; }
	function set_octaveMiddleC(value:Int):Int {
		_octaveMiddleC = value;
		reset();
		return value;
	}
	
	
	/**
	 * Detune a given (note) frequency by a set number of cents (cent = note/100)
	 * @param	freq
	 * @param	cents
	 * @return
	 */
	public static function detuneFreq(freq:Float, cents:Float):Float {
		if (cents < 0) return freq / Math.pow(2, -cents * centExp);
		else if (cents > 0) return freq * Math.pow(2, cents * centExp);
		return freq; 
	}
	
	/**
	 * 
	 * @param	note The destination key
	 * @param	cents Detune cents
	 * @param	root The root key
	 * @return	Playback rate for the destination key, given the root key
	 */
	public static inline function rateFromNote(note:Float, cents:Float, root:Float):Float {
		return (12 + note + (cents*0.01) - root) * Twelveth;
	}
	
	/**
	 * get the note value of a sample playing at [rate] with the root key of [root]
	 * @param	rate
	 * @param	root
	 * @return	Note index of the sample
	 */
	public static inline function noteFromRate(rate:Float, root:Int):Int {
		return Std.int(root + (rate * 12));
	}
	
	/**
	 * Typically used to get the playback rate for a sample generator being used as a waveform PCM synthesis / waveform generator
	 * @param	frequency		- required frequency
	 * @param	rootFrequency	- root frequency of the waveform
	 * @return
	 * */
	public static inline function rateFromFrequency(frequency:Float, rootFrequency:Float):Float {
		return frequency / rootFrequency;
	}
}