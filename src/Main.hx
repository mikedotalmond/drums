package;

import drums.BeatLines;
import drums.DrumSequencer;
import drums.Oscilliscope;
import drums.SequenceGrid;
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
	var sequenceGrid:SequenceGrid;
	var beatLines:BeatLines;
	var ready:Bool;

	public function new() {
		super();

		ready = false;

		initAudio();
		initPixi();

		initOscilliscope();
		initBeatLines();
		initStepGrid();

		stageResized();
	}


	function initAudio() {

		audioContext = AudioBase.createContext();
		outGain = audioContext.createGain();
		outGain.gain.value = .2;
		outGain.connect(audioContext.destination);

		drums = new DrumSequencer(audioContext, outGain);
		drums.tick.connect(onSequenceTick);
		drums.ready.connect(onDrumsReady);
	}


	function onDrumsReady() {
		ready = true;
	}


	function onSequenceTick(index:Int) {
		beatLines.tick(index);
		sequenceGrid.tick(index);
	}


	function initPixi() {

		backgroundColor = 0x333333;
		antialias = true;
		onUpdate = tick;
		onResize = stageResized;

		start(Application.AUTO);

		var txt = new Text('Drums', {font : 'normal 24px Raleway', fill : 'white', align : 'lefts'});
		stage.addChild(txt);
		txt.position.x = 10;
		txt.position.y = 10;

		stage.interactive = true;
	}


	function initOscilliscope() {
		oscilliscope = new Oscilliscope(audioContext, 568, 120);
		stage.addChild(oscilliscope);
		drums.outGain.connect(oscilliscope.analyser);
	}


	function initBeatLines() {
		beatLines = new BeatLines(600, 320);
		stage.addChild(beatLines);
	}


	function initStepGrid() {
		sequenceGrid = new SequenceGrid(600,320, drums);
		stage.addChild(sequenceGrid);
	}


	function tick(dt:Float) {
		if (!ready) return;
		oscilliscope.update(dt);
		sequenceGrid.update(dt);
	}


	function stageResized() {
		var w2 = (width / 2) + 20;
		var h2 = (height / 2) - 40;

		beatLines.position.x = w2 - beatLines.displayWidth / 2;
		beatLines.position.y = h2 - beatLines.displayHeight / 2;

		sequenceGrid.x = beatLines.position.x;
		sequenceGrid.y = beatLines.position.y;

		oscilliscope.position.x = beatLines.position.x - 2;
		oscilliscope.position.y = 160 + beatLines.position.y + beatLines.displayHeight/2;
	}


	static function main() {
		// start up once fonts have loaded
		WebFontEmbed.loaded = function() new Main();
		WebFontEmbed.load();
	}
}
