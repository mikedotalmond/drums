package tones.utils;

/**
 * A Haxe port of the Recorderjs interface - https://github.com/mattdiamond/Recorderjs
 * Uses/requires the recorderWorker.js script from Recorderjs
 * 
 * Utility to record the output of an AudioNode and save as WAV
 * (encode process runs asynchronously in a worker)
 */

import js.Browser;
import hxsignal.Signal;
import js.html.URL;

import js.html.AnchorElement;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.ScriptProcessorNode;

import js.html.Blob;
import js.html.Document;
import js.html.DOMURL;
import js.html.Float32Array;
import js.html.MessageEvent;
import js.html.Worker;

 
class AudioNodeRecorder {
	
	public var recording		(default, null):Bool;
	public var wavEncoded		(default, null):Signal<Blob->Void>;
	public var bufferExported	(default, null):Signal<Array<Float32Array>->Void>;

	var worker	:Worker;
	var node	:ScriptProcessorNode;
	
	public function new(source:AudioNode, bufferSize:Int=4096, workerPath:String='js/recorderWorker.js') {
		
		var context 	= source.context;
		node 			= context.createScriptProcessor(bufferSize, 2, 2);
		worker 			= new Worker(workerPath);
		recording		= false;
		
		wavEncoded 		= new Signal<Blob->Void>();
		bufferExported 	= new Signal<Array<Float32Array>->Void>();
		
		worker.postMessage({
		  command: 'init',
		  config: { sampleRate: context.sampleRate }
		});
		
		worker.onmessage = onWorkerMessage;
		node.onaudioprocess = onAudioProcess;
		
		source.connect(node);
		node.connect(context.destination); // this should not be necessary	
	}
	
	
    function onWorkerMessage(e:MessageEvent) {
		if (Std.is(e.data, Blob)) {
			wavEncoded.emit(cast e.data);
		} else if (Std.is(e.data, Array)) {
			bufferExported.emit(cast e.data);
		} else {
			throw "Unexpected message data";
		}
    }
	
	function onAudioProcess(e) {
		if (!recording) return;
		
		RecordBufferMessage.buffer[0] = e.inputBuffer.getChannelData(0);
		RecordBufferMessage.buffer[1] = e.inputBuffer.getChannelData(1);
		
		worker.postMessage(RecordBufferMessage);
	}
	
	
    inline public function start() recording = true;
    inline public function stop() recording = false;

	inline public function clear() worker.postMessage( ClearBufferMessage );
	inline public function getBuffer() worker.postMessage( GetBufferMessage );
	inline public function encodeWAV() worker.postMessage( EncodeWAVMessage );
	
	
	public static function forceDownload(blob:Blob, filename:String = 'output.wav') {
		
		var doc	:Document = js.Browser.window.document;
		var link:AnchorElement = cast doc.createElement('a');
		
		link.href = URL.createObjectURL(blob);
		link.download = filename;
		
		var click = doc.createEvent("Event");
		click.initEvent("click", true, true);
		link.dispatchEvent(click);
	}
	
	static var RecordBufferMessage	:BufferMessage = { command: 'record', buffer:[] };
	static var GetBufferMessage		:BufferMessage = { command: 'getBuffer' };
	static var EncodeWAVMessage		:BufferMessage = { command: 'exportWAV', type: 'audio/wav' };
	static var ClearBufferMessage	:BufferMessage = { command: 'clear' };
}


typedef BufferMessage = {
	var command:String;
	@:optional var type:String;
	@:optional var buffer:Array<Float32Array>;
}