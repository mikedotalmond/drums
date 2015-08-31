package drums;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */

typedef TrackEvent = {
	var id:Int;
	var active:Bool;
	var volume:Float;
	var pan:Float;
	var rate:Float;
	var attack:Float;
	
	var offset:Float;
	var duration:Float;
}