package drums.ui;
import drums.DrumSequencer;
import drums.DrumSequencer.TrackEvent;
import drums.ui.celledit.CellInfoPanel;
import drums.ui.celledit.WaveformPanel;
import drums.ui.UIElement;
import hxsignal.Signal;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.JQuery;
import parameter.Mapping.InterpolationExponential;
import parameter.Mapping.InterpolationLinear;
import parameter.Parameter;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.text.Text;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class CellEditPanel extends Container {

	var drums:DrumSequencer;
	var displayWidth:Int;
	var displayHeight:Int;

	var bg:Graphics;
	var bgSize:Float = 0;
	var fadeUI:Bool = false;
	var launching:Bool = false;
	var closing:Bool = false;

	var trackIndex:Int;
	var tickIndex:Int;
	var event:TrackEvent;

	var uiContainer:Container;
	var cellInfo:CellInfoPanel;
	var waveform:WaveformPanel;
	var controls:drums.ui.CellEditPanel.CellEditControls;


	public var closed(default, null):Signal<Void->Void>;

	public function new(drums:DrumSequencer, pointer:Pointer,displayWidth:Int, displayHeight:Int) {
		super();
		visible = false;

		closed = new Signal<Void->Void>();

		this.drums = drums;
		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		bg = new Graphics();
		bg.interactive = true;
		addChild(bg);

		setupUI(pointer);

		controls = new CellEditControls(drums);
		controls.close.connect(close);
		controls.play.connect(playNow);
		controls.editNextPrev.connect(function(i) {
			edit(controls.trackIndex, i);
		});
	}

	
	public function edit(trackIndex:Int, tickIndex:Int) {
		
		var sameTrack = this.trackIndex == trackIndex;
		
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
		
		if (!sameTrack) {
			visible = launching = true;
			fadeUI = closing = false;
			bgSize = 0;
			uiContainer.alpha = 0;
		}
		
		event = drums.tracks[trackIndex].events[tickIndex];

		waveform.setup(drums, trackIndex, tickIndex);

		cellInfo.update(drums, trackIndex, tickIndex);
		
		controls.update(trackIndex, tickIndex);
	}


	public function close() {

		bg.pivot.set(0,0);
		bg.position.set(0,0);
		bg.scale.set(1,1);

		closing = true;
		launching = false;
		uiContainer.alpha = 0;
		trackIndex = -1;
		tickIndex = -1;
		closed.emit();
	}


	public function tick(index:Int) {
		if (index == tickIndex && event.active) {
			waveform.play(event.duration);
		}
	}


	public function update() {
		if (!visible) return;

		if (launching || closing) {

			bgSize += (launching ? .07 : - .07);

			if (bgSize >= 1) onLaunched();
			else if (bgSize <= 0) onClosed();

			drawBg(bgSize);

		} else {

			if (fadeUI && uiContainer.alpha < 1) {
				uiContainer.alpha += .09;
				controls.container.style.opacity = '${uiContainer.alpha}';
				if (uiContainer.alpha >= 1) {
					uiContainer.alpha = 1;
					fadeUI = false;
				}
			}
		}
	}


	function setupUI(pointer:Pointer) {

		uiContainer = new Container();

		var bg = new Graphics();

		var inset = 10;
		var x = -SequenceGrid.xStep / 2 + inset;
		var y = -SequenceGrid.yStep / 2 + inset;
		var w = Main.displayWidth - (inset + inset);
		var h = Main.displayHeight - (inset + inset);

		bg.beginFill(0x0C80DE);
		bg.drawRect(x,y,w,h);
		bg.endFill();

		waveform = new WaveformPanel();
		cellInfo = new CellInfoPanel();
		
		uiContainer.addChild(bg);
		uiContainer.addChild(waveform);
		uiContainer.addChild(cellInfo);

		uiContainer.alpha = 0;
		addChild(uiContainer);
	}


	function onLaunched() {
		launching = false;
		bgSize = 1;
		fadeUI = true;
	}

	function onClosed() {
		trackIndex = -1;
		tickIndex = -1;
		closing = visible = false;
		bgSize = 0;
	}


	function drawBg(size:Float) {

		bg.position.set(0, 0);
		bg.clear();

		if (size == 1) {
			// pixi mouse events don't work on graphics drawn at negative values..?
			// so for final draw, start at 0,0 and fill the whole display
			bg.beginFill(0x2196f3);
			bg.drawRect(-SequenceGrid.xStep/2, -SequenceGrid.yStep/2, Main.displayWidth, Main.displayHeight);
			bg.endFill();
			return;
		}


		var size = size * size;

		var startX = (tickIndex * SequenceGrid.xStep);
		var startY = (trackIndex * SequenceGrid.yStep);

		var right, left, up, down;

		right = ((displayWidth - startX) - SequenceGrid.xStep + SequenceGrid.xStep / 2) * size;
		down = ((displayHeight - startY) - SequenceGrid.yStep + SequenceGrid.yStep / 2) * size;
		left = ((-startX * size) - SequenceGrid.xStep + SequenceGrid.xStep / 2) * size;
		up = ((-startY * size) - SequenceGrid.yStep + SequenceGrid.yStep / 2) * size;

		bg.beginFill(0x2196f3, size);

		// down / right
		bg.drawRect(startX, startY, right, down);
		// left / up
		bg.drawRect(startX, startY, left, up);
		// right / up
		bg.drawRect(startX, startY, right, up);
		// down / left
		bg.drawRect(startX, startY, left, down);

		bg.endFill();
	}


	inline function playNow():Void {
		drums.playTrackCellNow(trackIndex, tickIndex);
	}
}



