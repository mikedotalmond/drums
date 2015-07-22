package drums.ui;
import drums.DrumSequencer;
import drums.DrumSequencer.TrackEvent;
import drums.ui.Button;
import drums.ui.celledit.CellInfoPanel;
import drums.ui.celledit.OscilliscopePanel;
import drums.ui.celledit.WaveformPanel;
import drums.ui.UIElement;
import hxsignal.Signal;
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
	var playButton:LabelButton;
	var waveform:WaveformPanel;
	var oscilliscope:OscilliscopePanel;


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

		pointer.watch(bg);
		pointer.click.connect(onClick);
	}


	function onClick(target:DisplayObject) {
		if (target.parent == this) {
			close();
		} else if (target.parent==uiContainer) {
			switch (target){
				case playButton: playNow();
			}
		}
	}


	public function edit(trackIndex:Int, tickIndex:Int) {
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;

		visible = launching = true;
		fadeUI = closing = false;

		bgSize = 0;
		uiContainer.alpha = 0;

		event = drums.tracks[trackIndex].events[tickIndex];

		waveform.setup(drums, trackIndex, tickIndex);

		cellInfo.update(drums, trackIndex, tickIndex);
	}


	public function close() {

		bg.pivot.set(0,0);
		bg.position.set(0,0);
		bg.scale.set(1,1);

		closing = true;
		launching = false;
		uiContainer.alpha = 0;
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

		cellInfo = new CellInfoPanel();
		playButton = new LabelButton(90, 84, 'Play');
		playButton.position.set(225, 0);
		pointer.watch(playButton);


		oscilliscope = new OscilliscopePanel(drums, trackIndex, tickIndex);
		oscilliscope.y = 98;

		waveform = new WaveformPanel();
		waveform.x = 330;

		uiContainer.addChild(bg);
		uiContainer.addChild(cellInfo);
		uiContainer.addChild(playButton);

		uiContainer.addChild(oscilliscope);
		uiContainer.addChild(waveform);

		uiContainer.alpha = 0;
		addChild(uiContainer);
	}


	function onLaunched() {
		launching = false;
		bgSize = 1;
		fadeUI = true;
	}

	function onClosed() {
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