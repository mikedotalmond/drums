package drums.ui.celledit;
import pixi.core.text.Text;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class CellInfoPanel extends UIElement {


	var trackName:Text;
	var cellIndex:Text;
	var duration:Text;

	public function new() {

		super(315, 84);

		// Ubuntu - 300,400,700
		cellIndex = new Text('01', { font : '500 20px Roboto', fill : 'white', align:'center',
			dropShadow:false, dropShadowAngle:0, dropShadowDistance:1, dropShadowColor:'#FF4081'
		});

		cellIndex.position.set(15, 10);

		trackName = new Text('Cowbell', { font : '200 26px Roboto', fill : 'white', align : 'center',
			dropShadow:true, dropShadowAngle:0, dropShadowDistance:1, dropShadowColor:'#008ECC'
		});

		duration = new Text('00.000', { font : '500 16px Roboto', fill : 'white', align : 'center',
			dropShadow:true, dropShadowAngle:0, dropShadowDistance:1, dropShadowColor:'#008ECC'
		});

		addChild(cellIndex);
		addChild(trackName);
		addChild(duration);
	}


	public function update(sequencer:DrumSequencer, i:Int, j:Int) {
		var ii = i + 1, jj = j + 1;
		var track = sequencer.tracks[i];

		cellIndex.text = jj < 10 ? '0$jj/16': '$jj/16';

		duration.text = '${floatToStringPrecision(track.source.duration,4)}';
		duration.position.set(195 - duration.width, 50);

		trackName.text = track.name;
		trackName.position.set(15, 40);
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
		}

		return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
	}
}