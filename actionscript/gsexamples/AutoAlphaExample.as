/**
 * @mxmlc -target-player=10.0.0
 */
package gsexamples
{
  import flash.display.*;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import com.greensock.TweenLite;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.TweenPlugin;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '600', height = '400')]

	/**
	 * An example of the usage of the AutoAlpha plugin
	 * to adjust the visibility of an item.
	 * Get TweenLite from http://www.greensock.com/tweenlite/
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
    public class AutoAlphaExample extends Sprite
	{
		private const AMOUNT:uint = 600;
		private const MARGIN:uint = 10;

		private var _container:Sprite;
		private var _field:TextField;

        public function AutoAlphaExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			TweenPlugin.activate([AutoAlphaPlugin]);

			_container = new Sprite();
			addChild(_container);

			createField();
			drawItems();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function createField():void
		{
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat(
				"Verdana", 12, 0x042836, true
			);
			_field.background = _field.border = true;
			_field.selectable = false;
			_field.backgroundColor = 0xE3E3C9;
			_field.borderColor = 0x961D18;
			_field.x = _field.y = MARGIN;
			_field.width = stage.stageWidth - MARGIN * 2;
			_field.height = Number(_field.defaultTextFormat.size) * 1.5;
			addChild(_field);
		}

		private function drawItems():void
		{
			var num:uint = _container.numChildren;
			while (num > 0)
			{
				--num;
				_container.removeChildAt(num);
			}

			for (var i:uint = 0; i < AMOUNT; ++i)
			{
				var sh:Shape = new Shape();
				var gra:Graphics = sh.graphics;
				gra.beginFill(Math.random() * 0xFFFFFF);
				gra.drawCircle(0, 0, Math.random() * 20 + 10);
				gra.endFill();
				sh.x = Math.random() * stage.stageWidth;
				sh.y = Math.random() * stage.stageHeight;
				_container.addChild(sh);
			}
		}

		private function onEnterFrame(event:Event):void
		{
			var totalVisible:uint = 0;
			var totalHidden:uint = 0;
			var num:uint = _container.numChildren;
			for (var i:uint = 0; i < num; ++i)
			{
				var item:DisplayObject = _container.getChildAt(i);
				if (Math.random() * 4 > 3)
				{
					var alpha:Number = 0;
					if (!item.visible)
					{
						alpha = 1;
					}
					TweenLite.to(item, Math.random() * 2 + 1, {
						autoAlpha: alpha
					} );
				}
				if (item.visible)
				{
					++totalVisible;
				}
				else
				{
					++totalHidden;
				}
			}
			_field.text = "Total: " + num + " / visible: " +
				totalVisible + " / hidden: " + totalHidden;
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				drawItems();
			}
		}

		private function onStageResize(event:Event):void
		{
			_field.width = stage.stageWidth - MARGIN * 2;
			drawItems();
		}
    }
}
