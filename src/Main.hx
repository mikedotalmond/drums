package;

import js.Browser;
import js.html.*;
import js.html.audio.*;
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
	var analyser:AnalyserNode;
	var outGain:GainNode;

	var analyserData:Uint8Array;

	public function new() {
		super();
		initAudio();
		initPixi();
	}


	function initAudio() {

		audioContext = AudioBase.createContext();
		outGain = audioContext.createGain();
		outGain.gain.value = .2;
		outGain.connect(audioContext.destination);

		analyser = audioContext.createAnalyser();
		analyser.smoothingTimeConstant = 0.5;
		analyser.fftSize = 512;

		analyserData = new Uint8Array(analyser.frequencyBinCount);

		// test
		var samples = new SamplesBasic(audioContext, outGain);
		samples.outGain.connect(analyser);
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

		graphics = new Graphics();
		stage.addChild(graphics);
		stageResized();

		stage.interactive = true;
	}


	function tick(dt:Float) {
		graphics.clear();
		drawWaveform();
	}


	function stageResized() {
		graphics.position.x = 0;
		graphics.position.y = height / 2 - 128;
	}


	function drawWaveform() {

		var data = analyserData;
		var n = data.length;
		var xStep = width / n;

		analyser.getByteTimeDomainData(data);

		graphics.lineStyle(1, 0xffffff);
		graphics.moveTo(0, 256 - data[0]);

		for (i in 0...n) graphics.lineTo(i * xStep, (256 - data[i]));
	}



	static function main() {
		// start up once fonts have loaded
		WebFontEmbed.loaded = function() new Main();
		WebFontEmbed.load();
	}
}
