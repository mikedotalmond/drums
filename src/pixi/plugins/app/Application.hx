package pixi.plugins.app;

import js.html.Element;
import pixi.core.renderers.webgl.WebGLRenderer;
import pixi.core.renderers.canvas.CanvasRenderer;
import pixi.core.renderers.SystemRenderer;
import pixi.plugins.stats.Stats;
import pixi.core.renderers.Detector;
import pixi.core.display.Container;
import js.html.Event;
import js.html.CanvasElement;
import js.Browser;

import tones.utils.TimeUtil;

/**
 * Pixi Boilerplate Helper class that can be used by any application
 * @author Adi Reddy Mora
 * http://adireddy.github.io
 * @license MIT
 * @copyright 2015
 *
 * Changes from the above:
 * Use performance api in place of Date.now()
 * User TimeUtil to share a single requestanimationFrame
 * De-underscored the privates.
 */
class Application {

	/**
     * Sets the pixel ratio of the application.
     * default - 1
     */
	public var pixelRatio(null, default):Float;

	/**
	 * Default frame rate is 60 FPS and this can be set to true to get 30 FPS.
	 * default - false
	 */
	public var skipFrame(null, set):Bool;

	/**
	 * Default frame rate is 60 FPS and this can be set to anything between 1 - 60.
	 * default - 60
	 */
	public var fps(default, set):Int;

	/**
	 * Width of the application.
	 * default - Browser.window.innerWidth
	 */
	public var width(null, default):Float;

	/**
	 * Height of the application.
	 * default - Browser.window.innerHeight
	 */
	public var height(null, default):Float;

	/**
	 * Renderer transparency property.
	 * default - false
	 */
	public var transparent(null, default):Bool;

	/**
	 * Graphics antialias property.
	 * default - false
	 */
	public var antialias(null, default):Bool;

	/**
	 * Force FXAA shader antialias instead of native (faster)
	 * default - false
	 */
	public var forceFXAA(null, default):Bool;

	/**
	 * Whether you want to resize the canvas and renderer on browser resize.
	 * Should be set to false when custom width and height are used for the application.
	 * default - true
	 */
	public var autoResize(null, default):Bool;

	/**
	 * Sets the background color of the stage.
	 * default - 0xFFFFFF
	 */
	public var backgroundColor(null, default):Int;

	/**
	 * Update listener 	function
	 */
	public var onUpdate:Float -> Void;

	/**
	 * Window resize listener 	function
	 */
	public var onResize:Void -> Void;

	/**
	 * Global Container.
	 * Read-only
	 */
	var stage(default, null):Container;

	public static inline var AUTO:String = "auto";
	public static inline var RECOMMENDED:String = "recommended";
	public static inline var CANVAS:String = "canvas";
	public static inline var WEBGL:String = "webgl";

	var canvas:CanvasElement;
	var renderer:SystemRenderer;
	var stats:Stats;
	var lastTime:Float;
	var currentTime:Float;
	var elapsedTime:Float;

	var frameCount:Int;

	public function new() {
		lastTime = Browser.window.performance.now();
		_setDefaultValues();
	}

	function set_fps(val:Int):Int {
		frameCount = 0;
		return fps = (val >= 1 && val < 60) ? Std.int(val) : 60;
	}

	function set_skipFrame(val:Bool):Bool {
		if (val) {
			trace("pixi.plugins.app.Application > Deprecated: skipFrame - use fps property and set it to 30 instead");
			fps = 30;
		}
		return skipFrame = val;
	}

	function _setDefaultValues() {
		pixelRatio = 1;
		skipFrame = false;
		autoResize = true;
		transparent = false;
		antialias = false;
		forceFXAA = false;
		backgroundColor = 0xFFFFFF;
		width = Browser.window.innerWidth;
		height = Browser.window.innerHeight;
		fps = 60;
	}

	/**
	 * Starts pixi application setup using the properties set or default values
	 * @param [renderer] - Renderer type to use AUTO (default) | CANVAS | WEBGL
	 * @param [stats] - Enable/disable stats for the application.
	 * Note that stats.js is not part of pixi so don't forget to include it you html page
	 * Can be found in libs folder. "libs/stats.min.js" <script type="text/javascript" src="libs/stats.min.js"></script>
	 * @param [parentDom] - By default canvas will be appended to body or it can be appended to custom element if passed
	 */
	public function start(?renderer:String = AUTO, ?stats:Bool = true, ?parentDom:Element = null) {
		
		canvas = Browser.document.createCanvasElement();
		canvas.style.width = width + "px";
		canvas.style.height = height + "px";
		canvas.style.position = "absolute";
		
		if (parentDom == null) parentDom = Browser.document.body;
		
		stage = new Container();

		var renderingOptions:RenderingOptions = {};
		renderingOptions.view = canvas;
		renderingOptions.backgroundColor = backgroundColor;
		renderingOptions.resolution = pixelRatio;
		renderingOptions.antialias = antialias;
		renderingOptions.forceFXAA = forceFXAA;
		renderingOptions.autoResize = autoResize;
		renderingOptions.transparent = transparent;

		if (renderer == AUTO) this.renderer = Detector.autoDetectRenderer(width, height, renderingOptions);
		else if (renderer == CANVAS) this.renderer = new CanvasRenderer(width, height, renderingOptions);
		else this.renderer = new WebGLRenderer(width, height, renderingOptions);

		parentDom.appendChild(this.renderer.view);
		
		if (autoResize) Browser.window.onresize = _onWindowResize;
		TimeUtil.frameTick.connect(onRequestAnimationFrame);
		lastTime = Browser.window.performance.now();

		if (stats) addStats();
	}

	@:noCompletion function _onWindowResize(event:Event) {
		width = Browser.window.innerWidth;
		height = Browser.window.innerHeight;
		renderer.resize(width, height);
		canvas.style.width = width + "px";
		canvas.style.height = height + "px";

		if (stats != null) {
			stats.domElement.style.top = "2px";
			stats.domElement.style.right = "2px";
		}

		if (onResize != null) onResize();
	}

	@:noCompletion function onRequestAnimationFrame(_) {
		frameCount++;
		if (frameCount == Std.int(60 / fps)) {
			frameCount = 0;
			calculateElapsedTime();
			if (onUpdate != null) onUpdate(elapsedTime);
			renderer.render(stage);
		}
		if (stats != null) stats.update();
	}


	@:noCompletion function calculateElapsedTime() {
		currentTime = Browser.window.performance.now();
		elapsedTime = currentTime - lastTime;
		lastTime = currentTime;
	}


	@:noCompletion function addStats() {
		if (untyped __js__("window").Stats != null) {
			var container = Browser.document.createElement("div");
			Browser.document.body.appendChild(container);
			stats = new Stats();
			stats.domElement.style.position = "absolute";
			stats.domElement.style.top = "2px";
			stats.domElement.style.right = "2px";
			container.appendChild(stats.domElement);
			stats.begin();
		}
	}
}