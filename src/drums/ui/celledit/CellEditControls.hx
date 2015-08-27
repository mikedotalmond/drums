package drums.ui.celledit;
import hxsignal.Signal;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.JQuery;
import parameter.Mapping.InterpolationExponential;
import parameter.Mapping.InterpolationLinear;
import parameter.Parameter;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */

class CellEditControls {
	
	public var cellOffset(default, null):Parameter<Float, InterpolationLinear>;
	public var cellDuration(default, null):Parameter<Float, InterpolationLinear>;
	public var cellRate(default, null):Parameter<Float, InterpolationLinear>;
	public var cellVolume(default, null):Parameter<Float, InterpolationExponential>;
	public var cellPan(default, null):Parameter<Float, InterpolationLinear>;
	public var cellAttack(default, null):Parameter<Float, InterpolationExponential>;
	
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
		cellOffset.setValue(event.offset / duration, false, true);
		
		cellRate.setValue(event.rate, false, true); //
		cellVolume.setValue(event.volume, false, true);	//
		cellPan.setValue(event.pan, false, true);
		cellAttack.setValue(event.attack, false, true);		
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
		
		cellOffset.addObserver(cellOffsetHandler);	
		cellDuration.addObserver(cellDurationHandler);
		cellRate.addObserver(cellRateHandler);
		cellVolume.addObserver(cellVolumeHandler);
		cellPan.addObserver(cellPanHandler);
		cellAttack.addObserver(cellAttackHandler);
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
		track.events[tickIndex].offset = p.getValue() * track.source.buffer.duration;
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
}