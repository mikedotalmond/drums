package;

import drums.ui.BeatLines;
import drums.DrumSequencer;
import drums.Oscilliscope;
import drums.ui.Controls;
import drums.ui.SequenceGrid;
import input.KeyCodes;
import js.Browser;
import js.html.*;
import js.html.audio.*;
import js.JQuery;
import parameter.Mapping;
import parameter.Mapping.Interpolation;
import parameter.Mapping.InterpolationNone;
import parameter.Parameter;
import pixi.core.graphics.*;
import pixi.core.text.*;
import pixi.plugins.app.Application; // modified
import tones.*;
import tones.examples.*;
import tones.utils.AudioNodeRecorder;
import util.*;


class Main extends Application {

	public static inline var displayWidth = 900;
	public static inline var displayHeight = 448;

	var graphics:Graphics;

	var audioContext:AudioContext;
	var outGain:GainNode;

	var drums:DrumSequencer;
	var oscilliscope:Oscilliscope;
	var sequenceGrid:SequenceGrid;
	var beatLines:BeatLines;
	var ready:Bool;
	
	var recorder:AudioNodeRecorder;

	public function new() {
		super();

		ready = false;

		initUI();
		initAudio();
		initPixi();

		//initOscilliscope();
		initBeatLines();
		initStepGrid();

		stageResized();

		Browser.window.addEventListener('keydown', function(e:KeyboardEvent) {
			switch(e.keyCode) {
				case KeyCodes.SPACE:
					if (drums.playing) drums.stop();
					else drums.play();
			}
		});
	}
	
	function initUI() {
		
		controls = new Controls();
		
	}


	function initAudio() {
		
		audioContext = AudioBase.createContext();
		
		outGain = audioContext.createGain();
		outGain.gain.value = .25;
		outGain.connect(audioContext.destination);

		drums = new DrumSequencer(audioContext, outGain);
		drums.tick.connect(onSequenceTick);
		drums.ready.connect(onDrumsReady);
		
		recorder = new AudioNodeRecorder(drums.output);
		recorder.wavEncoded.connect(onOutputBufferEncoded);
		
		Reflect.setField(Browser.window,'startRecord',startRecord);
		Reflect.setField(Browser.window,'stopRecord',stopRecord);
		Reflect.setField(Browser.window,'toggleRandomise',toggleRandomise);
	}
	
	function startRecord() {
		trace('recording...');
		recorder.clear();
		recorder.start();
	}
	function stopRecord() {
		trace('stopped recording');
		recorder.stop(); 
		recorder.encodeWAV();
	}
	function onOutputBufferEncoded(data:Blob) {
		trace('Encoded wav - ${(data.size>>10) / 1024} MB  (${data.size} bytes)');
		AudioNodeRecorder.forceDownload(data);
	}


	function onDrumsReady() {
		trace('ready');
		ready = true;
		Browser.document.getElementById('load-spinner').remove();
		Browser.document.getElementById('pixi-container').style.display = '';
		drums.bpm = 60 + Math.random() * 120;
		drums.swing = Math.random()*.5;
		drums.play(0);
	}
	
	var randomise:Bool = true;
	var controls:drums.ui.Controls;
	function toggleRandomise() {
		randomise = !randomise;
		trace('randomise:$randomise');
	}

	function onSequenceTick(index:Int, time:Float) {
		beatLines.tick(index);
		sequenceGrid.tick(index);

		if (randomise) {
			if (index == 0 && Math.random() > .8) {
				drums.tracks[Std.int(Math.random() * 8)].randomise();
			}
			if (Math.random() > .95) {
				drums.tracks[Std.int(Math.random() * 8)].events[Std.int(Math.random() * 16)].active = Math.round(Math.random()) == 1;
			}
		}
	}


	function initPixi() {

		backgroundColor = 0x191B1C;// 0x242627;
		antialias = true;
		onUpdate = tick;
		onResize = stageResized;
		
		width = 898;
		height = 445;
		
		start(Application.AUTO, false, Browser.document.getElementById('pixi-container'));
		stage.x = 1;
	}
	
	override function _onWindowResize(event:Event) {
		width = 898;
		height = 445;
		//height = Browser.window.innerHeight;
		renderer.resize(width, height);
		canvas.style.width = width + "px";
		canvas.style.height = height + "px";
		if (onResize != null) onResize();
	}


	function initOscilliscope() {
		oscilliscope = new Oscilliscope(audioContext, 568, 120);
		stage.addChild(oscilliscope);
		drums.output.connect(oscilliscope.analyser);
	}


	function initBeatLines() {
		beatLines = new BeatLines(displayWidth, displayHeight);
		stage.addChild(beatLines);
	}


	function initStepGrid() {
		sequenceGrid = new SequenceGrid(drums);
		stage.addChild(sequenceGrid);
	}


	function tick(dt:Float) {
		if (!ready) return;
		//oscilliscope.update(dt);
		sequenceGrid.update(dt);
	}


	function stageResized() {
		
		var w2 = (width / 2);
		var h2 = (height / 2);

		sequenceGrid.x = 26;
		sequenceGrid.y = 26;
		
		beatLines.displayHeight = Math.round(height-40);
		beatLines.position.x = sequenceGrid.x;
		beatLines.position.y = 0;

		//oscilliscope.position.x = beatLines.position.x - 2;
		//oscilliscope.position.y = 160 + beatLines.position.y + beatLines.displayHeight/2;
	}


	static function main() {
		// start up once fonts have loaded
		WebFontEmbed.loaded = function() new Main();
		WebFontEmbed.load();
	}
}
