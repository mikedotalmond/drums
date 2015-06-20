package drums;
import drums.CellEditUI.Button;
import drums.DrumSequencer;
import drums.DrumSequencer.TrackEvent;
import hxsignal.Signal;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.text.Text;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class CellEditUI extends Container {

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
	var tickPulse:Float = 1.0;
	var event:TrackEvent;

	var uiContainer:Container;
	var cellInfo:drums.CellEditUI.CellInfo;
	var playButton:drums.CellEditUI.Button;


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
			tickPulse = 1.00725;
		}
	}


	public function update() {
		if (!visible) return;

		if (launching || closing) {

			bgSize += (launching ? .06 : - .06);

			if (bgSize >= 1) onLaunched();
			else if (bgSize <= 0) onClosed();

			drawBg(bgSize);

		} else {

			if (fadeUI && uiContainer.alpha < 1) {
				uiContainer.alpha += .07;
				if (uiContainer.alpha >= 1) {
					uiContainer.alpha = 1;
					fadeUI = false;
				}
			}

			// pulse with ticks for this cell
			if (tickPulse > 1) {

				tickPulse *= .99925;
				if (tickPulse < 1) tickPulse = 1;

				bg.pivot.set(bg.width / 2, bg.height / 2);
				bg.position.set(bg.width / 2, bg.height / 2);
				bg.scale.set(tickPulse, tickPulse);
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

		bg.beginFill(0x006088);
		bg.drawRect(x,y,w,h);
		bg.endFill();

		cellInfo = new CellInfo();
		playButton = new Button('Play');
		playButton.position.set(225, 0);
		pointer.watch(playButton);

		uiContainer.addChild(bg);
		uiContainer.addChild(cellInfo);
		uiContainer.addChild(playButton);

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
			bg.beginFill(0x2DBEff);
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

		bg.beginFill(0x2DBEff, size);

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
		tickPulse = 1.00725;
	}
}



class UIElement extends Container {

	var bg:Graphics;

	public function new(width:Int, height:Int, ?bgColour:Null<Int>) {
		super();
		if (bgColour != null) {
			bg = new Graphics();
			bg.beginFill(bgColour);
			bg.drawRect(0,0,width,height);
			bg.endFill();
			addChild(bg);
		}
	}
}

class Button extends UIElement {

	var label:Text;

	public function new(text:String) {
		super(90, 84, 0x2DBEFF);
		buttonMode = true;
		interactive = true;
		// Ubuntu - 300,400,700
		label = new Text(text, { font : '400 20px Ubuntu', fill : 'white', align : 'center' } );
		addChild(label);
		label.position.set(Math.fround(90/2 - label.width/2), Math.fround(84/2 - label.height/2));
	}
}

class CellInfo extends UIElement {

	var trackName:Text;
	var cellIndex:Text;
	var duration:Text;

	public function new() {

		super(210, 84, 0x2DBEFF);
		interactive = false;

		// Ubuntu - 300,400,700
		cellIndex = new Text('01', { font : '700 24px Ubuntu', fill : '#00ffbe', align : 'center' } );
		cellIndex.position.set(15,12);
		addChild(cellIndex);

		trackName = new Text('Cowbell', { font : '400 24px Ubuntu', fill : 'white', align : 'center' } );
		trackName.position.set(15,42);
		addChild(trackName);

		duration = new Text('00.000 s', { font : '400 16px Ubuntu', fill : 'white', align : 'center' } );
		duration.position.set(195 - duration.width, 48);
		addChild(duration);
	}

	public function update(sequencer:DrumSequencer, i:Int, j:Int) {
		var ii = i + 1, jj = j + 1;
		var track = sequencer.tracks[i];
		trackName.text = track.name;
		cellIndex.text = j < 10 ? '0$j': '$j';
		duration.text = '${floatToStringPrecision(track.source.duration,4)}';
	}


	public static function floatToStringPrecision(n:Float, prec:Int){
		n = Math.round(n * Math.pow(10, prec));
		var str = '$n';
		var len = str.length;
		if(len <= prec){
			while(len < prec){
			  str = '0$str';
			  len++;
			}
			return '0.$str';
		} else {
			return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
		}
	}
}