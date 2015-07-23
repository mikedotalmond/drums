package drums.ui;

import hxsignal.Signal;
import input.KeyCodes;
import js.Browser;
import js.html.InputElement;
import js.html.Int8Array;
import js.html.KeyboardEvent;
import js.JQuery;
import js.JQuery.JqEvent;

import parameter.Mapping.InterpolationExponential;
import parameter.Mapping.InterpolationLinear;
import parameter.Mapping.InterpolationNone;
import parameter.Parameter;

class Controls {
	
	public var playToggle	(default, null):Parameter<Bool,InterpolationNone>;
	public var randomModeToggle	(default, null):Parameter<Bool,InterpolationNone>;
	public var recordToggle	(default, null):Parameter<Bool,InterpolationNone>;
	public var muteToggle	(default, null):Parameter<Bool,InterpolationNone>;

	public var bpm			(default, null):Parameter<Int, InterpolationLinear>;
	public var swing		(default, null):Parameter<Float, InterpolationLinear>;
	public var volume		(default, null):Parameter<Float, InterpolationExponential>;
	
	public var trackMute	(default, null):Signal<Int->Bool->Void>;
	public var trackSolo	(default, null):Signal<Int->Bool->Void>;
	public var trackShuffle	(default, null):Signal<Int->Void>;
	
	public var muteTracks	(default, null):Int8Array;
	public var soloTracks	(default, null):Int8Array;
	
	inline public function trackIsMuted(index) return muteTracks[index] == 1;
	inline public function trackIsSolo(index) return soloTracks[index] == 1;
	
	/**
	 * wire up html controls with parameters for programatic control/access
	 */
	public function new() {
		
		setupControlBar();
		setupTracks();
		
		Browser.window.addEventListener('keydown', onKeyDown);
		
		muteTracks = new Int8Array([0, 0, 0, 0, 0, 0, 0, 0]);
		soloTracks = new Int8Array([0, 0, 0, 0, 0, 0, 0, 0]);
	}
	
