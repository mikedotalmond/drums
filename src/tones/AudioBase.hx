package tones;

import hxsignal.Signal;
import js.Browser;
import tones.data.ItemData;
import tones.utils.TimeUtil;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;


/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class AudioBase {

	static inline function isFirefox() return Browser.navigator.userAgent.indexOf('Firefox') > -1;

	public static function createContext():AudioContext {
		return untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
	}

	public var context(default, null):AudioContext;
	public var destination(default, null):AudioNode;

	public var now(get, never):Float;

	public var attack	(get, set):Float; // seconds
	public var release	(get, set):Float; // seconds
	public var volume	(get, set):Float;

	public var lastId		(default, null):Int;
	public var polyphony	(default, null):Int;
	public var activeItems	(default, null):Map<Int, ItemData>;
	public var itemBegin	(default, null):Signal<Int->Float->Void>;
	public var itemRelease	(default, null):Signal<Int->Float->Void>;
	public var itemEnd		(default, null):Signal<Int->Void>;
	public var timedEvent	(default, null):Signal<Int->Float->Void>;

	var ID:Int = 0;
	var _attack:Float;
	var _release:Float;
	var _volume:Float;
	var releaseFudge:Float;
	var lastTime:Float = .0;

	var delayedBegin:Array<{id:Int, time:Float}>;
	var delayedRelease:Array<{id:Int, time:Float}>;
	var delayedEnd:Array<{id:Int, time:Float}>;
	var timedEvents:Array<{id:Int, time:Float}>;

	/**
	 * @param	audioContext 	- optional. Pass an exsiting audioContext here to share it.
	 * @param	destinationNode - optional. Pass a custom destination AudioNode to connect to.
	 */
	public function new(audioContext:AudioContext = null, ?destinationNode:AudioNode = null) {

		if (audioContext == null) {
			context = AudioBase.createContext();
		} else {
			context = audioContext;
		}

		if (destinationNode == null) destination = context.destination;
		else destination = destinationNode;

		delayedBegin = [];
		delayedRelease = [];
		delayedEnd = [];
		timedEvents = [];

		lastId = ID;
		polyphony = 0;
		activeItems = new Map<Int, ItemData>();
		itemRelease = new Signal<Int->Float->Void>();
		itemBegin = new Signal<Int->Float->Void>();
		itemEnd = new Signal<Int->Void>();
		timedEvent = new Signal<Int->Float->Void>();
		// Hmm - Firefox (dev) appears to need the setTargetAtTime time to be a bit in the future for it to work in the release phase.
		// (apparently about 4096 samples worth of data (1 buffer perhaps?))
		// If I use context.currentTime the setTargetAtTime will not fade-out, it just ends aruptly.
		// Even with this delay in place it's still occasionaly glitchy...
		// Works fine in Chrome
		releaseFudge = isFirefox() ? (4096 / context.sampleRate) : 0;

		// set some reasonable defaults
		attack 	= 0.0;
		release = 1.0;
		volume 	= .2;

		#if debug
		itemBegin.connect(function(id, time) {
			trace('itemBegin | id:$id, time:$time');
		});
		itemRelease.connect(function(id, time) {
			trace('itemRelease | id:$id, time:$time');
		});
		itemEnd.connect(function(id) {
			trace('itemEnd | id:$id, time:${now}');
		});
		timedEvent.connect(function(id, time) {
			trace('timedEvent | id:$id, time:${time}');
		});
		#end

		TimeUtil.frameTick.connect(tick);
	}


	inline function nextID() {
		lastId = ID; ID++;
		return lastId;
	}


	/**
	 *
	 * @param	id - item id
	 * @param	delay - in seconds, relative to the current context time
	 */
	public function releaseAfter(id:Int, delay:Float) {
		doRelease(id, now + delay);
	}


	/**
	 *
	 * @param	id - item id
	 * @param	atTime - the context time to release at. Don't pass anything and release begins immediately.
	 */
	public function doRelease(id:Int, atTime:Float=-1) {
		var data = getItemData(id);
		if (data == null) return;

		var time;
		var nowTime = now;

		if (atTime < nowTime) time = nowTime;
		else time = atTime;

		time += releaseFudge;

		data.env.gain.cancelScheduledValues(time);
		data.env.gain.setTargetAtTime(0, time, TimeUtil.getTimeConstant(release));

		delayedRelease.push( { id:id, time:time } );
		delayedEnd.push( { id:id, time:time + release } );
	}


	public function releaseAll(atTime:Float = -1) {
		for (id in activeItems.keys()) doRelease(id, atTime);
	}


	public function stopAll() {
		for (id in activeItems.keys()) doStop(id);
	}


	/**
	 * Stop and disconnect nodes after release completes
	 * @param	id
	 */
	public function doStop(id:Int) {
		var data = cast activeItems.get(id);
		if (data == null) return;

		data.src.stop(now);
		data.src.disconnect();

		data.env.gain.cancelScheduledValues(now);
		data.env.disconnect();

		triggerItemEnd(id);

		activeItems.remove(id);
	}


	/**
	 * The ItemData for an active item (src,env,settings,etc)
	 * @param	id
	 * @return	ItemData
	 */
	inline public function getItemData(id:Int):ItemData return activeItems.get(id);



	/**
	 * @param	time
	 * @return	id
	 */
	public function addTimedEvent(time:Float):Int {
		if (time < now) return -1;

		var id = nextID();
		timedEvents.push({id:id, time:time});

		return id;
	}

	public function removeTimedEvent(id:Int):Bool {
		var n = timedEvents.length;
		var i = 0;
		while (i < n) {
			if (timedEvents[i].id == id) {
				timedEvents.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	public function removeAllTimedEvents():Void {
		timedEvents = [];
	}


	// get / set

	/**
	 * The current audio-context time
	 * @return
	 **/
	inline function get_now() return context.currentTime;


	inline function get_attack():Float return _attack;
	function set_attack(value:Float):Float {
		if (value < 0.001) value = 0.001;
		return _attack = value;
	}

	inline function get_release():Float return _release;
	function set_release(value:Float):Float {
		if (value < 0.001) value = 0.001;
		return _release = value;
	}

	inline function get_volume():Float return _volume;
	function set_volume(value:Float):Float {
		if (value < 0) value = 0;
		else if (value > 1) value = 1;
		return _volume = value;
	}


	// internal
	function triggerItemBegin(id:Int, time:Float):Void {
		polyphony++;
		itemBegin.emit(id, time);
	}

	function triggerItemEnd(id:Int):Void {
		polyphony--;
		itemEnd.emit(id);
	}


	function tick(_) {

		// regularly check for delayed starts, releases, and stops
		// in a requestAnimationFrame callback instead of creating
		// lots of anonymous Timer.delay callbacks
		// no function allocations, just array modification
		// could optimise further if there was a maximum polyphony limit...

		var t = now;
		var dt = t - lastTime;

		lastTime = t;

		t += (dt+dt);
		// Estimated 'next+1' frame-time
		// If an audio event is going to happen between frames, then we want to make sure the signal is triggered beforehand.
		// Passing the actual audio context time of the event in the signal being triggered allows for accurate sync.
		var j = 0;
		var n = timedEvents.length;
		while (j < n) {
			var item = timedEvents[j];
			if (t > item.time) {
				timedEvent.emit(item.id, item.time);
				timedEvents.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}

		var j = 0;
		var n = delayedBegin.length;
		while (j < n) {
			var item = delayedBegin[j];
			if (t > item.time) {
				triggerItemBegin(item.id, item.time);
				delayedBegin.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}

		j = 0;
		n = delayedRelease.length;
		while (j < n) {
			var item = delayedRelease[j];
			if (t > item.time) {
				itemRelease.emit(item.id, item.time);
				delayedRelease.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}

		j = 0;
		n = delayedEnd.length;
		while (j < n) {
			var item = delayedEnd[j];
			if (lastTime >= item.time) {
				doStop(item.id);
				delayedEnd.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}
	}
}