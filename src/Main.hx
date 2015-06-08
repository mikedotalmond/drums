package;

import drums.BeatLines;
import drums.DrumSequencer;
import drums.Oscilliscope;
import js.Browser;
import js.html.*;
import js.html.audio.*;
import pixi.core.display.Container;
import tones.utils.TimeUtil;

import pixi.core.graphics.*;
import pixi.core.text.*;

import pixi.plugins.app.Application; // modified

import tones.*;
import tones.examples.*;

import util.*;


class Main extends Application {

	var graphics:Graphics;

	var audioContext:AudioContext;
	var outGain:GainNode;

	var drums:DrumSequencer;
	var oscilliscope:Oscilliscope;
	var beatLines:BeatLines;

	public function new() {
		super();

		initAudio();
		initPixi();

		initBeatLines();
		initStepGrid();
		initOscilliscope();

		stageResized();
	}


	function initAudio() {

		audioContext = AudioBase.createContext();
		outGain = audioContext.createGain();
		outGain.gain.value = .2;
		outGain.connect(audioContext.destination);

		drums = new DrumSequencer(audioContext, outGain);
		drums.tick.connect(onSequenceTick);
	}

	function onSequenceTick(index:Int) {
		beatLines.tick(index);
	}


	function initPixi() {

		backgroundColor = 0x333333;
		antialias = true;
		onUpdate = tick;
		onResize = stageResized;

		start(Application.AUTO);

		var txt = new Text('Just a test...', {font : 'normal 24px Raleway', fill : 'white', align : 'lefts'});
		stage.addChild(txt);
		txt.position.x = 10;
		txt.position.y = 10;

		stage.interactive = true;
	}


	function initOscilliscope() {
		oscilliscope = new Oscilliscope(audioContext, 640, 320);
		//stage.addChild(oscilliscope);
		drums.outGain.connect(oscilliscope.analyser);
	}


	function initBeatLines() {
		beatLines = new BeatLines(600, 320);
		stage.addChild(beatLines);
	}


	function initStepGrid() {

	}


	function tick(dt:Float) {
		oscilliscope.update(dt);
	}


	function stageResized() {
		var w2 = width / 2;
		var h2 = height / 2;

		beatLines.position.x = w2 - beatLines.displayWidth / 2;
		beatLines.position.y = h2 - beatLines.displayHeight / 2;

		oscilliscope.position.x = w2 - oscilliscope.displayWidth / 2;
		oscilliscope.position.y = h2 - oscilliscope.displayHeight / 2;


	}


	static function main() {
		// start up once fonts have loaded
		WebFontEmbed.loaded = function() new Main();
		WebFontEmbed.load();
	}
}
