package drums.ui.celledit;
import pixi.core.text.Text;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class CellInfoPanel extends UIElement {


	var trackName:Text;

	public function new() {

		super(170, 43);
		bg.alpha = .66;

		trackName = new Text('', { font : '200 20px Roboto', fill : 'white', align : 'center'});

		trackName.position.set(15, 10);
		addChild(trackName);
	}


	public function update(sequencer:DrumSequencer, i:Int, j:Int) {
		var ii = i + 1, jj = j + 1;
		var track = sequencer.tracks[i];

		trackName.text = track.name + ' (' +  (jj < 10 ? '0$jj/16)': '$jj/16)');
		drawBg(Std.int(trackName.width) + 30, 43);
	}
}