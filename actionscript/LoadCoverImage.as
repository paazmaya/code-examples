/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
  import flash.display.*;
  import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.system.Capabilities;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '500', height = '300')]

	/**
	 * An example of how to retrieve meta data and a cover image if available.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://www.paazmaya.fi
	 */
    public class LoadCoverImage extends Sprite
	{
		private const MEDIA:String = "http://www.paazmaya.fidata/Disturbed-Criminal.mp4";

		private var _connection:NetConnection;
		private var _stream:NetStream;
		private var _bytedata:ByteArray;

        public function LoadCoverImage()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			trace("version: " + Capabilities.version);

			_bytedata = new ByteArray();

			_connection = new NetConnection();
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.connect(null);
		}

		private function connectStream():void
		{
			_stream = new NetStream(_connection);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_stream.checkPolicyFile = true;
			_stream.client = { onMetaData: onMetaData, onImageData: onImageData };

			var st:SoundTransform = _stream.soundTransform;
			st.volume = 0.5;
			_stream.soundTransform = st;

			_stream.play(MEDIA);

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

		private function onImageData(info:Object):void
		{
			trace("onImageData: " + info);
			trace("onImageData. info length: " + info.data.length);

			var loader:Loader = new Loader();
			loader.loadBytes(info.data);
			addChild(loader);
		}

		private function onMetaData(info:Object):void
		{
			if (info.tags != null && info.tags.covr != null)
			{
				var covr:Array = info.tags.covr as Array;
				if (covr != null)
				{
					var len:uint = covr.length;
					for (var i:uint = 0; i < len; ++i)
					{
						var loader:Loader = new Loader();
						loader.loadBytes(covr[i]);
						addChild(loader);
					}
				}
			}

			for (var key:Object in info)
			{
				trace("onMetaData. " + key + " (" + typeof info[key] + ") = " + info[key]);
			}
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			var st:SoundTransform = _stream.soundTransform;
			var vol:Number = st.volume;

			if (event.keyCode == Keyboard.UP)
			{
				vol += 0.1;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				vol -= 0.1;
			}

			if (vol > 1.0)
			{
				vol = 1.0;
			}
			else if (vol < 0.0)
			{
				vol = 0.0;
			}

			st.volume = vol;
			_stream.soundTransform = st;
		}


		private function onEnterFrame(event:Event):void
		{
			var st:SoundTransform = _stream.soundTransform;
			var s:ByteArray = _bytedata;
			var n:uint = 512;
			var w:Number = stage.stageWidth / n;
			var h:Number = 0;

			SoundMixer.computeSpectrum(s, true, 0);

			var gr:Graphics = graphics;
			gr.clear();
			gr.beginFill(0x121212, 1.0);
			for (var i:uint = 0; i < n; ++i)
			{
				h = s.readFloat() * stage.stageHeight;
				gr.drawRect(w * i, stage.stageHeight - h, w, h);
			}
			gr.endFill();

		}

		private function onAsyncError(event:AsyncErrorEvent):void
		{
			trace("onAsyncErrorEvent: " + event.toString());
		}

		private function onIOError(event:IOErrorEvent):void
		{
			trace("onIOErrorEvent: " + event.toString());
		}

		private function onNetStatus(event:NetStatusEvent):void
		{
			//trace("onNetStatusEvent: " + event.toString());
			trace("onNetStatusEvent. event.info.code: " + event.info.code);
			if (event.info.code == "NetConnection.Connect.Success")
			{
				connectStream();
			}
		}

		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("onSecurityErrorEvent: " + event.toString());
		}
    }
}
