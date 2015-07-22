package drums.ui;
import js.Browser;
import js.JQuery;
/**
 * ...
 * @author ...
 */
class Controls {
	var playButton:js.JQuery;
	var stopButton:js.JQuery;
	var randomButton:js.JQuery;
	var recordButton:js.JQuery;
	var muteButton:js.JQuery;
	var unmuteButton:js.JQuery;
	var bpmSlider:js.JQuery;
	var swingSlider:js.JQuery;
	var volumeSlider:js.JQuery;

	public function new() {
		
		playButton = new JQuery('#play-button');
		stopButton = new JQuery('#stop-button');
		
		playButton.on('click tap',  function(_) {
			playButton.css( { display:'none' } );
			stopButton.css( { display:'' } );
		});
		stopButton.on('click tap',  function(_) {
			stopButton.css( { display:'none' } );
			playButton.css( { display:'' } );
		});
		
		randomButton = new JQuery('#shuffle-button');
		recordButton = new JQuery('#record-button');
		
		randomButton.on('click tap',  function(_) {
			randomButton.toggleClass('mdl-button--accent');
		});
		recordButton.on('click tap',  function(_) {
			recordButton.toggleClass('mdl-button--accent');
		});
		
		muteButton = new JQuery('#mute-button');
		unmuteButton = new JQuery('#unmute-button');
		
		muteButton.on('click tap',  function(_) {
			muteButton.css( { display:'none' } );
			unmuteButton.css( { display:'' } );
		});
		unmuteButton.on('click tap',  function(_) {
			unmuteButton.css( { display:'none' } );
			muteButton.css( { display:'' } );
		});
		
		bpmSlider = new JQuery('#bpm-slider');
		swingSlider = new JQuery('#swing-slider');
		volumeSlider = new JQuery('#volume-slider');
		
		bpmSlider.on('change', onBPMSliderChange);
		swingSlider.on('change', onSwingSliderChange);
		volumeSlider.on('change', onVolumeSliderChange);
		
		var button;
		for (i in 0...8) {
			///*
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
	
	function onVolumeSliderChange(_) {
		var val = Std.parseFloat(volumeSlider.val());
		volumeSlider.parent().siblings('div[for="volume-slider"]').text('$val');
	}
	
	function onSwingSliderChange(_) {
		var val = Std.parseFloat(swingSlider.val());
		swingSlider.parent().siblings('div[for="swing-slider"]').text('${val*100}%');
	}
	
	function onBPMSliderChange(_) {
		var val = Std.parseFloat(bpmSlider.val());
		bpmSlider.parent().siblings('div[for="bpm-slider"]').text('$val');
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
	
	


		//var floatTest = new Parameter<Float, InterpolationLinear>('Parameter<Float,InterpolationLinear> test', 0,3.141);
		//var floatTest2 = new Parameter<Float, InterpolationExponential>('Parameter<Float,InterpolationExponential> test 2', 0,3.141);
		//
		//trace(floatTest.mapping);
		//floatTest.setValue(.5,true);
		//trace(floatTest.getValue());
		//trace(floatTest.getValue(true));
		//trace(floatTest2);
		//floatTest2.setValue(.5,true);
		//trace(floatTest2.getValue());
		//trace(floatTest2.getValue(true));
		////
		////
		//var intTest = new Parameter<Int, InterpolationLinear>('Parameter<Int,InterpolationLinear> test', -10, 10);
		//var intTest2 = new Parameter<Int, InterpolationExponential>('Parameter<Int,InterpolationExponential> test', -10, 10);
		//intTest.setDefault(0);
		//trace(intTest);
		//trace(intTest2);
		//trace(intTest.toString());
		//trace(intTest2.toString());
		////
		//var boolTest = new Parameter<Bool, InterpolationNone>('Parameter<Bool> test', false, true);
		//trace(boolTest);
		//trace(boolTest.toString());
	
}