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
		if(parentDom == null) window.document.body.appendChild(this.canvas); else parentDom.appendChild(this.canvas);
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
		window.document.body.appendChild(this.renderer.view);
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
};
var Main = function() {
	pixi_plugins_app_Application.call(this);
	this.ready = false;
	this.initAudio();
	this.initPixi();
	this.initOscilliscope();
	this.initBeatLines();
	this.initStepGrid();
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
	initAudio: function() {
		this.audioContext = tones_AudioBase.createContext();
		this.outGain = this.audioContext.createGain();
		this.outGain.gain.value = .2;
		this.outGain.connect(this.audioContext.destination);
		this.drums = new drums_DrumSequencer(this.audioContext,this.outGain);
		this.drums.tick.connect($bind(this,this.onSequenceTick));
		this.drums.ready.connect($bind(this,this.onDrumsReady));
	}
	,onDrumsReady: function() {
		this.ready = true;
	}
	,onSequenceTick: function(index) {
		this.beatLines.tick(index);
		this.sequenceGrid.tick(index);
		if(index == 0 && Math.random() > .5) {
			var tmp;
			var x = Math.random() * 8;
			tmp = x | 0;
			this.drums.tracks[tmp].randomise();
		}
		if(Math.random() > .75) {
			var tmp1;
			var x1 = Math.random() * 8;
			tmp1 = x1 | 0;
			var tmp2;
			var x2 = Math.random() * 16;
			tmp2 = x2 | 0;
			this.drums.tracks[tmp1].events[tmp2].active = Math.round(Math.random()) == 1;
		}
	}
	,initPixi: function() {
		this.backgroundColor = 3355443;
		this.antialias = true;
		this.onUpdate = $bind(this,this.tick);
		this.onResize = $bind(this,this.stageResized);
		this.start("auto");
		var txt = new PIXI.Text("Drums",{ font : "normal 24px Raleway", fill : "white", align : "lefts"});
		this.stage.addChild(txt);
		txt.position.x = 10;
		txt.position.y = 10;
		this.stage.interactive = true;
	}
	,initOscilliscope: function() {
		this.oscilliscope = new drums_Oscilliscope(this.audioContext,568,120);
		this.stage.addChild(this.oscilliscope);
		this.drums.outGain.connect(this.oscilliscope.analyser);
	}
	,initBeatLines: function() {
		this.beatLines = new drums_BeatLines(600,320);
		this.stage.addChild(this.beatLines);
	}
	,initStepGrid: function() {
		this.sequenceGrid = new drums_SequenceGrid(600,320,this.drums);
		this.stage.addChild(this.sequenceGrid);
	}
	,tick: function(dt) {
		if(!this.ready) return;
		this.oscilliscope.update(dt);
		this.sequenceGrid.update(dt);
	}
	,stageResized: function() {
		var w2 = this.width / 2 + 20;
		var h2 = this.height / 2 - 40;
		this.beatLines.position.x = w2 - this.beatLines.displayWidth / 2;
		this.beatLines.position.y = h2 - this.beatLines.displayHeight / 2;
		this.sequenceGrid.x = this.beatLines.position.x;
		this.sequenceGrid.y = this.beatLines.position.y;
		this.oscilliscope.position.x = this.beatLines.position.x - 2;
		this.oscilliscope.position.y = 160 + this.beatLines.position.y + this.beatLines.displayHeight / 2;
	}
});
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
};
var drums_BeatLines = function(displayWidth,displayHeight) {
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
drums_BeatLines.__name__ = true;
drums_BeatLines.__super__ = PIXI.Container;
drums_BeatLines.prototype = $extend(PIXI.Container.prototype,{
	tick: function(index) {
		if(index < 0) return;
		this.drawLine(this.lines[index],this.lineWidthForStep(index) * 4);
	}
	,update: function(dt) {
		var _g = 0;
		while(_g < 16) {
			var i = _g++;
			var gfx = this.lines[i];
			var currentWidth = gfx.width;
			var targetWidth = this.lineWidthForStep(i);
			if(currentWidth > targetWidth) {
				var w = currentWidth - (currentWidth - targetWidth) * .2;
				this.drawLine(gfx,w);
			}
		}
	}
	,drawLine: function(g,w) {
		g.clear();
		g.beginFill(65470,1);
		g.drawRect(-w / 2,-20,w,this.displayHeight);
		g.endFill();
	}
	,lineWidthForStep: function(index) {
		return index % 4 == 0?6:index % 2 == 0?3:1;
	}
});
var drums_DrumSequencer = function(audioContext,destination) {
	this.tickIndex = -1;
	this.tickLength = 0.25;
	this.bpm = 60 + Math.random() * 100;
	console.log("bpm:" + this.bpm);
	this.context = audioContext == null?tones_AudioBase.createContext():audioContext;
	this.outGain = this.context.createGain();
	this.outGain.connect(destination == null?this.context.destination:destination);
	this.ready = new hxsignal_impl_Signal0();
	this.tick = new hxsignal_impl_Signal1();
	this.tracks = [];
	this.loadSamples();
};
drums_DrumSequencer.__name__ = true;
drums_DrumSequencer.prototype = {
	loadSamples: function() {
		var _g1 = this;
		var names = ["Clave01","Clave02","Cowbell","Kick01","Rim01","Rim02","Snare01","Snare01"];
		var _g = 0;
		while(_g < names.length) {
			var name = names[_g];
			++_g;
			var request = new XMLHttpRequest();
			request.open("GET","data/samples/808_" + name + ".wav",true);
			request.responseType = "arraybuffer";
			request.onload = function(_) {
				_g1.context.decodeAudioData(_.currentTarget.response,$bind(_g1,_g1.sampleDecoded));
			};
			request.send();
		}
	}
	,sampleDecoded: function(buffer) {
		this.tracks.push(new drums_Track(buffer,this.context,this.outGain));
		if(this.tracks.length == 1) {
			this.timeTrack = this.tracks[0].source;
			this.timeTrack.timedEvent.connect($bind(this,this.onTrackTick));
		} else if(this.tracks.length == 8) {
			this.tickIndex = -1;
			this.timeTrack.addTimedEvent(this.context.currentTime + this.tickLength / (this.bpm / 60));
			this.ready.emit();
		}
	}
	,onTrackTick: function(id,time) {
		if(time < this.context.currentTime) time = this.context.currentTime;
		var nextTick = time + this.tickLength / (this.bpm / 60);
		this.timeTrack.addTimedEvent(nextTick);
		this.tick.emit(this.tickIndex);
		this.tickIndex++;
		if(this.tickIndex == 16) this.tickIndex = 0;
		this.playTick(this.tickIndex,nextTick);
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
				s.playbackRate = event.rate;
				s.set_release(event.release);
				track.set_pan(event.pan);
				s.playSample(null,time - this.context.currentTime);
			}
		}
	}
};
var drums_Track = function(buffer,context,destination) {
	this._pan = 0;
	this.panNode = context.createPanner();
	this.panNode.panningModel = "equalpower";
	this.panNode.connect(destination);
	this.source = new tones_Samples(context,this.panNode);
	this.source.set_attack(0);
	this.source.buffer = buffer;
	var tmp;
	var _g = [];
	var _g1 = 0;
	while(_g1 < 16) {
		_g1++;
		_g.push({ active : false, volume : 1, pan : 0, rate : 1, release : buffer.duration});
	}
	tmp = _g;
	this.events = tmp;
};
drums_Track.__name__ = true;
drums_Track.prototype = {
	randomise: function() {
		var buffer = this.source.buffer;
		var _g = 0;
		while(_g < 16) {
			var i = _g++;
			var rate = 1.1 - (1 + Math.random() * i) / 3;
			if(Math.random() < .5) rate = 2 - rate;
			var e = this.events[i];
			var tmp;
			var x = 16 * Math.random();
			tmp = x | 0;
			var tmp1;
			var x1 = Math.random() * 16;
			tmp1 = x1 | 0;
			e.active = tmp % tmp1 == 0;
			e.volume = .8 + Math.random() * .2;
			e.pan = Math.random() * (-0.5 + i / 32);
			e.rate = rate;
			e.release = buffer.duration / rate;
		}
	}
	,set_pan: function(value) {
		var x = value * 1.5707963267948966;
		var z = x + 1.5707963267948966;
		if(z > 1.5707963267948966) z = Math.PI - z;
		this.panNode.setPosition(Math.sin(x),0,Math.sin(z));
		return this._pan = value;
	}
};
var drums_Oscilliscope = function(audioContext,width,height) {
	PIXI.Graphics.call(this);
	this.displayWidth = width;
	this.displayHeight = height;
	this.analyser = audioContext.createAnalyser();
	this.analyser.smoothingTimeConstant = .8;
	this.analyser.fftSize = 512;
	this.analyserData = new Uint8Array(this.analyser.frequencyBinCount);
};
drums_Oscilliscope.__name__ = true;
drums_Oscilliscope.__super__ = PIXI.Graphics;
drums_Oscilliscope.prototype = $extend(PIXI.Graphics.prototype,{
	update: function(dt) {
		this.clear();
		var data = this.analyserData;
		var n = data.length;
		var xStep = this.displayWidth / n;
		var yScale = this.displayHeight / 256;
		this.analyser.getByteTimeDomainData(data);
		this.lineStyle(2,7631988);
		this.moveTo(0,this.displayHeight - data[0] * yScale);
		var _g = 0;
		while(_g < n) {
			var i = _g++;
			this.lineTo(i * xStep,this.displayHeight - data[i] * yScale);
		}
	}
});
var drums_SequenceGrid = function(displayWidth,displayHeight,drums1) {
	PIXI.Container.call(this);
	this.drums = drums1;
	this.displayWidth = displayWidth;
	this.displayHeight = displayHeight;
	this.xStep = displayWidth / 16;
	this.yStep = displayHeight / 8;
	this.cells = [];
	this.createCells();
};
drums_SequenceGrid.__name__ = true;
drums_SequenceGrid.__super__ = PIXI.Container;
drums_SequenceGrid.prototype = $extend(PIXI.Container.prototype,{
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
				g.position.x = Math.round(j * this.xStep);
				g.position.y = Math.round(i * this.yStep);
				this.drawCell(g,34,0);
				background.addChild(g);
			}
		}
		background.interactive = false;
		background.interactiveChildren = false;
		background.cacheAsBitmap = true;
		this.addChild(background);
		var _g2 = 0;
		while(_g2 < 8) {
			var i1 = _g2++;
			this.cells.push([]);
			var _g11 = 0;
			while(_g11 < 16) {
				var j1 = _g11++;
				g = new PIXI.Graphics();
				g.position.x = Math.round(j1 * this.xStep);
				g.position.y = Math.round(i1 * this.yStep);
				g.interactive = true;
				g.on("mousedown",$bind(this,this.onDown));
				g.on("touchstart",$bind(this,this.onDown));
				this.cells[i1].push(this.addChild(g));
			}
		}
	}
	,onDown: function(data) {
		console.log(data);
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
				this.drawCell(cell,34,16777215);
			}
		}
	}
	,update: function(dt) {
		var c;
		var cell;
		var tracks = this.drums.tracks;
		var _g = 0;
		while(_g < 8) {
			var i = _g++;
			var _g1 = 0;
			while(_g1 < 16) {
				var j = _g1++;
				cell = this.cells[i][j];
				if(cell.width > 17.) {
					var size = cell.width - (cell.width - 17.) * .15 | 0;
					this.drawCell(cell,size,16777215);
				} else {
					c = tracks[i].events[j].active?16777215:1184274;
					if(cell.lineColor != c) {
						cell.lineColor = c;
						this.drawCell(cell,17.,c);
					}
				}
			}
		}
	}
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
});
var hxsignal_impl_Connection = function(signal,slot,times) {
	this.signal = signal;
	if(slot == null) throw new js__$Boot_HaxeError("Slot cannot be null");
	this.slot = slot;
	this.times = times;
	this.blocked = false;
	this.connected = true;
};
hxsignal_impl_Connection.__name__ = true;
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
	,disconnect: function(slot) {
		var con = this.slots.h[slot.__id__];
		if(con == null) return false;
		this.slots.remove(slot);
		con.connected = false;
		return true;
	}
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
});
var js_Boot = function() { };
js_Boot.__name__ = true;
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
	,set_attack: function(value) {
		if(value < 0.001) value = 0.001;
		return this._attack = value;
	}
	,set_release: function(value) {
		if(value < 0.001) value = 0.001;
		return this._release = value;
	}
	,set_volume: function(value) {
		if(value < 0) value = 0; else if(value > 1) value = 1;
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
		var nextTime = t + dt * 2;
		var j = 0;
		var n = this.delayedBegin.length;
		while(j < n) {
			var item = this.delayedBegin[j];
			if(nextTime > item.time) {
				this.triggerItemBegin(item.id,item.time);
				this.delayedBegin.splice(j,1);
				n--;
			} else j++;
		}
		j = 0;
		n = this.delayedRelease.length;
		while(j < n) {
			var item1 = this.delayedRelease[j];
			if(nextTime > item1.time) {
				this.itemRelease.emit(item1.id,item1.time);
				this.delayedRelease.splice(j,1);
				n--;
			} else j++;
		}
		var j1 = 0;
		var n1 = this.timedEvents.length;
		while(j1 < n1) {
			var item2 = this.timedEvents[j1];
			if(nextTime > item2.time) {
				this.timedEvent.emit(item2.id,item2.time);
				this.timedEvents.splice(j1,1);
				n1--;
			} else j1++;
		}
		j1 = 0;
		n1 = this.delayedEnd.length;
		while(j1 < n1) {
			var item3 = this.delayedEnd[j1];
			if(t >= item3.time) {
				this.doStop(item3.id);
				this.delayedEnd.splice(j1,1);
				n1--;
			} else j1++;
		}
	}
};
var tones_Samples = function(audioContext,destinationNode) {
	this.buffer = null;
	tones_AudioBase.call(this,audioContext,destinationNode);
	this.playbackRate = 1.0;
};
tones_Samples.__name__ = true;
tones_Samples.__super__ = tones_AudioBase;
tones_Samples.prototype = $extend(tones_AudioBase.prototype,{
	playSample: function(buffer,delayBy,autoRelease) {
		if(autoRelease == null) autoRelease = true;
		if(delayBy == null) delayBy = .0;
		if(buffer != null) this.buffer = buffer;
		if(delayBy < 0) delayBy = 0;
		var tmp;
		this.lastId = this.ID;
		this.ID++;
		tmp = this.lastId;
		var id = tmp;
		var envelope = this.context.createGain();
		var triggerTime = this.context.currentTime + delayBy;
		var releaseTime = triggerTime + this._attack;
		envelope.gain.value = 0;
		envelope.connect(this.destination);
		envelope.gain.setTargetAtTime(this._volume,triggerTime,Math.log(this._attack + 1.0) / 4.605170185988092);
		var src = this.context.createBufferSource();
		src.buffer = this.buffer;
		src.playbackRate.value = this.playbackRate;
		src.connect(envelope);
		src.start(triggerTime);
		this.activeItems.h[id] = { id : id, src : src, volume : this._volume, env : envelope, attack : this._attack, release : this._release, triggerTime : triggerTime};
		if(delayBy == 0) this.triggerItemBegin(id,triggerTime); else this.delayedBegin.push({ id : id, time : triggerTime});
		if(autoRelease) this.doRelease(id,releaseTime);
		return id;
	}
});
var tones_data_OscillatorTypeShim = function() { };
tones_data_OscillatorTypeShim.__name__ = true;
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
	var config = { google : { families : ["Raleway:400"]}, active : util_WebFontEmbed.loaded};
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
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.__name__ = true;
Array.__name__ = true;
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
haxe_ds_ObjectMap.count = 0;
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
