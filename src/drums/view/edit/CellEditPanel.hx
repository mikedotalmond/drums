package drums.view.edit;
import drums.DrumSequencer;
import drums.TrackEvent;
import drums.view.edit.CellEditControls;
import drums.view.edit.CellInfoPanel;
import drums.view.edit.WaveformPanel;
import drums.view.sequencer.CellGrid;
import hxsignal.Signal;
import input.KeyCodes;
import js.Browser;
import js.html.KeyboardEvent;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;

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
	var controls:CellEditControls;


	public var closed(default, null):Signal<Void->Void>;

	public function new(drums:DrumSequencer, pointer:Pointer,displayWidth:Int, displayHeight:Int) {
		super();
		visible = false;

		closed = new Signal<Void->Void>();

		this.drums = drums;
		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		bg = new Graphics();
		addChild(bg);

		setupUI(pointer);

		controls = new CellEditControls(drums);
		controls.close.connect(close);
		controls.play.connect(playNow);
		controls.editNextPrev.connect(function(i) {
			edit(controls.trackIndex, i);
		});
		
		var f = function(val) waveform.updateOverlay(controls.cellOffset.getValue(true), controls.cellDuration.getValue(true));
		
		controls.cellOffset.addObserver(f);
		controls.cellDuration.addObserver(f);
	}

	
	public function edit(trackIndex:Int, tickIndex:Int) {
		
		if (tickIndex > 15) tickIndex = 0;
		else if (tickIndex < 0) tickIndex = 15;
		
		if (trackIndex > 7) trackIndex = 0;
		else if (trackIndex < 0) trackIndex = 7;
		
		var sameTrack = this.trackIndex == trackIndex;
		
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
		
		if (!visible) {
			visible = launching = true;
			fadeUI = closing = false;
			bgSize = 0;
			uiContainer.alpha = 0;
		} else if(!sameTrack) {
			visible = true;
			launching = closing = false;
			fadeUI = true;
			bgSize = 1;
			uiContainer.alpha = 0;
		}
		
		event = drums.tracks[trackIndex].events[tickIndex];

		waveform.setup(drums, trackIndex, tickIndex);
		waveform.updateOverlay(controls.cellOffset.getValue(true), controls.cellDuration.getValue(true));
		
		cellInfo.update(drums, trackIndex, tickIndex);
		
		controls.update(trackIndex, tickIndex);
		
		Browser.window.removeEventListener('keydown', onKeyDown);
		Browser.window.addEventListener('keydown', onKeyDown);
	}
	
	
	function onKeyDown(e:KeyboardEvent):Void {
		switch(e.keyCode) {
			case KeyCodes.P:
				playNow();
			case KeyCodes.LEFT:
				edit(trackIndex, tickIndex - 1);
			case KeyCodes.RIGHT:
				edit(trackIndex, tickIndex + 1);
			case KeyCodes.UP:
				edit(trackIndex - 1, tickIndex);
			case KeyCodes.DOWN:
				edit(trackIndex + 1, tickIndex);
		}
	}
	
	public function close() {

		Browser.window.removeEventListener('keydown', onKeyDown);
		
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

	var ticked:Float = 0.0;
	public function tick(index:Int) {
		if (index == tickIndex && event.active) {
			ticked = 1.0;
		}
	}
	

	public function update() {
		if (!visible) return;
		
		if (launching || closing) {

			bgSize += (launching ? .08 : - .07);

			if (bgSize >= 1) onLaunched();
			else if (bgSize <= 0) onClosed();

			drawBg(bgSize);

		} else {
			
			if (ticked > 0) {
				ticked *= .925;
				if (ticked < .05) {
					ticked = 0;
					drawBg(1);
				} else {
					var g = 0x96 + Std.int(ticked * (0xf6 - 0x96));
					drawBg(1, (0x210000 | (g<<8) | 0xf3));
				}
			}
			
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
		var x = -CellGrid.xStep / 2 + inset;
		var y = -CellGrid.yStep / 2 + inset;
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


	function drawBg(size:Float, colour:Int=0x2196f3) {

		bg.position.set(0, 0);
		bg.clear();

		if (size == 1) {
			// pixi mouse events don't work on graphics drawn at negative values..?
			// so for final draw, start at 0,0 and fill the whole display
			bg.beginFill(colour);
			bg.drawRect(-CellGrid.xStep/2, -CellGrid.yStep/2, Main.displayWidth, Main.displayHeight);
			bg.endFill();
			return;
		}


		var size = size * size;

		var startX = (tickIndex * CellGrid.xStep);
		var startY = (trackIndex * CellGrid.yStep);

		var right, left, up, down;

		right = ((displayWidth - startX) - CellGrid.xStep + CellGrid.xStep / 2) * size;
		down = ((displayHeight - startY) - CellGrid.yStep + CellGrid.yStep / 2) * size;
		left = ((-startX * size) - CellGrid.xStep + CellGrid.xStep / 2) * size;
		up = ((-startY * size) - CellGrid.yStep + CellGrid.yStep / 2) * size;

		bg.beginFill(colour, size);

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