class CellEditControls {
	
	public var cellOffset(default, null):Parameter<Float, InterpolationLinear>;
	public var cellDuration(default, null):Parameter<Float, InterpolationLinear>;
	public var cellRate(default, null):Parameter<Float, InterpolationLinear>;
	public var cellVolume(default, null):Parameter<Float, InterpolationExponential>;
	public var cellPan(default, null):Parameter<Float, InterpolationLinear>;
	public var cellAttack(default, null):Parameter<Float, InterpolationExponential>;
	//public var cellRelease(default, null):Parameter<Float, InterpolationExponential>;
	
	public var editNextPrev(default, null):Signal<Int->Void>;
	public var close(default, null):Signal<Void->Void>;
	public var play(default, null):Signal<Void->Void>;
	
	public var container(default, null):Element;
	
	public var tickIndex(default, null):Int;
	public var trackIndex(default, null):Int;

	var drums:DrumSequencer;
	
	public function new(drums:DrumSequencer) {
		
		trackIndex = -1;
		tickIndex = -1;
		this.drums = drums;
		
		container = Browser.document.getElementById('cell-edit-controls');
		
		close = new Signal<Void->Void>();
		play = new Signal<Void->Void>();
		editNextPrev = new Signal<Int->Void>();
		
		new JQuery('#cell-edit-play-button').on('click tap', function(_) {
			play.emit();
		});
		new JQuery('#cell-edit-close-button').on('click tap', function(_) {
			close.emit();
			tickIndex = -1;
			trackIndex = - 1;
			container.style.display = 'none';
		});
		
		new JQuery('#cell-edit-next-button').on('click tap', function(_) {
			tickIndex++;
			if (tickIndex >= drums.tracks[trackIndex].events.length) tickIndex = 0;
			editNextPrev.emit(tickIndex);
		});
		new JQuery('#cell-edit-prev-button').on('click tap', function(_) {
			tickIndex--;
			if (tickIndex < 0) tickIndex += drums.tracks[trackIndex].events.length;
			editNextPrev.emit(tickIndex);
		});
		
		setupSliders();
	}
	
	
	public function update(trackIndex:Int, tickIndex:Int) {
		
		var sameTrack = this.trackIndex == trackIndex;
		
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
		
		if (!sameTrack) {
			container.style.opacity = '0';
			container.style.display = 'block';
		}
		
		var track = drums.tracks[trackIndex];
		var event = track.events[tickIndex];
		var duration = track.source.buffer.duration;
		
		cellDuration.setValue(event.duration / duration, false, true); 
		cellOffset.setValue(event.offset / event.duration, false, true);		
		
		//trace(cellDuration.getValue());
		//trace(cellOffset.getValue());
		
		//for(var i in .)
		cellRate.setValue(event.rate, false, true); //
		
		cellVolume.setValue(event.volume, false, true);	//
		
		cellPan.setValue(event.pan, false, true);
		cellAttack.setValue(event.attack, false, true);		
		//cellRelease.setValue(event.release, false, true);
	}
	
	
	function setupSliders() { 
		
		var id = 'cell-offset-slider';
		var slider:InputElement = cast Browser.document.getElementById(id);
		cellOffset = new Parameter<Float, InterpolationLinear>('cellOffsetSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellOffset, slider, false);
		
		id = 'cell-duration-slider';
		slider = cast Browser.document.getElementById(id);
		cellDuration = new Parameter<Float, InterpolationLinear>('cellDurationSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellDuration, slider, false);
		
		id = 'cell-rate-slider';
		slider = cast Browser.document.getElementById(id);
		cellRate  = new Parameter<Float, InterpolationLinear>('cellRateSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellRate, slider, false);
		
		
		id = 'cell-volume-slider';
		slider = cast Browser.document.getElementById(id);
		cellVolume = new Parameter<Float, InterpolationExponential>('cellVolumeSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellVolume, slider, false);		
		
		id = 'cell-pan-slider';
		slider = cast Browser.document.getElementById(id);
		cellPan = new Parameter<Float, InterpolationLinear>('cellPanSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellPan, slider, false);
		
		id = 'cell-attack-slider';
		slider = cast Browser.document.getElementById(id);
		cellAttack = new Parameter<Float, InterpolationExponential>('cellAttackSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		setupParameterSlider(untyped cellAttack, slider, false);
		//
		//id = 'cell-release-slider';
		//slider = cast Browser.document.getElementById(id);
		//cellRelease = new Parameter<Float, InterpolationExponential>('cellReleaseSlider', Std.parseInt(slider.min), Std.parseFloat(slider.max));
		//setupParameterSlider(untyped cellRelease, slider, false);
		
		
		cellOffset.addObserver(cellOffsetHandler);	
		cellDuration.addObserver(cellDurationHandler);
		cellRate.addObserver(cellRateHandler);
		cellVolume.addObserver(cellVolumeHandler);
		cellPan.addObserver(cellPanHandler);
		cellAttack.addObserver(cellAttackHandler);
		//cellRelease.addObserver(cellReleaseHandler);
	}
	
	
	function setupParameterSlider(parameter, slider:InputElement, normalised:Bool) {
		parameter.addObserver(function(p) {
			var val = p.getValue(normalised);
			untyped slider.MaterialSlider.change(val);
			new JQuery(slider).parent().siblings('div[for="${slider.id}"]').text('${val}');
		});
		new JQuery(slider).on('input change', function(_) { parameter.setValue(slider.valueAsNumber, normalised); });
	}
	
	
	function cellOffsetHandler(p:Parameter<Float, InterpolationLinear>) {
		var track = drums.tracks[trackIndex];
		track.events[tickIndex].offset = p.getValue() * track.source.buffer.duration * cellDuration.getValue();
	}
	
	function cellDurationHandler(p:Parameter<Float, InterpolationLinear>) {
		var track = drums.tracks[trackIndex];
		track.events[tickIndex].duration = p.getValue() * track.source.buffer.duration;
	}
	
	function cellRateHandler(p:Parameter<Float, InterpolationLinear>) {
		drums.tracks[trackIndex].events[tickIndex].rate = p.getValue();
	}
	
	function cellVolumeHandler(p:Parameter<Float, InterpolationExponential>) {
		drums.tracks[trackIndex].events[tickIndex].volume = p.getValue();
	}
	
	function cellPanHandler(p:Parameter<Float, InterpolationLinear>) { 
		drums.tracks[trackIndex].events[tickIndex].pan = p.getValue();
	}
	
	function cellAttackHandler(p:Parameter<Float, InterpolationExponential>) { 
		drums.tracks[trackIndex].events[tickIndex].attack = p.getValue();
	}
	
	//function cellReleaseHandler(p:Parameter<Float, InterpolationExponential>) { 
		//drums.tracks[trackIndex].events[tickIndex].release = p.getValue();
	//}
}