/**
 * @mxmlc -target-player=10.0.0
 */
package gsexamples
{
    import flash.display.*;
    import flash.events.*;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	import com.greensock.TweenLite;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '500', height = '300')]

	/**
	 * An example of the usage of the TransformAroundCenter plugin to transform an item.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
    public class TransformAroundCenterExample extends Sprite
	{
		private const INTERVAL:uint = 1000;

		// http://www.flickr.com/photos/paazio/2449304844/sizes/s/
		[Embed(source = "2449304844_a742a2e148_m.jpg")]
		private var DogLapo:Class;

		private var _container:Sprite;
		private var _timer:Timer;

        public function TransformAroundCenterExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			TweenPlugin.activate([TransformAroundCenterPlugin]);

			_container = new Sprite();
			addChild(_container);

			drawItems();

			_timer = new Timer(INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

		private function drawItems():void
		{
			var lapo:Bitmap = new DogLapo() as Bitmap;
			var m:Number = 6;
			var h:int = Math.floor(stage.stageWidth / (lapo.width + m * 2));
			var v:int = Math.floor(stage.stageHeight / (lapo.height + m * 2));

			var num:uint = _container.numChildren;
			while (num > 0)
			{
				--num;
				_container.removeChildAt(num);
			}

			for (var i:uint = 0; i < h; ++i)
			{
				for (var j:uint = 0; j < v; ++j)
				{
					var bm:Bitmap = new Bitmap(lapo.bitmapData);
					bm.x = (m + lapo.width) * i + m;
					bm.y = (m + lapo.height) * j + m;
					_container.addChild(bm);
				}
			}
		}
		private function onTimer(event:TimerEvent):void
		{
			var index:uint = Math.round(Math.random() * (_container.numChildren - 1));
			var bm:Bitmap = _container.getChildAt(index) as Bitmap;
			var options:Object = {
				scale: Math.random() * 2,
				rotation: Math.random() * 360
			};
			TweenLite.to(bm, 2, { transformAroundCenter: options } );
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				drawItems();
			}
		}
    }
}