	function onKeyDown(e:KeyboardEvent) {
		if (e.ctrlKey) return;
		
		switch(e.keyCode) {
			case KeyCodes.SPACE, KeyCodes.NUMBER_1: 
				playToggle.setValue(!playToggle.getValue());
				
			case KeyCodes.R, KeyCodes.NUMBER_2:
				randomModeToggle.setValue(!randomModeToggle.getValue());
				
			case KeyCodes.NUMBER_3, KeyCodes.SHIFT: 
				recordToggle.setValue(!recordToggle.getValue());
				
			case KeyCodes.NUMBER_4, KeyCodes.M: 
				muteToggle.setValue(!muteToggle.getValue());
				
			case KeyCodes.NUMPAD_ADD, KeyCodes.EQUALS:
				var val = volume.getValue(true) + .1;
				if (val > 1) val = 1;
				volume.setValue(val, true);
				
			case KeyCodes.MINUS, KeyCodes.NUMPAD_SUBTRACT:
				var val = volume.getValue(true) - .1;
				if (val < 0) val = 0;
				volume.setValue(val, true);
		}
	}
	
	
	function setupControlBar() {
		var byId = Browser.document.getElementById;
		
		//
		playToggle = new Parameter<Bool,InterpolationNone>('playToggle', true, false);
		playToggle.addObserver(function(p) {
			var state = p.getValue();
			byId('play-button').style.display = state ? 'none' : '';
			byId('stop-button').style.display = state ? '' : 'none';
		});
		new JQuery('#play-button').on('click tap',  function(_) { playToggle.setValue(true); });
		new JQuery('#stop-button').on('click tap',  function(_) { playToggle.setValue(false); });
		
		//
		var randomButton = byId('shuffle-button');
		randomModeToggle = new Parameter<Bool,InterpolationNone>('randomModeToggle', false, true);
		randomModeToggle.addObserver(function(p) {
			if (p.getValue()) randomButton.classList.add('mdl-button--accent');
			else randomButton.classList.remove('mdl-button--accent');
		});
		new JQuery(randomButton).on('click tap',  function(_) { randomModeToggle.setValue(!randomModeToggle.getValue()); });
		
		//
		var recordButton =  byId('record-button');
		recordToggle = new Parameter<Bool,InterpolationNone>('recordToggle', false, true);
		recordToggle.addObserver(function(p) {
			if (p.getValue()) recordButton.classList.add('mdl-button--accent');
			else recordButton.classList.remove('mdl-button--accent');
		});
		new JQuery(recordButton).on('click tap',  function(_) { recordToggle.setValue(!recordToggle.getValue()); });
		
		
		//
		var bpmSlider:InputElement = cast byId('bpm-slider');
		bpm = new Parameter<Int,InterpolationLinear>('bpmSlider', Std.parseInt(bpmSlider.min), Std.parseInt(bpmSlider.max));
		bpm.addObserver(function(p) {
			var val = p.getValue();
			untyped bpmSlider.MaterialSlider.change(val);
			new JQuery(bpmSlider).parent().siblings('div[for="bpm-slider"]').text('${val}');
		});
		new JQuery('#bpm-slider').on('change', function(_) { bpm.setValue(Std.int(bpmSlider.valueAsNumber)); });
		bpm.setDefault(Std.int(bpmSlider.valueAsNumber));
		
		
		//
		var swingSlider:InputElement = cast byId('swing-slider');
		swing = new Parameter<Float, InterpolationLinear>('swingSlider', Std.parseInt(swingSlider.min), Std.parseFloat(swingSlider.max));
		swing.addObserver(function(p) {
			var val = p.getValue();
			untyped swingSlider.MaterialSlider.change(val);
			new JQuery(swingSlider).parent().siblings('div[for="swing-slider"]').text('${val*100}%');
		});
		new JQuery('#swing-slider').on('change', function(_) { swing.setValue(swingSlider.valueAsNumber); });
		swing.setDefault(swingSlider.valueAsNumber);
		
		//
		var volumeSlider:InputElement = cast byId('volume-slider');
		volume = new Parameter<Float, InterpolationExponential>('volumeSlider', Std.parseInt(volumeSlider.min), Std.parseFloat(volumeSlider.max));
		volume.addObserver(function(p) {
			var normValue = p.getValue(true);
			untyped volumeSlider.MaterialSlider.change(normValue);
			new JQuery(volumeSlider).parent().siblings('div[for="volume-slider"]').text('${normValue}');
		});
		new JQuery('#volume-slider').on('change', function(_) { volume.setValue(volumeSlider.valueAsNumber, true); });
		volume.setDefault(volumeSlider.valueAsNumber, true);
		
		//
		muteToggle = new Parameter<Bool,InterpolationNone>('muteToggle', false, true);
		muteToggle.addObserver(function(p) {
			var state = p.getValue();
			if (state) untyped volumeSlider.MaterialSlider.disable();
			else untyped volumeSlider.MaterialSlider.enable();
			byId('mute-button').style.display = state ? 'none' : '';
			byId('unmute-button').style.display = state ? '' : 'none';
		});
		new JQuery('#mute-button').on('click tap',  function(_) { muteToggle.setValue(true); });
		new JQuery('#unmute-button').on('click tap',  function(_) { muteToggle.setValue(false); });
	}
	
	
	function setupTracks() {
		
		trackShuffle = new Signal<Int->Void>();
		trackMute = new Signal<Int->Bool->Void>();
		trackSolo = new Signal<Int->Bool->Void>();
		
		trackMute.connect(function(i, state) {
			if (state) new JQuery('#track-mute-$i').addClass('mdl-button--accent');	
			else new JQuery('#track-mute-$i').removeClass('mdl-button--accent');
			muteTracks[i] = state ? 1 : 0;
		});
		
		trackSolo.connect(function(i, state) {
			if (state) new JQuery('#track-solo-$i').addClass('mdl-button--accent');	
			else new JQuery('#track-solo-$i').removeClass('mdl-button--accent');
			soloTracks[i] = state ? 1 : 0;
		});
		
		for (i in 0...8) {
			
			new JQuery('#track-shuffle-$i')
				.on('click tap',  function(_) {
					trackShuffle.emit(i);
				});
			
			new JQuery('#track-mute-$i')
				.on('click tap', function(_) {
					trackMute.emit(i, !new JQuery('#track-mute-$i').hasClass('mdl-button--accent'));
				});
			
			new JQuery('#track-solo-$i')
				.on('click tap', function(_) {
					trackSolo.emit(i, !new JQuery('#track-solo-$i').hasClass('mdl-button--accent'));
				});
		}
	}
}