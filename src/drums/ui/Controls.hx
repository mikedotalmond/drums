package drums.ui;
import js.Browser;
import js.JQuery;
/**
 * ...
 * @author ...
 */
class Controls {

	public function new() {
		
		var playButton = new JQuery('#play-button');
		var stopButton = new JQuery('#stop-button');
		var randomButton = new JQuery('#shuffle-button');
		var recordButton = new JQuery('#record-button');
		
		playButton.on('click tap',  function(_) {
			playButton.css( { display:'none' } );
			stopButton.css( { display:'' } );
		});
		stopButton.on('click tap',  function(_) {
			stopButton.css( { display:'none' } );
			playButton.css( { display:'' } );
		});
		
		randomButton.on('click tap',  function(_) {
			randomButton.toggleClass('mdl-button--primary');
		});
		recordButton.on('click tap',  function(_) {
			recordButton.toggleClass('mdl-button--primary');
		});
		
		/*
		
		'bpm-slider'
		'swing-slider'
		'volume-slider'
		'mute-button'
		'unmute-button'
		
		'track-shuffle-$i'
		'track-mute-$i'
		'track-solo-$i'
		*/
		
		/*mdl-button--primary */
		/*mdl-button--colored*/
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