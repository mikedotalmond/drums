(function (console) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,__class__: List
};
var pixi_plugins_app_Application = function() {
	this.lastTime = window.performance.now();
	this._setDefaultValues();
};
pixi_plugins_app_Application.__name__ = true;
pixi_plugins_app_Application.prototype = {
	set_fps: function(val) {
		this.frameCount = 0;
		return this.fps = val >= 1 && val < 60?val | 0:60;
	}
	,set_skipFrame: function(val) {
		if(val) {
			console.log("pixi.plugins.app.Application > Deprecated: skipFrame - use fps property and set it to 30 instead");
			this.set_fps(30);
		}
		return this.skipFrame = val;
	}
	,_setDefaultValues: function() {
		this.pixelRatio = 1;
		this.set_skipFrame(false);
		this.autoResize = true;
		this.transparent = false;
		this.antialias = false;
		this.forceFXAA = false;
		this.backgroundColor = 16777215;
		this.width = window.innerWidth;
		this.height = window.innerHeight;
		this.set_fps(60);
	}
	,start: function(renderer,stats,parentDom) {
		if(stats == null) stats = true;
		if(renderer == null) renderer = "auto";
		var tmp;
		var _this = window.document;
		tmp = _this.createElement("canvas");
		this.canvas = tmp;
		this.canvas.style.width = this.width + "px";
		this.canvas.style.height = this.height + "px";
		this.canvas.style.position = "absolute";
		if(parentDom == null) parentDom = window.document.body;
		this.stage = new PIXI.Container();
		var renderingOptions = { };
		renderingOptions.view = this.canvas;
		renderingOptions.backgroundColor = this.backgroundColor;
		renderingOptions.resolution = this.pixelRatio;
		renderingOptions.antialias = this.antialias;
		renderingOptions.forceFXAA = this.forceFXAA;
		renderingOptions.autoResize = this.autoResize;
		renderingOptions.transparent = this.transparent;
		if(renderer == "auto") this.renderer = PIXI.autoDetectRenderer(this.width,this.height,renderingOptions); else if(renderer == "canvas") this.renderer = new PIXI.CanvasRenderer(this.width,this.height,renderingOptions); else this.renderer = new PIXI.WebGLRenderer(this.width,this.height,renderingOptions);
		parentDom.appendChild(this.renderer.view);
		if(this.autoResize) window.onresize = $bind(this,this._onWindowResize);
		tones_utils_TimeUtil.get_frameTick().connect($bind(this,this.onRequestAnimationFrame));
		this.lastTime = window.performance.now();
		if(stats) this.addStats();
	}
	,_onWindowResize: function(event) {
		this.width = window.innerWidth;
		this.height = window.innerHeight;
		this.renderer.resize(this.width,this.height);
		this.canvas.style.width = this.width + "px";
		this.canvas.style.height = this.height + "px";
		if(this.stats != null) {
			this.stats.domElement.style.top = "2px";
			this.stats.domElement.style.right = "2px";
		}
		if(this.onResize != null) this.onResize();
	}
	,onRequestAnimationFrame: function(_) {
		this.frameCount++;
		if(this.frameCount == (60 / this.fps | 0)) {
			this.frameCount = 0;
			this.calculateElapsedTime();
			if(this.onUpdate != null) this.onUpdate(this.elapsedTime);
			this.renderer.render(this.stage);
		}
		if(this.stats != null) this.stats.update();
	}
	,calculateElapsedTime: function() {
		this.currentTime = window.performance.now();
		this.elapsedTime = this.currentTime - this.lastTime;
		this.lastTime = this.currentTime;
	}
	,addStats: function() {
		if(window.Stats != null) {
			var container = window.document.createElement("div");
			window.document.body.appendChild(container);
			this.stats = new Stats();
			this.stats.domElement.style.position = "absolute";
			this.stats.domElement.style.top = "2px";
			this.stats.domElement.style.right = "2px";
			container.appendChild(this.stats.domElement);
			this.stats.begin();
		}
	}
	,__class__: pixi_plugins_app_Application
};
var Main = function() {
	this.randomise = false;
	pixi_plugins_app_Application.call(this);
	this.ready = false;
	this.initAudio();
	this.initPixi();
	this.initBeatLines();
	this.initStepGrid();
	this.initControls();
	this.stageResized();
};
Main.__name__ = true;
Main.main = function() {
	util_WebFontEmbed.loaded = function() {
		new Main();
	};
	util_WebFontEmbed.load();
};
Main.__super__ = pixi_plugins_app_Application;
Main.prototype = $extend(pixi_plugins_app_Application.prototype,{
	initControls: function() {
		var _g = this;
		this.controls = new drums_Controls();
		this.controls.bpm.addObserver(function(p) {
			_g.drums.set_bpm(p.getValue());
		});
		this.controls.muteToggle.addObserver(function(p1) {
			if(p1.getValue()) _g.outGain.gain.setValueAtTime(0,0); else _g.outGain.gain.setValueAtTime(_g.controls.volume.getValue(),0);
		});
		this.controls.playToggle.addObserver(function(p2) {
			if(p2.getValue()) _g.drums.play(); else _g.drums.stop();
		});
		this.controls.randomModeToggle.addObserver(function(p3) {
			_g.randomise = p3.getValue();
		});
		this.controls.recordToggle.addObserver(function(p4) {
			var r = p4.getValue();
			if(!_g.recorder.recording && r) {
				if(!_g.drums.isPlaying) {
					p4.setValue(false);
					return;
				}
				console.log("recording...");
				_g.recorder.worker.postMessage(tones_utils_AudioNodeRecorder.ClearBufferMessage);
				_g.recorder.recording = true;
				window.document.getElementById("record-start-tooltip").style.display = "none";
				window.document.getElementById("record-stop-tooltip").style.display = "block";
			} else if(_g.recorder.recording && !r) {
				window.document.getElementById("record-start-tooltip").style.display = "block";
				window.document.getElementById("record-stop-tooltip").style.display = "none";
				var resetRecordButtons = function() {
					window.document.getElementById("save-recording-button").style.display = "none";
					window.document.getElementById("clear-recording-button").style.display = "none";
					window.document.getElementById("record-button").style.display = "block";
				};
				_g.recorder.wavEncoded.connect(function(data) {
					console.log("Encoded wav - " + (data.size >> 10) / 1024 + " MB  (" + data.size + " bytes)");
					window.document.getElementById("save-recording-button").style.display = "block";
					window.document.getElementById("clear-recording-button").style.display = "block";
					var link = window.document.getElementById("save-button-link");
					link.href = URL.createObjectURL(data);
					link.download = "drums_" + _g.drums._bpm + "bpm.wav";
					_g.controls.saveRecording.connect(function() {
						resetRecordButtons();
					},hxsignal_ConnectionTimes.Once);
					_g.controls.clearRecording.connect(function() {
						_g.recorder.worker.postMessage(tones_utils_AudioNodeRecorder.ClearBufferMessage);
						resetRecordButtons();
					},hxsignal_ConnectionTimes.Once);
				},hxsignal_ConnectionTimes.Once);
				console.log("stopped recording");
				_g.recorder.recording = false;
				console.log("encoding wav...");
				_g.recorder.worker.postMessage(tones_utils_AudioNodeRecorder.EncodeWAVMessage);
				window.document.getElementById("record-button").style.display = "none";
			}
		});
		this.controls.swing.addObserver(function(p5) {
			_g.drums.set_swing(p5.getValue());
		});
		this.controls.volume.addObserver(function(p6) {
			_g.outGain.gain.setValueAtTime(p6.getValue(),0);
		});
		this.controls.trackMute.connect(function(i,state) {
			_g.drums.tracks[i].mute(state);
		});
		this.controls.trackShuffle.connect(function(i1) {
			_g.drums.tracks[i1].randomise();
		});
		this.controls.trackSolo.connect(function(i2,state1) {
			var tracks = _g.drums.tracks;
			var soloTracks = _g.controls.soloTracks;
			var soloCount = 0;
			var _g1 = 0;
			while(_g1 < soloTracks.length) {
				var val = soloTracks[_g1];
				++_g1;
				soloCount += val;
			}
			var track;
			var solo;
			var _g11 = 0;
			while(_g11 < 8) {
				var j = _g11++;
				track = tracks[j];
				solo = soloTracks[j];
				if(solo == 0 && soloCount > 0) track.otherSolo = true; else if(solo == 1 && soloCount > 1) track.otherSolo = true; else track.otherSolo = false;
			}
			tracks[i2].solo(state1);
			var _g12 = 0;
			while(_g12 < tracks.length) {
				var track1 = tracks[_g12];
				++_g12;
				track1.updateOutputState();
			}
		});
		this.drums.playing.connect(function(value) {
			if(!value && _g.recorder.recording) _g.controls.recordToggle.setValue(false);
		});
	}
	,initAudio: function() {
		this.audioContext = tones_AudioBase.createContext();
		this.outGain = this.audioContext.createGain();
		this.outGain.gain.value = .25;
		this.outGain.connect(this.audioContext.destination);
		this.drums = new drums_DrumSequencer(this.audioContext,this.outGain);
		this.drums.tick.connect($bind(this,this.onSequenceTick));
		this.drums.ready.connect($bind(this,this.onDrumsReady));
		this.recorder = new tones_utils_AudioNodeRecorder(this.drums.output);
	}
	,onDrumsReady: function() {
		console.log("ready");
		this.ready = true;
		window.document.getElementById("load-spinner").remove();
		window.document.getElementById("pixi-container").style.display = "";
		this.controls.bpm.setValue(Math.round(60 + Math.random() * 120));
		this.controls.swing.setValue(Math.random() * .5);
		this.controls.volume.setValue(.5);
		this.drums.play(0);
	}
	,onSequenceTick: function(index,time) {
		this.beatLines.tick(index);
		this.sequenceGrid.tick(index);
		if(this.randomise) {
			if(index == 0 && Math.random() > .8) {
				var tmp;
				var x = Math.random() * 8;
				tmp = x | 0;
				this.drums.tracks[tmp].randomise();
			}
			if(Math.random() > .95) {
				var tmp1;
				var x1 = Math.random() * 8;
				tmp1 = x1 | 0;
				var tmp2;
				var x2 = Math.random() * 16;
				tmp2 = x2 | 0;
				this.drums.tracks[tmp1].events[tmp2].active = Math.round(Math.random()) == 1;
			}
		}
	}
	,initPixi: function() {
		this.backgroundColor = 1645340;
		this.antialias = true;
		this.onUpdate = $bind(this,this.tick);
		this.onResize = $bind(this,this.stageResized);
		this.width = 898;
		this.height = 445;
		this.start("auto",false,window.document.getElementById("pixi-container"));
		this.stage.x = 1;
	}
	,_onWindowResize: function(event) {
		this.width = 898;
		this.height = 445;
		this.renderer.resize(this.width,this.height);
		this.canvas.style.width = this.width + "px";
		this.canvas.style.height = this.height + "px";
		if(this.onResize != null) this.onResize();
	}
	,initBeatLines: function() {
		this.beatLines = new drums_view_sequencer_BeatLines(900,448);
		this.stage.addChild(this.beatLines);
	}
	,initStepGrid: function() {
		this.sequenceGrid = new drums_view_sequencer_CellGrid(this.drums);
		this.stage.addChild(this.sequenceGrid);
	}
	,tick: function(dt) {
		if(!this.ready) return;
		this.sequenceGrid.update(dt);
	}
	,stageResized: function() {
		this.sequenceGrid.x = 26;
		this.sequenceGrid.y = 26;
		this.beatLines.displayHeight = Math.round(this.height - 40);
		this.beatLines.position.x = this.sequenceGrid.x;
		this.beatLines.position.y = 0;
	}
	,__class__: Main
});
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
};
var Std = function() { };
Std.__name__ = true;
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
var drums_Controls = function() {
	this.setupControlBar();
	this.setupTracks();
	window.addEventListener("keydown",$bind(this,this.onKeyDown));
	this.muteTracks = new Int8Array([0,0,0,0,0,0,0,0]);
	this.soloTracks = new Int8Array([0,0,0,0,0,0,0,0]);
};
drums_Controls.__name__ = true;
drums_Controls.prototype = {
	onKeyDown: function(e) {
		if(e.ctrlKey || e.shiftKey) return;
		var _g = e.keyCode;
		switch(_g) {
		case 32:case 49:
			this.playToggle.setValue(!this.playToggle.getValue());
			break;
		case 82:case 50:
			this.randomModeToggle.setValue(!this.randomModeToggle.getValue());
			break;
		case 51:case 16:
			this.recordToggle.setValue(!this.recordToggle.getValue());
			break;
		case 52:case 77:
			this.muteToggle.setValue(!this.muteToggle.getValue());
			break;
		case 107:case 187:
			var val = this.volume.getValue(true) + .1;
			if(val > 1) val = 1;
			this.volume.setValue(val,true);
			break;
		case 189:case 109:
			var val1 = this.volume.getValue(true) - .1;
			if(val1 < 0) val1 = 0;
			this.volume.setValue(val1,true);
			break;
		}
	}
	,setupControlBar: function() {
		var _g = this;
		var byId = ($_=window.document,$bind($_,$_.getElementById));
		if(!js_Cookie.exists("viewedHelp") || js_Cookie.get("viewedHelp") != "true") js.JQuery("#info-modal").css("display","block");
		js.JQuery("#help-button").on("click tap",function(_) {
			js.JQuery("#info-modal").css("display","block");
		});
		js.JQuery("#close-help").on("click tap",function(_1) {
			js.JQuery("#info-modal").css("display","none");
			js_Cookie.set("viewedHelp","true",2592000,"/");
		});
		this.playToggle = new parameter_ParameterBase("playToggle",parameter__$Parameter_Parameter_$Impl_$.getBool(true,false));
		this.playToggle.addObserver(function(p) {
			var state = p.getValue();
			byId("play-button").style.display = state?"none":"";
			byId("stop-button").style.display = state?"":"none";
		});
		js.JQuery("#play-button").on("click tap",function(_2) {
			_g.playToggle.setValue(true);
		});
		js.JQuery("#stop-button").on("click tap",function(_3) {
			_g.playToggle.setValue(false);
		});
		var randomButton = byId("shuffle-button");
		this.randomModeToggle = new parameter_ParameterBase("randomModeToggle",parameter__$Parameter_Parameter_$Impl_$.getBool(false,true));
		this.randomModeToggle.addObserver(function(p1) {
			if(p1.getValue()) randomButton.classList.add("mdl-button--accent"); else randomButton.classList.remove("mdl-button--accent");
		});
		js.JQuery(randomButton).on("click tap",function(_4) {
			_g.randomModeToggle.setValue(!_g.randomModeToggle.getValue());
		});
		var recordButton = byId("record-button");
		this.recordToggle = new parameter_ParameterBase("recordToggle",parameter__$Parameter_Parameter_$Impl_$.getBool(false,true));
		this.recordToggle.addObserver(function(p2) {
			if(p2.getValue()) recordButton.classList.add("mdl-button--accent"); else recordButton.classList.remove("mdl-button--accent");
		});
		js.JQuery(recordButton).on("click tap",function(_5) {
			_g.recordToggle.setValue(!_g.recordToggle.getValue());
		});
		this.saveRecording = new hxsignal_impl_Signal0();
		js.JQuery(byId("save-recording-button")).on("click tap",function(_6) {
			_g.saveRecording.emit();
		});
		this.clearRecording = new hxsignal_impl_Signal0();
		js.JQuery(byId("clear-recording-button")).on("click tap",function(_7) {
			_g.clearRecording.emit();
		});
		var bpmSlider = byId("bpm-slider");
		this.bpm = (function($this) {
			var $r;
			var min = Std.parseInt(bpmSlider.min);
			var max = Std.parseInt(bpmSlider.max);
			$r = new parameter_ParameterBase("bpmSlider",parameter__$Parameter_Parameter_$Impl_$.getInt(min,max));
			return $r;
		}(this));
		this.bpm.addObserver(function(p3) {
			var val = p3.getValue();
			bpmSlider.MaterialSlider.change(val);
			js.JQuery(bpmSlider).parent().siblings("div[for=\"bpm-slider\"]").text("" + val);
		});
		js.JQuery("#bpm-slider").on("input change",function(_8) {
			_g.bpm.setValue(bpmSlider.valueAsNumber | 0);
		});
		this.bpm.setDefault(bpmSlider.valueAsNumber | 0);
		var swingSlider = byId("swing-slider");
		this.swing = (function($this) {
			var $r;
			var min1 = Std.parseInt(swingSlider.min);
			var max1 = parseFloat(swingSlider.max);
			$r = new parameter_ParameterBase("swingSlider",parameter__$Parameter_Parameter_$Impl_$.getFloat(min1,max1));
			return $r;
		}(this));
		this.swing.addObserver(function(p4) {
			var val1 = p4.getValue();
			swingSlider.MaterialSlider.change(val1);
			js.JQuery(swingSlider).parent().siblings("div[for=\"swing-slider\"]").text("" + (val1 * 100 | 0) + "%");
		});
		js.JQuery("#swing-slider").on("input change",function(_9) {
			_g.swing.setValue(swingSlider.valueAsNumber);
		});
		this.swing.setDefault(swingSlider.valueAsNumber);
		var volumeSlider = byId("volume-slider");
		this.volume = (function($this) {
			var $r;
			var min2 = Std.parseInt(volumeSlider.min);
			var max2 = parseFloat(volumeSlider.max);
			$r = new parameter_ParameterBase("volumeSlider",parameter__$Parameter_Parameter_$Impl_$.getFloatExponential(min2,max2));
			return $r;
		}(this));
		this.volume.addObserver(function(p5) {
			var normValue = p5.getValue(true);
			volumeSlider.MaterialSlider.change(normValue);
			js.JQuery(volumeSlider).parent().siblings("div[for=\"volume-slider\"]").text("" + normValue);
		});
		js.JQuery("#volume-slider").on("input change",function(_10) {
			_g.volume.setValue(volumeSlider.valueAsNumber,true);
		});
		this.volume.setDefault(volumeSlider.valueAsNumber,true);
		this.muteToggle = new parameter_ParameterBase("muteToggle",parameter__$Parameter_Parameter_$Impl_$.getBool(false,true));
		this.muteToggle.addObserver(function(p6) {
			var state1 = p6.getValue();
			if(state1) volumeSlider.MaterialSlider.disable(); else volumeSlider.MaterialSlider.enable();
			byId("mute-button").style.display = state1?"none":"";
			byId("unmute-button").style.display = state1?"":"none";
		});
		js.JQuery("#mute-button").on("click tap",function(_11) {
			_g.muteToggle.setValue(true);
		});
		js.JQuery("#unmute-button").on("click tap",function(_12) {
			_g.muteToggle.setValue(false);
		});
	}
	,setupTracks: function() {
		var _g = this;
		this.trackShuffle = new hxsignal_impl_Signal1();
		this.trackMute = new hxsignal_impl_Signal2();
		this.trackSolo = new hxsignal_impl_Signal2();
		this.trackMute.connect(function(i,state) {
			if(state) js.JQuery("#track-mute-" + i).addClass("mdl-button--accent"); else js.JQuery("#track-mute-" + i).removeClass("mdl-button--accent");
			_g.muteTracks[i] = state?1:0;
		});
		this.trackSolo.connect(function(i1,state1) {
			if(state1) js.JQuery("#track-solo-" + i1).addClass("mdl-button--accent"); else js.JQuery("#track-solo-" + i1).removeClass("mdl-button--accent");
			_g.soloTracks[i1] = state1?1:0;
		});
		var _g1 = 0;
		while(_g1 < 8) {
			var i2 = [_g1++];
			js.JQuery("#track-shuffle-" + i2[0]).on("click tap",(function(i2) {
				return function(_) {
					_g.trackShuffle.emit(i2[0]);
				};
			})(i2));
			js.JQuery("#track-mute-" + i2[0]).on("click tap",(function(i2) {
				return function(_1) {
					_g.trackMute.emit(i2[0],!js.JQuery("#track-mute-" + i2[0]).hasClass("mdl-button--accent"));
				};
			})(i2));
			js.JQuery("#track-solo-" + i2[0]).on("click tap",(function(i2) {
				return function(_2) {
					_g.trackSolo.emit(i2[0],!js.JQuery("#track-solo-" + i2[0]).hasClass("mdl-button--accent"));
				};
			})(i2));
		}
	}
	,__class__: drums_Controls
};
var drums_DrumSequencer = function(audioContext,destination) {
	this.tickIndex = -1;
	this.set_bpm(120);
	this.set_swing(0);
	this.playing = new hxsignal_impl_Signal1();
	this.isPlaying = false;
	this.context = audioContext == null?tones_AudioBase.createContext():audioContext;
	this.output = this.context.createGain();
	this.output.connect(destination == null?this.context.destination:destination);
	this.ready = new hxsignal_impl_Signal0();
	this.tick = new hxsignal_impl_Signal2();
	this.tracks = [];
	this.loadSamples();
};
drums_DrumSequencer.__name__ = true;
drums_DrumSequencer.prototype = {
	play: function(tick) {
		if(tick == null) tick = 0;
		this.isPlaying = true;
		this.tickIndex = tick - 1;
		this.timeTrack.removeAllTimedEvents();
		this.timeTrack.addTimedEvent(this.context.currentTime + 0.0083333333333333332);
		this.playing.emit(true);
	}
	,stop: function() {
		this.isPlaying = false;
		this.tickIndex = -1;
		this.timeTrack.removeAllTimedEvents();
		this.playing.emit(false);
	}
	,toggleEvent: function(trackIndex,tickIndex) {
		var track = this.tracks[trackIndex];
		var e = track.events[tickIndex];
		e.active = !e.active;
		if(!e.active && e.id != -1) track.source.doStop(e.id);
	}
	,loadSamples: function() {
		var _g2 = this;
		this.loadCount = 0;
		var _g1 = 0;
		var _g = drums_DrumSequencer.filenames.length;
		while(_g1 < _g) {
			var i = [_g1++];
			this.tracks.push(null);
			var request = new XMLHttpRequest();
			request.open("GET","data/samples/808_" + drums_DrumSequencer.filenames[i[0]] + ".wav",true);
			request.responseType = "arraybuffer";
			request.onload = (function(i) {
				return function(_) {
					var tmp;
					var f = $bind(_g2,_g2.sampleDecoded);
					var a2 = i[0];
					tmp = (function() {
						return function(a1) {
							f(a1,a2);
						};
					})();
					_g2.context.decodeAudioData(_.currentTarget.response,tmp);
				};
			})(i);
			request.send();
		}
	}
	,sampleDecoded: function(buffer,index) {
		this.tracks[index] = new drums_Track(drums_DrumSequencer.trackNames[index],buffer,this.context,this.output);
		this.loadCount++;
		if(index == 0) {
			this.timeTrack = this.tracks[0].source;
			this.timeTrack.timedEvent.connect($bind(this,this.onTrackTick));
		} else if(this.loadCount == drums_DrumSequencer.filenames.length) this.ready.emit();
	}
	,onTrackTick: function(id,time) {
		if(!this.isPlaying) return;
		if(time < this.context.currentTime) time = this.context.currentTime;
		var offset = .0;
		if(this._swing > 0) {
			if((this.tickIndex & 1) == 1) offset = this._swing * 0.25; else offset = -this._swing * 0.25;
		}
		var nextTick = time + (0.25 + offset) / (this._bpm / 60);
		this.timeTrack.addTimedEvent(nextTick);
		this.tick.emit(this.tickIndex,time);
		this.tickIndex++;
		if(this.tickIndex == 16) this.tickIndex = 0;
		this.playTick(this.tickIndex,nextTick);
	}
	,playTrackCellNow: function(trackIndex,cellIndex) {
		var track = this.tracks[trackIndex];
		var event = track.events[cellIndex];
		var s = track.source;
		track.set_pan(event.pan);
		s.set_volume(event.volume);
		s.set_attack(event.attack);
		s.offset = event.offset;
		s.duration = event.duration;
		s.playbackRate = event.rate;
		s.playSample(null,0);
	}
	,playTick: function(index,time) {
		var _g = 0;
		var _g1 = this.tracks;
		while(_g < _g1.length) {
			var track = _g1[_g];
			++_g;
			var event = track.events[index];
			if(event.active) {
				var s = track.source;
				s.set_volume(event.volume);
				s.set_attack(event.attack);
				s.offset = event.offset;
				s.duration = event.duration;
				s.playbackRate = event.rate;
				track.set_pan(event.pan);
				event.id = s.playSample(null,time - this.context.currentTime);
			}
		}
	}
	,set_bpm: function(value) {
		if(value < 1) value = 1; else if(value > 300) value = 300;
		return this._bpm = value;
	}
	,set_swing: function(value) {
		if(value < 0) value = 0; else if(value >= 1) value = 0;
		return this._swing = value;
	}
	,__class__: drums_DrumSequencer
};
var drums_Track = function(name,buffer,context,destination) {
	this.otherSolo = false;
	this.isSolo = false;
	this.isMuted = false;
	this.outGain = 1;
	this._pan = 0;
	this.name = name;
	this.outGain = 1.0;
	this.gainNode = context.createGain();
	this.gainNode.gain.value = this.outGain;
	this.gainNode.connect(destination);
	this.panNode = context.createPanner();
	this.panNode.panningModel = "equalpower";
	this.panNode.connect(this.gainNode);
	this.source = new tones_Samples(context,this.panNode);
	this.source.set_attack(0);
	this.source.set_buffer(buffer);
	var tmp;
	var _g = [];
	var _g1 = 0;
	while(_g1 < 16) {
		_g1++;
		_g.push({ active : false, id : -1, volume : 1, pan : 0, rate : 1, attack : 0, offset : 0, duration : buffer.duration});
	}
	tmp = _g;
	this.events = tmp;
};
drums_Track.__name__ = true;
drums_Track.prototype = {
	randomise: function() {
		var _g = 0;
		while(_g < 16) {
			var i = _g++;
			var e = this.events[i];
			var tmp;
			var x = 16 * Math.random();
			tmp = x | 0;
			var tmp1;
			var x1 = Math.random() * 16;
			tmp1 = x1 | 0;
			var active = tmp % tmp1 == 0;
			if(active) {
				e.active = true;
				var rate = 1.1 - (1 + Math.random() * i) / 16;
				if(Math.random() < .5) rate = 2 - rate;
				if(rate <= 0) rate = 1;
				e.rate = rate;
				e.volume = .5 + Math.random() * 2;
				e.pan = Math.random() * (-0.5 + i / 32);
				e.duration = this.source._buffer.duration * .1 + Math.random() * .9;
				e.offset = Math.random() > .5?0:e.duration * Math.random() * .1;
				e.attack = Math.random() > .5?0:.1 * Math.random();
			} else e.active = false;
		}
	}
	,mute: function(state) {
		this.isMuted = state;
		this.updateOutputState();
	}
	,solo: function(state) {
		this.isSolo = state;
		this.updateOutputState();
	}
	,updateOutputState: function() {
		var val = this.isMuted?0:!this.otherSolo || this.isSolo?this.outGain:0;
		this.gainNode.gain.setValueAtTime(val,0);
	}
	,set_pan: function(value) {
		var x = value * 1.5707963267948966;
		var z = x + 1.5707963267948966;
		if(z > 1.5707963267948966) z = Math.PI - z;
		this.panNode.setPosition(Math.sin(x),0,Math.sin(z));
		return this._pan = value;
	}
	,__class__: drums_Track
};
var drums_view_Pointer = function() {
	this.lastTime = 0;
	this.timeDown = 0;
	this.isDown = false;
	this.moved = false;
	this.up = new hxsignal_impl_Signal1();
	this.down = new hxsignal_impl_Signal1();
	this.click = new hxsignal_impl_Signal1();
	this.longPress = new hxsignal_impl_Signal1();
	this.pressCancel = new hxsignal_impl_Signal1();
	this.pressProgress = new hxsignal_impl_Signal2();
	tones_utils_TimeUtil.get_frameTick().connect($bind(this,this.update));
};
drums_view_Pointer.__name__ = true;
drums_view_Pointer.prototype = {
	watch: function(target) {
		target.on("mousemove",$bind(this,this.onMove));
		target.on("mousedown",$bind(this,this.onDown));
		target.on("mouseup",$bind(this,this.onUp));
		target.on("touchmove",$bind(this,this.onMove));
		target.on("touchstart",$bind(this,this.onDown));
		target.on("touchend",$bind(this,this.onUp));
	}
	,update: function(t) {
		var dt = t - this.lastTime;
		this.lastTime = t;
		if(this.isDown) {
			this.timeDown += dt;
			if(this.timeDown - 250 > 400) {
				this.longPress.emit(this.currentTarget);
				this.isDown = false;
				this.timeDown = 0;
			} else if(this.timeDown > 250) this.pressProgress.emit(this.currentTarget,(this.timeDown - 250) / 400);
		} else if(this.timeDown > 0) {
			if(this.timeDown < 250) this.click.emit(this.currentTarget);
			this.pressCancel.emit(this.currentTarget);
			this.timeDown = 0;
		}
		this.moved = false;
	}
	,onDown: function(e) {
		this.isDown = true;
		this.timeDown = 0;
		this.down.emit(this.currentTarget = e.target);
	}
	,onUp: function(e) {
		this.isDown = false;
		this.up.emit(this.currentTarget);
	}
	,onMove: function(e) {
		this.moved = true;
	}
	,__class__: drums_view_Pointer
};
var drums_view_UIElement = function(width,height) {
	PIXI.Container.call(this);
	this.interactive = false;
	this.bg = new PIXI.Graphics();
	this.drawBg(width,height);
	this.addChild(this.bg);
};
drums_view_UIElement.__name__ = true;
drums_view_UIElement.__super__ = PIXI.Container;
drums_view_UIElement.prototype = $extend(PIXI.Container.prototype,{
	drawBg: function(w,h) {
		this.bg.clear();
		this.bg.beginFill(817360);
		this.bg.drawRect(0,0,w,h);
		this.bg.endFill();
	}
	,__class__: drums_view_UIElement
});
var drums_view_displays_Waveform = function(width,height) {
	PIXI.Graphics.call(this);
	this.displayWidth = width;
	this.displayHeight = height;
};
drums_view_displays_Waveform.__name__ = true;
drums_view_displays_Waveform.__super__ = PIXI.Graphics;
drums_view_displays_Waveform.prototype = $extend(PIXI.Graphics.prototype,{
	drawBuffer: function(buffer,normalise) {
		if(normalise == null) normalise = true;
		var peaks = buffer == this.lastBuffer?this.lastPeaks:this.getPeaks(this.displayWidth >> 1,buffer);
		this.drawPeaks(peaks,normalise);
		this.lastPeaks = peaks;
		this.lastBuffer = buffer;
	}
	,drawPeaks: function(peaks,normalise) {
		var h;
		var halfH = this.displayHeight / 2;
		this.clear();
		this.lineStyle(1.25,1436341,1);
		this.moveTo(0,halfH);
		var max = normalise?this.getMax(peaks):1.0;
		var scale = this.displayWidth / peaks.length;
		var n = peaks.length;
		max *= 1.05;
		var _g = 0;
		while(_g < n) {
			var i = _g++;
			h = Math.round(peaks[i] / max * halfH);
			this.moveTo(i * scale,halfH - h);
			this.lineTo(i * scale,halfH + h);
		}
	}
	,getMax: function(peaks) {
		var max = .0;
		var _g = 0;
		while(_g < peaks.length) {
			var v = peaks[_g];
			++_g;
			if(v > max) max = v;
		}
		return max;
	}
	,getPeaks: function(length,buffer) {
		var sampleSize = buffer.length / length;
		var sampleStep = sampleSize / 10;
		var channels = buffer.numberOfChannels;
		var mergedPeaks = [];
		var _g = 0;
		while(_g < channels) {
			var c = _g++;
			var peaks = [];
			var chan = buffer.getChannelData(c);
			var _g1 = 0;
			while(_g1 < length) {
				var i = _g1++;
				var start = i * sampleSize;
				var end = start + sampleSize;
				var max = .0;
				var j = start;
				while(j < end) {
					var value = chan[j | 0];
					if(value > max) max = value; else if(-value > max) max = -value;
					j += sampleStep;
				}
				peaks[i] = max;
				if(c == 0 || max > mergedPeaks[i]) mergedPeaks[i] = max;
			}
		}
		return new Float32Array(mergedPeaks);
	}
	,__class__: drums_view_displays_Waveform
});
var drums_view_edit_CellEditControls = function(drums1) {
	var _g = this;
	this.trackIndex = -1;
	this.tickIndex = -1;
	this.drums = drums1;
	this.container = window.document.getElementById("cell-edit-controls");
	this.close = new hxsignal_impl_Signal0();
	this.play = new hxsignal_impl_Signal0();
	this.editNextPrev = new hxsignal_impl_Signal1();
	js.JQuery("#cell-edit-play-button").on("click tap",function(_) {
		_g.play.emit();
	});
	js.JQuery("#cell-edit-close-button").on("click tap",function(_1) {
		_g.close.emit();
		_g.tickIndex = -1;
		_g.trackIndex = -1;
		_g.container.style.display = "none";
	});
	js.JQuery("#cell-edit-next-button").on("click tap",function(_2) {
		_g.tickIndex++;
		if(_g.tickIndex >= drums1.tracks[_g.trackIndex].events.length) _g.tickIndex = 0;
		_g.editNextPrev.emit(_g.tickIndex);
	});
	js.JQuery("#cell-edit-prev-button").on("click tap",function(_3) {
		_g.tickIndex--;
		if(_g.tickIndex < 0) _g.tickIndex += drums1.tracks[_g.trackIndex].events.length;
		_g.editNextPrev.emit(_g.tickIndex);
	});
	this.setupSliders();
};
drums_view_edit_CellEditControls.__name__ = true;
drums_view_edit_CellEditControls.prototype = {
	update: function(trackIndex,tickIndex) {
		var sameTrack = this.trackIndex == trackIndex;
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
		if(!sameTrack) {
			this.container.style.opacity = "0";
			this.container.style.display = "block";
		}
		var track = this.drums.tracks[trackIndex];
		var event = track.events[tickIndex];
		var duration = track.source._buffer.duration;
		this.cellDuration.setValue(event.duration / duration,false,true);
		this.cellOffset.setValue(event.offset / duration,false,true);
		this.cellRate.setValue(event.rate,false,true);
		this.cellVolume.setValue(event.volume,false,true);
		this.cellPan.setValue(event.pan,false,true);
		this.cellAttack.setValue(event.attack,false,true);
	}
	,setupSliders: function() {
		var id = "cell-offset-slider";
		var slider = window.document.getElementById(id);
		this.cellOffset = (function($this) {
			var $r;
			var min = Std.parseInt(slider.min);
			var max = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellOffsetSlider",parameter__$Parameter_Parameter_$Impl_$.getFloat(min,max));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellOffset,slider,false);
		id = "cell-duration-slider";
		slider = window.document.getElementById(id);
		this.cellDuration = (function($this) {
			var $r;
			var min1 = Std.parseInt(slider.min);
			var max1 = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellDurationSlider",parameter__$Parameter_Parameter_$Impl_$.getFloat(min1,max1));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellDuration,slider,false);
		id = "cell-rate-slider";
		slider = window.document.getElementById(id);
		this.cellRate = (function($this) {
			var $r;
			var min2 = Std.parseInt(slider.min);
			var max2 = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellRateSlider",parameter__$Parameter_Parameter_$Impl_$.getFloat(min2,max2));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellRate,slider,false);
		id = "cell-volume-slider";
		slider = window.document.getElementById(id);
		this.cellVolume = (function($this) {
			var $r;
			var min3 = Std.parseInt(slider.min);
			var max3 = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellVolumeSlider",parameter__$Parameter_Parameter_$Impl_$.getFloatExponential(min3,max3));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellVolume,slider,false);
		id = "cell-pan-slider";
		slider = window.document.getElementById(id);
		this.cellPan = (function($this) {
			var $r;
			var min4 = Std.parseInt(slider.min);
			var max4 = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellPanSlider",parameter__$Parameter_Parameter_$Impl_$.getFloat(min4,max4));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellPan,slider,false);
		id = "cell-attack-slider";
		slider = window.document.getElementById(id);
		this.cellAttack = (function($this) {
			var $r;
			var min5 = Std.parseInt(slider.min);
			var max5 = parseFloat(slider.max);
			$r = new parameter_ParameterBase("cellAttackSlider",parameter__$Parameter_Parameter_$Impl_$.getFloatExponential(min5,max5));
			return $r;
		}(this));
		this.setupParameterSlider(this.cellAttack,slider,false);
		this.cellOffset.addObserver($bind(this,this.cellOffsetHandler));
		this.cellDuration.addObserver($bind(this,this.cellDurationHandler));
		this.cellRate.addObserver($bind(this,this.cellRateHandler));
		this.cellVolume.addObserver($bind(this,this.cellVolumeHandler));
		this.cellPan.addObserver($bind(this,this.cellPanHandler));
		this.cellAttack.addObserver($bind(this,this.cellAttackHandler));
	}
	,setupParameterSlider: function(parameter,slider,normalised) {
		parameter.addObserver(function(p) {
			var val = p.getValue(normalised);
			slider.MaterialSlider.change(val);
			js.JQuery(slider).parent().siblings("div[for=\"" + slider.id + "\"]").text("" + val);
		});
		js.JQuery(slider).on("input change",function(_) {
			parameter.setValue(slider.valueAsNumber,normalised);
		});
	}
	,cellOffsetHandler: function(p) {
		var track = this.drums.tracks[this.trackIndex];
		track.events[this.tickIndex].offset = p.getValue() * track.source._buffer.duration;
	}
	,cellDurationHandler: function(p) {
		var track = this.drums.tracks[this.trackIndex];
		track.events[this.tickIndex].duration = p.getValue() * track.source._buffer.duration;
	}
	,cellRateHandler: function(p) {
		this.drums.tracks[this.trackIndex].events[this.tickIndex].rate = p.getValue();
	}
	,cellVolumeHandler: function(p) {
		this.drums.tracks[this.trackIndex].events[this.tickIndex].volume = p.getValue();
	}
	,cellPanHandler: function(p) {
		this.drums.tracks[this.trackIndex].events[this.tickIndex].pan = p.getValue();
	}
	,cellAttackHandler: function(p) {
		this.drums.tracks[this.trackIndex].events[this.tickIndex].attack = p.getValue();
	}
	,__class__: drums_view_edit_CellEditControls
};
var drums_view_edit_CellEditPanel = function(drums1,pointer,displayWidth,displayHeight) {
	this.ticked = 0.0;
	this.closing = false;
	this.launching = false;
	this.fadeUI = false;
	this.bgSize = 0;
	var _g = this;
	PIXI.Container.call(this);
	this.visible = false;
	this.closed = new hxsignal_impl_Signal0();
	this.drums = drums1;
	this.displayWidth = displayWidth;
	this.displayHeight = displayHeight;
	this.bg = new PIXI.Graphics();
	this.addChild(this.bg);
	this.setupUI(pointer);
	this.controls = new drums_view_edit_CellEditControls(drums1);
	this.controls.close.connect($bind(this,this.close));
	this.controls.play.connect($bind(this,this.playNow));
	this.controls.editNextPrev.connect(function(i) {
		_g.edit(_g.controls.trackIndex,i);
	});
	var f = function(val) {
		_g.waveform.updateOverlay(_g.controls.cellOffset.getValue(true),_g.controls.cellDuration.getValue(true));
	};
	this.controls.cellOffset.addObserver(f);
	this.controls.cellDuration.addObserver(f);
};
drums_view_edit_CellEditPanel.__name__ = true;
drums_view_edit_CellEditPanel.__super__ = PIXI.Container;
drums_view_edit_CellEditPanel.prototype = $extend(PIXI.Container.prototype,{
	edit: function(trackIndex,tickIndex) {
		if(tickIndex > 15) tickIndex = 0; else if(tickIndex < 0) tickIndex = 15;
		if(trackIndex > 7) trackIndex = 0; else if(trackIndex < 0) trackIndex = 7;
		var sameTrack = this.trackIndex == trackIndex;
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
		if(!this.visible) {
			this.visible = this.launching = true;
			this.fadeUI = this.closing = false;
			this.bgSize = 0;
			this.uiContainer.alpha = 0;
		} else if(!sameTrack) {
			this.visible = true;
			this.launching = this.closing = false;
			this.fadeUI = true;
			this.bgSize = 1;
			this.uiContainer.alpha = 0;
		}
		this.event = this.drums.tracks[trackIndex].events[tickIndex];
		this.waveform.setup(this.drums,trackIndex,tickIndex);
		this.waveform.updateOverlay(this.controls.cellOffset.getValue(true),this.controls.cellDuration.getValue(true));
		this.cellInfo.update(this.drums,trackIndex,tickIndex);
		this.controls.update(trackIndex,tickIndex);
		window.removeEventListener("keydown",$bind(this,this.onKeyDown));
		window.addEventListener("keydown",$bind(this,this.onKeyDown));
	}
	,onKeyDown: function(e) {
		var _g = e.keyCode;
		switch(_g) {
		case 80:
			this.drums.playTrackCellNow(this.trackIndex,this.tickIndex);
			break;
		case 37:
			this.edit(this.trackIndex,this.tickIndex - 1);
			break;
		case 39:
			this.edit(this.trackIndex,this.tickIndex + 1);
			break;
		case 38:
			this.edit(this.trackIndex - 1,this.tickIndex);
			break;
		case 40:
			this.edit(this.trackIndex + 1,this.tickIndex);
			break;
		}
	}
	,close: function() {
		window.removeEventListener("keydown",$bind(this,this.onKeyDown));
		this.bg.pivot.set(0,0);
		this.bg.position.set(0,0);
		this.bg.scale.set(1,1);
		this.closing = true;
		this.launching = false;
		this.uiContainer.alpha = 0;
		this.trackIndex = -1;
		this.tickIndex = -1;
		this.closed.emit();
	}
	,tick: function(index) {
		if(index == this.tickIndex && this.event.active) this.ticked = 1.0;
	}
	,update: function() {
		if(!this.visible) return;
		if(this.launching || this.closing) {
			this.bgSize += this.launching?.08:-.07;
			if(this.bgSize >= 1) this.onLaunched(); else if(this.bgSize <= 0) this.onClosed();
			this.drawBg(this.bgSize);
		} else {
			if(this.ticked > 0) {
				this.ticked *= .925;
				if(this.ticked < .05) {
					this.ticked = 0;
					this.drawBg(1);
				} else {
					var g = 150 + (this.ticked * 96 | 0);
					this.drawBg(1,2162688 | g << 8 | 243);
				}
			}
			if(this.fadeUI && this.uiContainer.alpha < 1) {
				this.uiContainer.alpha += .09;
				this.controls.container.style.opacity = "" + this.uiContainer.alpha;
				if(this.uiContainer.alpha >= 1) {
					this.uiContainer.alpha = 1;
					this.fadeUI = false;
				}
			}
		}
	}
	,setupUI: function(pointer) {
		this.uiContainer = new PIXI.Container();
		var bg = new PIXI.Graphics();
		bg.beginFill(819422);
		bg.drawRect(-18.125,-18.,880,428);
		bg.endFill();
		this.waveform = new drums_view_edit_WaveformPanel();
		this.cellInfo = new drums_view_edit_CellInfoPanel();
		this.uiContainer.addChild(bg);
		this.uiContainer.addChild(this.waveform);
		this.uiContainer.addChild(this.cellInfo);
		this.uiContainer.alpha = 0;
		this.addChild(this.uiContainer);
	}
	,onLaunched: function() {
		this.launching = false;
		this.bgSize = 1;
		this.fadeUI = true;
	}
	,onClosed: function() {
		this.trackIndex = -1;
		this.tickIndex = -1;
		this.closing = this.visible = false;
		this.bgSize = 0;
	}
	,drawBg: function(size,colour) {
		if(colour == null) colour = 2201331;
		this.bg.position.set(0,0);
		this.bg.clear();
		if(size == 1) {
			this.bg.beginFill(colour);
			this.bg.drawRect(-28.125,-28.,900,448);
			this.bg.endFill();
			return;
		}
		var size1 = size * size;
		var startX = this.tickIndex * 56.25;
		var startY = this.trackIndex * 56.;
		var right;
		var left;
		var up;
		var down;
		right = (this.displayWidth - startX - 56.25 + 28.125) * size1;
		down = (this.displayHeight - startY - 56. + 28.) * size1;
		left = (-startX * size1 - 56.25 + 28.125) * size1;
		up = (-startY * size1 - 56. + 28.) * size1;
		this.bg.beginFill(colour,size1);
		this.bg.drawRect(startX,startY,right,down);
		this.bg.drawRect(startX,startY,left,up);
		this.bg.drawRect(startX,startY,right,up);
		this.bg.drawRect(startX,startY,left,down);
		this.bg.endFill();
	}
	,playNow: function() {
		this.drums.playTrackCellNow(this.trackIndex,this.tickIndex);
	}
	,__class__: drums_view_edit_CellEditPanel
});
var drums_view_edit_CellInfoPanel = function() {
	drums_view_UIElement.call(this,170,43);
	this.bg.alpha = .66;
	this.trackName = new PIXI.Text("",{ font : "200 20px Roboto", fill : "white", align : "center"});
	this.trackName.position.set(15,10);
	this.addChild(this.trackName);
};
drums_view_edit_CellInfoPanel.__name__ = true;
drums_view_edit_CellInfoPanel.__super__ = drums_view_UIElement;
drums_view_edit_CellInfoPanel.prototype = $extend(drums_view_UIElement.prototype,{
	update: function(sequencer,i,j) {
		var jj = j + 1;
		var track = sequencer.tracks[i];
		this.trackName.text = track.name + " (" + (jj < 10?"0" + jj + "/16)":"" + jj + "/16)");
		this.drawBg((this.trackName.width | 0) + 30,43);
	}
	,__class__: drums_view_edit_CellInfoPanel
});
var drums_view_edit_WaveformPanel = function() {
	drums_view_UIElement.call(this,840,198);
	this.waveform = new drums_view_displays_Waveform(840,198);
	this.overlay = new PIXI.Graphics();
	this.addChildAt(this.overlay,1);
	this.addChildAt(this.waveform,2);
	this.updateOverlay(0,1);
};
drums_view_edit_WaveformPanel.__name__ = true;
drums_view_edit_WaveformPanel.__super__ = drums_view_UIElement;
drums_view_edit_WaveformPanel.prototype = $extend(drums_view_UIElement.prototype,{
	setup: function(drums1,trackIndex,tickIndex) {
		var buffer = drums1.tracks[trackIndex].source._buffer;
		this.waveform.drawBuffer(buffer);
	}
	,updateOverlay: function(offset,duration) {
		duration = duration - offset;
		var x = 840 * offset;
		var w = x + 840 * duration;
		w = Math.min(840 - x,w);
		this.overlay.clear();
		this.overlay.beginFill(0,.1);
		this.overlay.drawRect(x,0,w,198);
		this.overlay.endFill();
	}
	,drawBg: function(w,h) {
		drums_view_UIElement.prototype.drawBg.call(this,w,h);
		this.bg.lineStyle(1,6344447);
		this.bg.moveTo(0,h / 2);
		this.bg.lineTo(840,h / 2);
	}
	,__class__: drums_view_edit_WaveformPanel
});
var drums_view_sequencer_BeatLines = function(displayWidth,displayHeight) {
	PIXI.Container.call(this);
	this.interactive = false;
	this.interactiveChildren = false;
	this.displayWidth = displayWidth;
	this.displayHeight = displayHeight;
	this.xStep = displayWidth / 16;
	this.lines = [];
	var g;
	var _g = 0;
	while(_g < 16) {
		var i = _g++;
		g = new PIXI.Graphics();
		g.position.x = Math.round(this.xStep * i);
		this.lines.push(this.addChild(g));
	}
	var _g1 = 0;
	while(_g1 < 16) {
		var i1 = _g1++;
		this.tick(i1);
	}
	tones_utils_TimeUtil.get_frameTick().connect($bind(this,this.update));
};
drums_view_sequencer_BeatLines.__name__ = true;
drums_view_sequencer_BeatLines.__super__ = PIXI.Container;
drums_view_sequencer_BeatLines.prototype = $extend(PIXI.Container.prototype,{
	tick: function(index) {
		if(index < 0) return;
		this.drawLine(this.lines[index],16);
	}
	,update: function(dt) {
		var _g = 0;
		while(_g < 16) {
			var i = _g++;
			var gfx = this.lines[i];
			var currentWidth = gfx.width;
			if(currentWidth > 1) {
				var w = currentWidth - (currentWidth - 1) * .15;
				this.drawLine(gfx,w);
			}
		}
	}
	,drawLine: function(g,w) {
		g.clear();
		g.beginFill(2201331,1);
		g.drawRect(-w / 2,0,w,this.displayHeight);
		g.endFill();
	}
	,__class__: drums_view_sequencer_BeatLines
});
var drums_view_sequencer_CellGrid = function(drums1) {
	PIXI.Container.call(this);
	this.drums = drums1;
	this.displayHeight = 448;
	this.cells = [];
	this.pointer = new drums_view_Pointer();
	this.cellEditPanel = new drums_view_edit_CellEditPanel(drums1,this.pointer,900,448);
	this.cellUI = new drums_view_sequencer_CellUI(this.pointer);
	this.cellUI.editEvent.connect(($_=this.cellEditPanel,$bind($_,$_.edit)));
	this.cellUI.toggleEvent.connect($bind(drums1,drums1.toggleEvent));
	this.createCells();
	this.cellEditPanel.closed.connect(($_=this.cellUI,$bind($_,$_.clear)));
	this.addChild(this.cellEditPanel);
};
drums_view_sequencer_CellGrid.__name__ = true;
drums_view_sequencer_CellGrid.__super__ = PIXI.Container;
drums_view_sequencer_CellGrid.prototype = $extend(PIXI.Container.prototype,{
	createCells: function() {
		var g;
		var background = new PIXI.Container();
		var _g = 0;
		while(_g < 8) {
			var i = _g++;
			var _g1 = 0;
			while(_g1 < 16) {
				var j = _g1++;
				g = new PIXI.Graphics();
				g.position.x = Math.round(j * 56.25);
				g.position.y = Math.round(i * 56.);
				this.drawCell(g,52,0);
				background.addChild(g);
			}
		}
		background.interactive = false;
		background.interactiveChildren = false;
		background.cacheAsBitmap = true;
		this.addChild(background);
		this.addChild(this.cellUI);
		var _g2 = 0;
		while(_g2 < 8) {
			var i1 = _g2++;
			this.cells.push([]);
			var _g11 = 0;
			while(_g11 < 16) {
				var j1 = _g11++;
				g = new PIXI.Graphics();
				g.position.x = Math.round(j1 * 56.25);
				g.position.y = Math.round(i1 * 56.);
				g.interactive = true;
				g.name = "" + i1 + "," + j1;
				this.pointer.watch(g);
				this.cells[i1].push(this.addChild(g));
			}
		}
	}
	,drawCell: function(g,size,color) {
		g.clear();
		g.beginFill(color,1);
		g.drawRect(-(size / 2),-(size / 2),size,size);
		g.endFill();
	}
	,tick: function(index) {
		if(index < 0) return;
		var cell;
		var event;
		var tracks = this.drums.tracks;
		var _g = 0;
		while(_g < 8) {
			var i = _g++;
			event = tracks[i].events[index];
			if(event.active) {
				cell = this.cells[i][index];
				cell.lineColor = 16777215;
				this.drawCell(cell,52,16777215);
			}
		}
		this.cellEditPanel.tick(index);
	}
	,update: function(dt) {
		var c;
		var cell;
		var active;
		var tracks = this.drums.tracks;
		var _g = 0;
		while(_g < 8) {
			var i = _g++;
			var _g1 = 0;
			while(_g1 < 16) {
				var j = _g1++;
				cell = this.cells[i][j];
				active = tracks[i].events[j].active;
				var w = cell.width;
				if(active && w > 41.6) {
					var p = (w / 41.6 - 1) * 4;
					var intensity = 48 + (207 * p | 0);
					var size = w - (w - 41.6) * .1;
					if(p < .001) size = 41.6;
					this.drawCell(cell,size,intensity | intensity << 8 | intensity << 16);
				} else {
					c = active?3158064:1184274;
					if(cell.lineColor != c) {
						cell.lineColor = c;
						this.drawCell(cell,41.6,c);
					}
				}
			}
		}
		this.cellUI.update();
		this.cellEditPanel.update();
	}
	,__class__: drums_view_sequencer_CellGrid
});
var drums_view_sequencer_CellUI = function(pointer) {
	this.isDown = false;
	this.fading = false;
	PIXI.Graphics.call(this);
	this.toggleEvent = new hxsignal_impl_Signal2();
	this.editEvent = new hxsignal_impl_Signal2();
	pointer.click.connect($bind(this,this.onClick));
	pointer.down.connect($bind(this,this.onDown));
	pointer.up.connect($bind(this,this.onPressCancel));
	pointer.longPress.connect($bind(this,this.onLongPress));
	pointer.pressCancel.connect($bind(this,this.onPressCancel));
	pointer.pressProgress.connect($bind(this,this.onPressProgress));
};
drums_view_sequencer_CellUI.__name__ = true;
drums_view_sequencer_CellUI.__super__ = PIXI.Graphics;
drums_view_sequencer_CellUI.prototype = $extend(PIXI.Graphics.prototype,{
	onClick: function(target) {
		if(target.parent != this.parent) return;
		var values = target.name.split(",");
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
		this.toggleEvent.emit(trackIndex,tickIndex);
	}
	,onDown: function(target) {
		if(target.parent != this.parent) return;
		this.clear();
		this.x = target.x;
		this.y = target.y;
		this.beginFill(2201331,0.25);
		this.drawRect(-26.,-26.,52,52);
		this.endFill();
		this.alpha = 0;
		this.isDown = true;
		this.fading = false;
	}
	,onPressProgress: function(target,p) {
		if(target.parent != this.parent) return;
		this.x = target.x;
		this.y = target.y;
		this.clear();
		this.alpha = 1;
		var pp = p * p;
		var ppp = pp * p;
		this.beginFill(2201331,.25 + ppp * .25);
		this.drawRect(-26.,-26.,52,52);
		this.endFill();
		this.beginFill(2201331,pp);
		this.drawRect(-26.,-26.,pp * 52,52);
		this.endFill();
	}
	,onLongPress: function(target) {
		if(target.parent != this.parent) return;
		this.isDown = false;
		this.beginFill(2201331,1);
		this.drawRect(-26.,-26.,52,52);
		this.endFill();
		var values = target.name.split(",");
		var trackIndex = Std.parseInt(values[0]);
		var tickIndex = Std.parseInt(values[1]);
		this.editEvent.emit(trackIndex,tickIndex);
	}
	,onPressCancel: function(target) {
		if(target != null && target.parent != this.parent) return;
		this.fading = true;
		this.isDown = false;
	}
	,update: function() {
		if(this.fading) {
			if(this.alpha > 0.001) this.alpha *= .75; else {
				this.clear();
				this.alpha = 1;
				this.fading = false;
			}
		} else if(this.isDown) {
			if(this.alpha < 1) this.alpha += .05;
		}
	}
	,__class__: drums_view_sequencer_CellUI
});
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
var haxe_ds_BalancedTree = function() {
};
haxe_ds_BalancedTree.__name__ = true;
haxe_ds_BalancedTree.prototype = {
	set: function(key,value) {
		this.root = this.setLoop(key,value,this.root);
	}
	,get: function(key) {
		var node = this.root;
		while(node != null) {
			var c = this.compare(key,node.key);
			if(c == 0) return node.value;
			if(c < 0) node = node.left; else node = node.right;
		}
		return null;
	}
	,iterator: function() {
		var ret = [];
		this.iteratorLoop(this.root,ret);
		return HxOverrides.iter(ret);
	}
	,setLoop: function(k,v,node) {
		if(node == null) return new haxe_ds_TreeNode(null,k,v,null);
		var c = this.compare(k,node.key);
		var tmp;
		if(c == 0) tmp = new haxe_ds_TreeNode(node.left,k,v,node.right,node == null?0:node._height); else if(c < 0) {
			var nl = this.setLoop(k,v,node.left);
			tmp = this.balance(nl,node.key,node.value,node.right);
		} else {
			var nr = this.setLoop(k,v,node.right);
			tmp = this.balance(node.left,node.key,node.value,nr);
		}
		return tmp;
	}
	,iteratorLoop: function(node,acc) {
		if(node != null) {
			this.iteratorLoop(node.left,acc);
			acc.push(node.value);
			this.iteratorLoop(node.right,acc);
		}
	}
	,balance: function(l,k,v,r) {
		var hl = l == null?0:l._height;
		var hr = r == null?0:r._height;
		var tmp;
		if(hl > hr + 2) {
			var tmp1;
			var _this = l.left;
			if(_this == null) tmp1 = 0; else tmp1 = _this._height;
			var tmp2;
			var _this1 = l.right;
			if(_this1 == null) tmp2 = 0; else tmp2 = _this1._height;
			if(tmp1 >= tmp2) tmp = new haxe_ds_TreeNode(l.left,l.key,l.value,new haxe_ds_TreeNode(l.right,k,v,r)); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l.left,l.key,l.value,l.right.left),l.right.key,l.right.value,new haxe_ds_TreeNode(l.right.right,k,v,r));
		} else if(hr > hl + 2) {
			var tmp3;
			var _this2 = r.right;
			if(_this2 == null) tmp3 = 0; else tmp3 = _this2._height;
			var tmp4;
			var _this3 = r.left;
			if(_this3 == null) tmp4 = 0; else tmp4 = _this3._height;
			if(tmp3 > tmp4) tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left),r.key,r.value,r.right); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left.left),r.left.key,r.left.value,new haxe_ds_TreeNode(r.left.right,r.key,r.value,r.right));
		} else tmp = new haxe_ds_TreeNode(l,k,v,r,(hl > hr?hl:hr) + 1);
		return tmp;
	}
	,compare: function(k1,k2) {
		return Reflect.compare(k1,k2);
	}
	,__class__: haxe_ds_BalancedTree
};
var haxe_ds_TreeNode = function(l,k,v,r,h) {
	if(h == null) h = -1;
	this.left = l;
	this.key = k;
	this.value = v;
	this.right = r;
	if(h == -1) {
		var tmp;
		var _this = this.left;
		if(_this == null) tmp = 0; else tmp = _this._height;
		var tmp1;
		var _this1 = this.right;
		if(_this1 == null) tmp1 = 0; else tmp1 = _this1._height;
		var tmp2;
		if(tmp > tmp1) {
			var _this2 = this.left;
			if(_this2 == null) tmp2 = 0; else tmp2 = _this2._height;
		} else {
			var _this3 = this.right;
			if(_this3 == null) tmp2 = 0; else tmp2 = _this3._height;
		}
		this._height = tmp2 + 1;
	} else this._height = h;
};
haxe_ds_TreeNode.__name__ = true;
haxe_ds_TreeNode.prototype = {
	__class__: haxe_ds_TreeNode
};
var haxe_ds_IntMap = function() {
	this.h = { };
};
haxe_ds_IntMap.__name__ = true;
haxe_ds_IntMap.__interfaces__ = [haxe_IMap];
haxe_ds_IntMap.prototype = {
	remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,__class__: haxe_ds_IntMap
};
var haxe_ds_ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe_ds_ObjectMap.__name__ = true;
haxe_ds_ObjectMap.__interfaces__ = [haxe_IMap];
haxe_ds_ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe_ds_ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,remove: function(key) {
		var id = key.__id__;
		if(this.h.__keys__[id] == null) return false;
		delete(this.h[id]);
		delete(this.h.__keys__[id]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i.__id__];
		}};
	}
	,__class__: haxe_ds_ObjectMap
};
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		return this.rh == null?null:this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,__class__: haxe_ds_StringMap
};
var hxsignal_ConnectionTimes = { __ename__ : true, __constructs__ : ["Once","Times","Forever"] };
hxsignal_ConnectionTimes.Once = ["Once",0];
hxsignal_ConnectionTimes.Once.toString = $estr;
hxsignal_ConnectionTimes.Once.__enum__ = hxsignal_ConnectionTimes;
hxsignal_ConnectionTimes.Times = function(t) { var $x = ["Times",1,t]; $x.__enum__ = hxsignal_ConnectionTimes; $x.toString = $estr; return $x; };
hxsignal_ConnectionTimes.Forever = ["Forever",2];
hxsignal_ConnectionTimes.Forever.toString = $estr;
hxsignal_ConnectionTimes.Forever.__enum__ = hxsignal_ConnectionTimes;
var hxsignal_ConnectPosition = { __ename__ : true, __constructs__ : ["AtBack","AtFront"] };
hxsignal_ConnectPosition.AtBack = ["AtBack",0];
hxsignal_ConnectPosition.AtBack.toString = $estr;
hxsignal_ConnectPosition.AtBack.__enum__ = hxsignal_ConnectPosition;
hxsignal_ConnectPosition.AtFront = ["AtFront",1];
hxsignal_ConnectPosition.AtFront.toString = $estr;
hxsignal_ConnectPosition.AtFront.__enum__ = hxsignal_ConnectPosition;
var hxsignal_ds_LinkedList = function() {
	List.call(this);
};
hxsignal_ds_LinkedList.__name__ = true;
hxsignal_ds_LinkedList.__super__ = List;
hxsignal_ds_LinkedList.prototype = $extend(List.prototype,{
	__class__: hxsignal_ds_LinkedList
});
var hxsignal_ds_TreeMap = function() {
	haxe_ds_BalancedTree.call(this);
};
hxsignal_ds_TreeMap.__name__ = true;
hxsignal_ds_TreeMap.__super__ = haxe_ds_BalancedTree;
hxsignal_ds_TreeMap.prototype = $extend(haxe_ds_BalancedTree.prototype,{
	firstKey: function() {
		var first = this.getFirstNode();
		return first != null?first.key:null;
	}
	,lastKey: function() {
		var last = this.getLastNode();
		return last != null?last.key:null;
	}
	,firstValue: function() {
		var first = this.getFirstNode();
		return first != null?first.value:null;
	}
	,lastValue: function() {
		var last = this.getLastNode();
		return last != null?last.value:null;
	}
	,getFirstNode: function() {
		var n = this.root;
		if(n != null) while(n.left != null) n = n.left;
		return n;
	}
	,getLastNode: function() {
		var n = this.root;
		if(n != null) while(n.right != null) n = n.right;
		return n;
	}
	,__class__: hxsignal_ds_TreeMap
});
var hxsignal_impl_Connection = function(signal,slot,times) {
	this.signal = signal;
	if(slot == null) throw new js__$Boot_HaxeError("Slot cannot be null");
	this.slot = slot;
	this.times = times;
	this.blocked = false;
	this.connected = true;
	this.calledTimes = 0;
};
hxsignal_impl_Connection.__name__ = true;
hxsignal_impl_Connection.prototype = {
	__class__: hxsignal_impl_Connection
};
var hxsignal_impl_SignalBase = function() {
	this.slots = new hxsignal_impl_SlotMap();
};
hxsignal_impl_SignalBase.__name__ = true;
hxsignal_impl_SignalBase.prototype = {
	connect: function(slot,times,groupId,at) {
		if(times == null) times = hxsignal_ConnectionTimes.Forever;
		if(!this.updateConnection(slot,times)) {
			var conn = new hxsignal_impl_Connection(this,slot,times);
			this.slots.insert(conn,groupId,at);
		}
	}
	,updateConnection: function(slot,times,groupId,at) {
		var con = this.slots.get(slot);
		if(con == null) return false;
		if(groupId != null && con.groupId != groupId || at != null) {
			this.slots.disconnect(slot);
			return false;
		}
		con.times = times;
		con.calledTimes = 0;
		con.connected = true;
		return true;
	}
	,isConnected: function(slot) {
		return this.slots.has(slot);
	}
	,loop: function(delegate) {
		this.emitting = true;
		var $it0 = this.slots.groups.iterator();
		while( $it0.hasNext() ) {
			var g = $it0.next();
			var _g_head = g.h;
			var _g_val = null;
			while(_g_head != null) {
				var tmp;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				tmp = _g_val;
				var con = tmp;
				if(con.connected && !con.blocked) {
					con.calledTimes++;
					delegate(con);
					if(!con.connected) this.slots.disconnect(con.slot);
					if(con.times == hxsignal_ConnectionTimes.Once) con.times = hxsignal_ConnectionTimes.Times(1);
					{
						var _g = con.times;
						switch(_g[1]) {
						case 1:
							if(_g[2] <= con.calledTimes) this.slots.disconnect(con.slot);
							break;
						default:
						}
					}
				}
			}
		}
		this.emitting = false;
	}
	,__class__: hxsignal_impl_SignalBase
};
var hxsignal_impl_Signal0 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal0.__name__ = true;
hxsignal_impl_Signal0.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal0.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function() {
		var delegate = function(con) {
			con.slot();
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal0
});
var hxsignal_impl_Signal1 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal1.__name__ = true;
hxsignal_impl_Signal1.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal1.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function(p1) {
		var delegate = function(con) {
			con.slot(p1);
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal1
});
var hxsignal_impl_Signal2 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal2.__name__ = true;
hxsignal_impl_Signal2.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal2.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function(p1,p2) {
		var delegate = function(con) {
			con.slot(p1,p2);
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal2
});
var hxsignal_impl_SlotMap = function() {
	this.clear();
};
hxsignal_impl_SlotMap.__name__ = true;
hxsignal_impl_SlotMap.prototype = {
	clear: function() {
		this.slots = new haxe_ds_ObjectMap();
		this.groups = new hxsignal_ds_TreeMap();
		this.groups.set(0,new hxsignal_ds_LinkedList());
	}
	,insert: function(con,groupId,at) {
		if(at == null) at = hxsignal_ConnectPosition.AtBack;
		this.slots.set(con.slot,con);
		var group;
		if(groupId == null) {
			if(at != null) switch(at[1]) {
			case 1:
				groupId = this.groups.firstKey();
				group = this.groups.firstValue();
				break;
			default:
				groupId = this.groups.lastKey();
				group = this.groups.lastValue();
			} else {
				groupId = this.groups.lastKey();
				group = this.groups.lastValue();
			}
		} else {
			group = this.groups.get(groupId);
			if(group == null) {
				group = new hxsignal_ds_LinkedList();
				this.groups.set(groupId,group);
			}
		}
		con.groupId = groupId;
		if(at != null) switch(at[1]) {
		case 1:
			group.push(con);
			break;
		default:
			group.add(con);
		} else group.add(con);
	}
	,get: function(slot) {
		return this.slots.h[slot.__id__];
	}
	,has: function(slot) {
		return this.slots.h[slot.__id__] != null;
	}
	,disconnect: function(slot) {
		var con = this.slots.h[slot.__id__];
		if(con == null) return false;
		this.slots.remove(slot);
		con.connected = false;
		return true;
	}
	,__class__: hxsignal_impl_SlotMap
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return (Function("return typeof " + name + " != \"undefined\" ? " + name + " : null"))();
};
var js_Cookie = function() { };
js_Cookie.__name__ = true;
js_Cookie.set = function(name,value,expireDelay,path,domain) {
	var s = name + "=" + encodeURIComponent(value);
	if(expireDelay != null) {
		var d2 = (function($this) {
			var $r;
			var d = new Date();
			$r = (function($this) {
				var $r;
				var t = d.getTime() + expireDelay * 1000;
				var d1 = new Date();
				d1.setTime(t);
				$r = d1;
				return $r;
			}($this));
			return $r;
		}(this));
		s += ";expires=" + d2.toGMTString();
	}
	if(path != null) s += ";path=" + path;
	if(domain != null) s += ";domain=" + domain;
	window.document.cookie = s;
};
js_Cookie.all = function() {
	var h = new haxe_ds_StringMap();
	var a = window.document.cookie.split(";");
	var _g = 0;
	while(_g < a.length) {
		var e = a[_g];
		++_g;
		e = StringTools.ltrim(e);
		var t = e.split("=");
		if(t.length < 2) continue;
		var key = t[0];
		var value = decodeURIComponent(t[1].split("+").join(" "));
		if(__map_reserved[key] != null) h.setReserved(key,value); else h.h[key] = value;
	}
	return h;
};
js_Cookie.get = function(name) {
	var tmp;
	var _this = js_Cookie.all();
	if(__map_reserved[name] != null) tmp = _this.getReserved(name); else tmp = _this.h[name];
	return tmp;
};
js_Cookie.exists = function(name) {
	var tmp;
	var _this = js_Cookie.all();
	if(__map_reserved[name] != null) tmp = _this.existsReserved(name); else tmp = _this.h.hasOwnProperty(name);
	return tmp;
};
var parameter_Interpolation = function() { };
parameter_Interpolation.__name__ = true;
var parameter_InterpolationNone = function() { };
parameter_InterpolationNone.__name__ = true;
parameter_InterpolationNone.__interfaces__ = [parameter_Interpolation];
var parameter_InterpolationLinear = function() { };
parameter_InterpolationLinear.__name__ = true;
parameter_InterpolationLinear.__interfaces__ = [parameter_Interpolation];
var parameter_InterpolationExponential = function() { };
parameter_InterpolationExponential.__name__ = true;
parameter_InterpolationExponential.__interfaces__ = [parameter_Interpolation];
var parameter_IMapping = function() { };
parameter_IMapping.__name__ = true;
parameter_IMapping.prototype = {
	__class__: parameter_IMapping
};
var parameter_MapBool = function(min,max) {
	this.min = min;
	this.max = max;
};
parameter_MapBool.__name__ = true;
parameter_MapBool.__interfaces__ = [parameter_IMapping];
parameter_MapBool.prototype = {
	map: function(normalizedValue) {
		return normalizedValue == 1.0?this.max:this.min;
	}
	,mapInverse: function(value) {
		return value == this.max?1.0:.0;
	}
	,__class__: parameter_MapBool
};
var parameter_MapIntLinear = function(min,max) {
	if(max == null) max = 1;
	if(min == null) min = 0;
	this.min = min;
	this.max = max;
};
parameter_MapIntLinear.__name__ = true;
parameter_MapIntLinear.__interfaces__ = [parameter_IMapping];
parameter_MapIntLinear.prototype = {
	map: function(normalisedValue) {
		return Math.round(this.min + normalisedValue * (this.max - this.min));
	}
	,mapInverse: function(value) {
		return (value - this.min) / (this.max - this.min);
	}
	,__class__: parameter_MapIntLinear
};
var parameter_MapFloatLinear = function(min,max) {
	if(max == null) max = 1;
	if(min == null) min = 0;
	this.min = min;
	this.max = max;
};
parameter_MapFloatLinear.__name__ = true;
parameter_MapFloatLinear.__interfaces__ = [parameter_IMapping];
parameter_MapFloatLinear.prototype = {
	map: function(normalisedValue) {
		return this.min + normalisedValue * (this.max - this.min);
	}
	,mapInverse: function(value) {
		return (value - this.min) / (this.max - this.min);
	}
	,__class__: parameter_MapFloatLinear
};
var parameter_MapFloatExponential = function(min,max) {
	if(max == null) max = 1.0;
	if(min == null) min = .0;
	this.setMinMax(min,max);
};
parameter_MapFloatExponential.__name__ = true;
parameter_MapFloatExponential.__interfaces__ = [parameter_IMapping];
parameter_MapFloatExponential.prototype = {
	setMinMax: function(min,max) {
		this.min = min;
		this.max = max;
		this._t2 = 0;
		if(min <= 0) this._t2 = 1 + min * -1;
		this._min = min + this._t2;
		this._max = max + this._t2;
		this._t0 = Math.log(this._max / this._min);
		this._t1 = 1.0 / this._t0;
	}
	,map: function(normalisedValue) {
		return this._min * Math.exp(normalisedValue * this._t0) - this._t2;
	}
	,mapInverse: function(value) {
		return Math.log((value + this._t2) / this._min) * this._t1;
	}
	,__class__: parameter_MapFloatExponential
};
var parameter_ParameterBase = function(name,mapping) {
	this.name = name;
	this.mapping = mapping;
	this.change = new hxsignal_impl_Signal1();
	this.setDefault(mapping.min);
};
parameter_ParameterBase.__name__ = true;
parameter_ParameterBase.prototype = {
	setDefault: function(value,normalised) {
		if(normalised == null) normalised = false;
		var normValue;
		if(normalised) {
			normValue = value;
			value = this.mapping.map(normValue);
		} else normValue = this.mapping.mapInverse(value);
		this.normalisedDefaultValue = normValue;
		this.defaultValue = value;
		this.setValue(normValue,true);
	}
	,setValue: function(value,normalised,forced) {
		if(forced == null) forced = false;
		if(normalised == null) normalised = false;
		var normValue = normalised?value:this.mapping.mapInverse(value);
		if(forced || normValue != this.normalisedValue) {
			this.normalisedValue = normValue;
			this.change.emit(this);
		}
	}
	,getValue: function(normalised) {
		if(normalised == null) normalised = false;
		if(normalised) return this.normalisedValue;
		return this.mapping.map(this.normalisedValue);
	}
	,addObserver: function(callback,triggerImmediately,once) {
		if(once == null) once = false;
		if(triggerImmediately == null) triggerImmediately = false;
		if(!this.change.isConnected(callback)) this.change.connect(callback,once?hxsignal_ConnectionTimes.Once:hxsignal_ConnectionTimes.Forever);
		if(triggerImmediately) this.change.emit(this);
	}
	,__class__: parameter_ParameterBase
};
var parameter__$Parameter_Parameter_$Impl_$ = {};
parameter__$Parameter_Parameter_$Impl_$.__name__ = true;
parameter__$Parameter_Parameter_$Impl_$.getBool = function(min,max) {
	return new parameter_MapBool(min,max);
};
parameter__$Parameter_Parameter_$Impl_$.getFloat = function(min,max) {
	return new parameter_MapFloatLinear(min,max);
};
parameter__$Parameter_Parameter_$Impl_$.getFloatExponential = function(min,max) {
	return new parameter_MapFloatExponential(min,max);
};
parameter__$Parameter_Parameter_$Impl_$.getInt = function(min,max) {
	return new parameter_MapIntLinear(min,max);
};
var tones_AudioBase = function(audioContext,destinationNode) {
	this.lastTime = .0;
	this.ID = 0;
	if(audioContext == null) this.context = tones_AudioBase.createContext(); else this.context = audioContext;
	if(destinationNode == null) this.destination = this.context.destination; else this.destination = destinationNode;
	this.delayedBegin = [];
	this.delayedRelease = [];
	this.delayedEnd = [];
	this.timedEvents = [];
	this.lastId = this.ID;
	this.polyphony = 0;
	this.activeItems = new haxe_ds_IntMap();
	this.itemRelease = new hxsignal_impl_Signal2();
	this.itemBegin = new hxsignal_impl_Signal2();
	this.itemEnd = new hxsignal_impl_Signal1();
	this.timedEvent = new hxsignal_impl_Signal2();
	this.releaseFudge = window.navigator.userAgent.indexOf("Firefox") > -1?4096 / this.context.sampleRate:0;
	this.set_attack(0.0);
	this.set_release(1.0);
	this.set_volume(.2);
	tones_utils_TimeUtil.get_frameTick().connect($bind(this,this.tick));
};
tones_AudioBase.__name__ = true;
tones_AudioBase.createContext = function() {
	return new (window.AudioContext || window.webkitAudioContext)();
};
tones_AudioBase.prototype = {
	doRelease: function(id,atTime) {
		if(atTime == null) atTime = -1;
		var data = this.activeItems.h[id];
		if(data == null) return;
		var time;
		var nowTime = this.context.currentTime;
		if(atTime < nowTime) time = nowTime; else time = atTime;
		time += this.releaseFudge;
		data.env.gain.cancelScheduledValues(time);
		data.env.gain.setTargetAtTime(0,time,Math.log(this._release + 1.0) / 4.605170185988092);
		this.delayedRelease.push({ id : id, time : time});
		this.delayedEnd.push({ id : id, time : time + this._release});
	}
	,doStop: function(id) {
		var data = this.activeItems.h[id];
		if(data == null) return;
		data.src.stop(this.context.currentTime);
		data.src.disconnect();
		data.env.gain.cancelScheduledValues(this.context.currentTime);
		data.env.disconnect();
		this.triggerItemEnd(id);
		this.activeItems.remove(id);
	}
	,addTimedEvent: function(time) {
		if(time < this.context.currentTime) return -1;
		var tmp;
		this.lastId = this.ID;
		this.ID++;
		tmp = this.lastId;
		var id = tmp;
		this.timedEvents.push({ id : id, time : time});
		return id;
	}
	,removeAllTimedEvents: function() {
		this.timedEvents = [];
	}
	,set_attack: function(value) {
		if(value < 0.001) value = 0;
		return this._attack = value;
	}
	,set_release: function(value) {
		if(value < 0.001) value = 0.001;
		return this._release = value;
	}
	,set_volume: function(value) {
		if(value < 0) value = 0;
		return this._volume = value;
	}
	,triggerItemBegin: function(id,time) {
		this.polyphony++;
		this.itemBegin.emit(id,time);
	}
	,triggerItemEnd: function(id) {
		this.polyphony--;
		this.itemEnd.emit(id);
	}
	,tick: function(_) {
		var t = this.context.currentTime;
		var dt = t - this.lastTime;
		this.lastTime = t;
		t += dt + dt;
		var j = 0;
		var n = this.timedEvents.length;
		while(j < n) {
			var item = this.timedEvents[j];
			if(t > item.time) {
				this.timedEvent.emit(item.id,item.time);
				this.timedEvents.splice(j,1);
				n--;
			} else j++;
		}
		var j1 = 0;
		var n1 = this.delayedBegin.length;
		while(j1 < n1) {
			var item1 = this.delayedBegin[j1];
			if(t > item1.time) {
				this.triggerItemBegin(item1.id,item1.time);
				this.delayedBegin.splice(j1,1);
				n1--;
			} else j1++;
		}
		j1 = 0;
		n1 = this.delayedRelease.length;
		while(j1 < n1) {
			var item2 = this.delayedRelease[j1];
			if(t > item2.time) {
				this.itemRelease.emit(item2.id,item2.time);
				this.delayedRelease.splice(j1,1);
				n1--;
			} else j1++;
		}
		j1 = 0;
		n1 = this.delayedEnd.length;
		while(j1 < n1) {
			var item3 = this.delayedEnd[j1];
			if(this.lastTime >= item3.time) {
				this.doStop(item3.id);
				this.delayedEnd.splice(j1,1);
				n1--;
			} else j1++;
		}
	}
	,__class__: tones_AudioBase
};
var tones_Samples = function(audioContext,destinationNode) {
	this._buffer = null;
	tones_AudioBase.call(this,audioContext,destinationNode);
	this.playbackRate = 1.0;
	this.offset = 0;
	this.duration = 0;
};
tones_Samples.__name__ = true;
tones_Samples.__super__ = tones_AudioBase;
tones_Samples.prototype = $extend(tones_AudioBase.prototype,{
	set_buffer: function(value) {
		this.offset = 0;
		this.duration = value.duration;
		return this._buffer = value;
	}
	,playSample: function(buffer,delayBy,autoRelease) {
		if(autoRelease == null) autoRelease = true;
		if(delayBy == null) delayBy = .0;
		if(buffer != null) this.set_buffer(buffer);
		if(delayBy < 0) delayBy = 0;
		var tmp;
		this.lastId = this.ID;
		this.ID++;
		tmp = this.lastId;
		var id = tmp;
		var envelope = this.context.createGain();
		var triggerTime = this.context.currentTime + delayBy;
		var releaseTime = triggerTime + this._attack;
		if(this._attack > 0) {
			envelope.gain.value = 0;
			envelope.gain.setTargetAtTime(this._volume,triggerTime,Math.log(this._attack + 1.0) / 4.605170185988092);
		} else envelope.gain.value = this._volume;
		envelope.connect(this.destination);
		var src = this.context.createBufferSource();
		src.buffer = this._buffer;
		src.playbackRate.value = this.playbackRate;
		if(this.duration <= 0) this.duration = src.buffer.duration;
		src.connect(envelope);
		src.start(triggerTime,this.offset,this.duration);
		this.activeItems.h[id] = { id : id, src : src, volume : this._volume, env : envelope, attack : this._attack, release : this._release, triggerTime : triggerTime};
		if(delayBy == 0) this.triggerItemBegin(id,triggerTime); else this.delayedBegin.push({ id : id, time : triggerTime});
		if(autoRelease) this.doRelease(id,releaseTime);
		return id;
	}
	,__class__: tones_Samples
});
var tones_data_OscillatorTypeShim = function() { };
tones_data_OscillatorTypeShim.__name__ = true;
var tones_utils_AudioNodeRecorder = function(source,bufferSize,workerPath) {
	if(workerPath == null) workerPath = "js/recorderWorker.js";
	if(bufferSize == null) bufferSize = 4096;
	var context = source.context;
	this.node = context.createScriptProcessor(bufferSize,2,2);
	this.worker = new Worker(workerPath);
	this.recording = false;
	this.wavEncoded = new hxsignal_impl_Signal1();
	this.bufferExported = new hxsignal_impl_Signal1();
	this.worker.postMessage({ command : "init", config : { sampleRate : context.sampleRate}});
	this.worker.onmessage = $bind(this,this.onWorkerMessage);
	this.node.onaudioprocess = $bind(this,this.onAudioProcess);
	source.connect(this.node);
	this.node.connect(context.destination);
};
tones_utils_AudioNodeRecorder.__name__ = true;
tones_utils_AudioNodeRecorder.prototype = {
	onWorkerMessage: function(e) {
		if(js_Boot.__instanceof(e.data,Blob)) this.wavEncoded.emit(e.data); else if((e.data instanceof Array) && e.data.__enum__ == null) this.bufferExported.emit(e.data); else throw new js__$Boot_HaxeError("Unexpected message data");
	}
	,onAudioProcess: function(e) {
		if(!this.recording) return;
		tones_utils_AudioNodeRecorder.RecordBufferMessage.buffer[0] = e.inputBuffer.getChannelData(0);
		tones_utils_AudioNodeRecorder.RecordBufferMessage.buffer[1] = e.inputBuffer.getChannelData(1);
		this.worker.postMessage(tones_utils_AudioNodeRecorder.RecordBufferMessage);
	}
	,__class__: tones_utils_AudioNodeRecorder
};
var tones_utils_TimeUtil = function() { };
tones_utils_TimeUtil.__name__ = true;
tones_utils_TimeUtil.get_frameTick = function() {
	return tones_utils_TimeUtil._frameTick;
};
tones_utils_TimeUtil.onFrame = function(_) {
	tones_utils_TimeUtil._frameTick.emit(_);
	window.requestAnimationFrame(tones_utils_TimeUtil.onFrame);
};
var util_WebFontEmbed = function() { };
util_WebFontEmbed.__name__ = true;
util_WebFontEmbed.load = function() {
	var config = { google : { families : ["Roboto:300,400,500,700"]}, active : util_WebFontEmbed.loaded};
	var o = window;
	o.WebFontConfig = config;
	var tmp;
	var _this = window.document;
	tmp = _this.createElement("script");
	var wf = tmp;
	wf.src = "https://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js";
	wf.type = "text/javascript";
	wf.async = true;
	var s = window.document.getElementsByTagName("script")[0];
	s.parentNode.insertBefore(wf,s);
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var __map_reserved = {}
var q = window.jQuery;
var js = js || {}
js.JQuery = q;
var node = window.OscillatorNode;
if(node != null) {
	if(Object.prototype.hasOwnProperty.call(node,"SINE")) {
		window.OscillatorTypeShim = {SINE:node.SINE, SQUARE:node.SQUARE, TRIANGLE:node.TRIANGLE, SAWTOOTH:node.SAWTOOTH, CUSTOM:node.CUSTOM}
	} else {
		window.OscillatorTypeShim = {SINE:"sine", SQUARE:"square", TRIANGLE:"triangle", SAWTOOTH:"sawtooth", CUSTOM:"custom"}
	}
}
tones_utils_TimeUtil._frameTick = new hxsignal_impl_Signal1();
window.requestAnimationFrame(tones_utils_TimeUtil.onFrame);
drums_DrumSequencer.filenames = ["Kick01","Snare01","Snare02","Rim01","Rim02","Clave01","Clave02","Cowbell"];
drums_DrumSequencer.trackNames = ["Kick","Snare 1","Snare 2","Rim 1","Rim 2","Clave 1","Clave 2","Cowbell"];
haxe_ds_ObjectMap.count = 0;
js_Boot.__toStr = {}.toString;
tones_utils_AudioNodeRecorder.RecordBufferMessage = { command : "record", buffer : []};
tones_utils_AudioNodeRecorder.EncodeWAVMessage = { command : "exportWAV", type : "audio/wav"};
tones_utils_AudioNodeRecorder.ClearBufferMessage = { command : "clear"};
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
