/*
 * =BEGIN MIT LICENSE
 * 
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 The CrossBridge Team
 * https://github.com/crossbridge-community
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * =END MIT LICENSE
 *
 */
package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.events.AsyncErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.display.LoaderInfo;
    import flash.display.Graphics;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.system.Worker;
    
    import com.adobe.flascc.vfs.HTTPBackingStore;
	import com.adobe.flascc.CModule;
	import com.adobe.flascc.Console;

	public class VFSPreLoader extends MovieClip
	{
		private var webfs:Object = null
		private var webfsPct:Number = 0, swfPct:Number = 0
		private var webfsFinished:Boolean = false
		private var failed:Boolean = false

		public function VFSPreLoader() 
		{
			if(!Worker.current.isPrimordial) {
				gotoAndStop(2)
				new Console(this)
				return
			}

			webfs = new URLLoader(new URLRequest("bochsvfs.zip"));
			webfs.dataFormat = URLLoaderDataFormat.BINARY;
			webfs.addEventListener(AsyncErrorEvent.ASYNC_ERROR, webfsError)
			webfs.addEventListener(SecurityErrorEvent.SECURITY_ERROR, webfsError)
			webfs.addEventListener(IOErrorEvent.IO_ERROR, webfsError)
			webfs.addEventListener(Event.COMPLETE, webfsComplete)
			webfs.addEventListener(ProgressEvent.PROGRESS, webfsProgress)

			if(stage) {
				stage.frameRate = 60
				loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress)
				loaderInfo.addEventListener(Event.COMPLETE, onPreloaderComplete)
			} else {
				addEventListener(Event.ADDED_TO_STAGE, onPreloaderComplete)
			}
		}

		private function webfsProgress(e:ProgressEvent):void {
			webfsPct = (e.bytesLoaded / e.bytesTotal)
			render()
		}

		private function webfsComplete(e:Event):void {
			webfsFinished = true
			webfs = webfs.data
			onPreloaderComplete(null)
		}

		private function webfsError(e:Event):void {
			trace(e)
			failed = true
			webfsFinished = true
		}

		private function render():void {
			graphics.clear()
			graphics.beginFill(0)
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight)
			graphics.endFill()

			var barColor:uint = failed ? 0xFF0000 : 0xFFFFFF;

			// Swf progress bar
			var barHeight:int = 40
			var barWidth:int = stage.stageWidth * 0.75

			graphics.lineStyle(1, barColor)
      		graphics.drawRect((stage.stageWidth - barWidth) / 2, (stage.stageHeight/2) - (barHeight/2), barWidth, barHeight)

      		graphics.beginFill(barColor)
      		graphics.drawRect((stage.stageWidth - barWidth) / 2 + 5, (stage.stageHeight/2) - (barHeight/2) + 5, (barWidth - 10) * swfPct, barHeight - 10)
			graphics.endFill()

			// WebsFS progress bar
			if(webfs) {
				barColor = failed ? 0xFF0000 : 0xAAAAAA;
				graphics.lineStyle(1, barColor)
				graphics.drawRect((stage.stageWidth - barWidth) / 2, (stage.stageHeight/2) - (barHeight/2) + 5 + barHeight, barWidth, barHeight)

				graphics.beginFill(barColor)
				graphics.drawRect((stage.stageWidth - barWidth) / 2 + 5, (stage.stageHeight/2) - (barHeight/2) + 10 + barHeight, (barWidth - 10) * webfsPct, barHeight - 10)
				graphics.endFill()
			}
		}

		private function onProgress(e:ProgressEvent):void 
		{
			swfPct = e.bytesLoaded / e.bytesTotal
			render()
		}
		
		private function onPreloaderComplete(e:Event):void 
		{
			if(webfs && webfsFinished == false)
				return; // wait until the webfs is complete

			gotoAndStop(2)
			graphics.clear()

			new Console(this,webfs as ByteArray)
			webfs = null
		}		
	}
}
