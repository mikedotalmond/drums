package util;

/**
 * ...
 * @author ...
 */

import js.Browser;
import js.html.ScriptElement;


class WebFontEmbed {

	static public var loaded:Void->Void;

	/**
	 * Load webfont(s) from google using https://github.com/typekit/webfontloader
	 */
	static public function load():Void {

		var config = {
			google: { families: ['Roboto:300,400,500,700'] },
			active: loaded
		};

		Reflect.setField(Browser.window, 'WebFontConfig', config);

		var wf = Browser.document.createScriptElement();
		wf.src = 'https://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
		wf.type = 'text/javascript';
		wf.async = true;
		var s = Browser.document.getElementsByTagName('script')[0];
		s.parentNode.insertBefore(wf, s);
	}
}
