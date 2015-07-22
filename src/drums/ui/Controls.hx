package drums.ui;

import js.Browser;
import js.html.InputElement;
import js.JQuery;
import js.JQuery.JqEvent;

import parameter.Mapping.InterpolationExponential;
import parameter.Mapping.InterpolationLinear;
import parameter.Mapping.InterpolationNone;
import parameter.Parameter;

class Controls {
	
	public var playToggle		:Parameter<Bool,InterpolationNone>;
	public var randomModeToggle	:Parameter<Bool,InterpolationNone>;
	public var recordToggle		:Parameter<Bool,InterpolationNone>;
	public var muteToggle		:Parameter<Bool,InterpolationNone>;

	public var bpm				:Parameter<Int, InterpolationLinear>;
	public var swing			:Parameter<Float, InterpolationLinear>;
	public var volume			:Parameter<Float, InterpolationExponential>;
	
	
	public function new() {
		setupControlBar();
		setupTracks();
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
		
		
		//new JQuery('#swing-slider').on('change', onSwingSliderChange);
		var swingSlider:InputElement = cast byId('swing-slider');
		swing = new Parameter<Float, InterpolationLinear>('swingSlider', Std.parseInt(swingSlider.min), Std.parseFloat(swingSlider.max));
		swing.addObserver(function(p) {
			var val = p.getValue();
			untyped swingSlider.MaterialSlider.change(val);
			new JQuery(swingSlider).parent().siblings('div[for="swing-slider"]').text('${val*100}%');
		});
		new JQuery('#swing-slider').on('change', function(_) { swing.setValue(swingSlider.valueAsNumber); });
		swing.setDefault(swingSlider.valueAsNumber);
		
		
		
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
		var button;
		for (i in 0...8) {
			
			button = new JQuery('#track-shuffle-$i');
			button.on('click tap', onTrackShuffle.bind(i, _));
			
			new JQuery('#track-mute-$i').on('click tap', function(e) {
				var button = new JQuery('#track-mute-$i');
				button.toggleClass('mdl-button--accent'); 
				onTrackMute(i, button.hasClass('mdl-button--accent'));				
			});
			
			new JQuery('#track-solo-$i').on('click tap', function(e) {
				var button = new JQuery('#track-solo-$i');
				button.toggleClass('mdl-button--accent'); 
				onTrackSolo(i, button.hasClass('mdl-button--accent'));
			});
		}
	}
	
	
	
	function onTrackSolo(index:Int, state:Bool) {
		trace(index, state);
	}
	
	function onTrackMute(index:Int, state:Bool) {
		trace(index, state);
	}
	
	function onTrackShuffle(index:Int, _) {
		trace(index);
	}
}