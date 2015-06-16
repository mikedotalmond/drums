package drums;
import drums.DrumSequencer;
import drums.DrumSequencer.TrackEvent;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;

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
	var launching:Bool = false;
	var closing:Bool = false;

	var trackIndex:Int;
	var tickIndex:Int;
	var tickPulse = .0;
	var event:TrackEvent;

	public function new(drums:DrumSequencer, pointer:Pointer,displayWidth:Int, displayHeight:Int) {
		super();
		visible = false;

		this.drums = drums;
		this.displayWidth = displayWidth;
		this.displayHeight = displayHeight;

		bg = new Graphics();
		bg.interactive = true;
		//bg.buttonMode = true;

		pointer.watch(bg);
		pointer.click.connect(function(target) {
			if (target.parent == this) {
				close();
			}
		});

		addChild(bg);
	}

	public function edit(trackIndex:Int, tickIndex:Int) {
		visible = launching = true;
		closing = false;

		bgSize = 0;
		event = drums.tracks[trackIndex].events[tickIndex];
		this.trackIndex = trackIndex;
		this.tickIndex = tickIndex;
	}


	public function close() {
		closing = true;
		launching = false;
	}

	public function tick(index:Int) {
		if (index == tickIndex && event.active) {
			tickPulse = 1.01;
		}
	}

	public function update() {
		if (!visible) return;

		if (launching || closing) {

			bgSize += (launching ? .06 : - .06);

			if (bgSize >= 1) {
				bgSize = 1;
				launching = false;
			} else if (bgSize <= 0) {
				bgSize = 0;
				closing = false;
				visible = false;
			}

			drawBg(bgSize);

		} else {

			// pulse with ticks for this cell
			if (tickPulse > 1) {
				tickPulse *= .998;
				if (tickPulse < 1) tickPulse = 1;

				var dx = Main.displayWidth - Main.displayWidth * tickPulse;
				var dy = Main.displayHeight - Main.displayHeight * tickPulse;

				bg.position.set(dx, dy);
				bg.clear();
				bg.beginFill(0x2DBEff);
				bg.drawRect( -SequenceGrid.xStep / 2, -SequenceGrid.yStep / 2, Main.displayWidth * tickPulse - dx, Main.displayHeight * tickPulse - dy);
				bg.endFill();
			}
		}
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

}