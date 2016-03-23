/**
 * @mxmlc -target-player=10.0.0
 */
package gsexamples
{
    import flash.display.*;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import com.greensock.TweenLite;
	import com.greensock.plugins.EndArrayPlugin;
	import com.greensock.plugins.TweenPlugin;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '500', height = '300')]

	/**
	 * An example of the usage of the EndArray plugin to change values in an array over time.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi
	 */
    public class EndArrayExample extends Sprite
	{
		private const AMOUNT:uint = 20;

		private var _container:Sprite;
		private var _values:Array = [];

        public function EndArrayExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			TweenPlugin.activate([EndArrayPlugin]);

			_container = new Sprite();
			addChild(_container);

			drawItems();

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

		private function drawItems():void
		{
			var num:uint = _container.numChildren;
			while (num > 0)
			{
				--num;
				_container.removeChildAt(num);
			}

			var destination:Array = [];

			for (var i:uint = 0; i < AMOUNT; ++i)
			{
				var sp:Sprite = new Sprite();
				var gra:Graphics = sp.graphics;
				gra.lineStyle(2, 0xF2F2F2);
				gra.beginFill(Math.random() * 0xFFFFFF);
				gra.drawCircle(0, 0, Math.random() * 20 + 10);
				gra.endFill();
				sp.x = stage.stageWidth / AMOUNT * i;
				sp.y = 20;
				_container.addChild(sp);

				_values[i] = sp.y;
				destination[i] = Math.random() * (stage.stageHeight - 40) + 10;
			}

			TweenLite.to(_values, 4, { endArray: destination, onUpdate: onArrayUpdate } );
		}

		private function onArrayUpdate():void
		{
			var len:uint = _values.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var sp:Sprite = _container.getChildAt(i) as Sprite;
				if (sp != null)
				{
					sp.y = _values[i];
				}
			}
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
