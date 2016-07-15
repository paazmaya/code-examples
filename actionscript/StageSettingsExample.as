/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '500', height = '300')]

	/**
	 * A test on how do different Stage settings
	 * related to the visual presentation behave.
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
	public class StageSettingsExample extends Sprite
	{
		private var _states:Array =
		[
			StageDisplayState.FULL_SCREEN,
			StageDisplayState.NORMAL
		];

		private var _alings:Array =
		[
			StageAlign.BOTTOM,
			StageAlign.BOTTOM_LEFT,
			StageAlign.BOTTOM_RIGHT,
			StageAlign.LEFT,
			StageAlign.RIGHT,
			StageAlign.TOP,
			StageAlign.TOP_LEFT,
			StageAlign.TOP_RIGHT
		];

		private var _qualities:Array =
		[
			StageQuality.BEST,
			StageQuality.HIGH,
			StageQuality.LOW,
			StageQuality.MEDIUM
		];

		private var _scales:Array =
		[
			StageScaleMode.EXACT_FIT,
			StageScaleMode.NO_BORDER,
			StageScaleMode.NO_SCALE,
			StageScaleMode.SHOW_ALL
		];

		public function StageSettingsExample()
		{
			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			var names:Array =
			[
				"StageDisplayState",
				"StageAlign",
				"StageQuality",
				"StageScaleMode"
			];
			var arrays:Array =
			[
				_states,
				_alings,
				_qualities,
				_scales
			];
			var len:uint = names.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var sp:Sprite = new Sprite();
				sp.name = names[i] as String;
				sp.y = 2;
				sp.x = 100 * i + 2;
				addChild(sp);
				createList(arrays[i] as Array, sp);
			}

			graphics.lineStyle(1);
			graphics.drawRect(1, 1, stage.stageWidth, stage.stageHeight);
		}

		private function createList(list:Array, parent:Sprite):void
		{
			var len:uint = list.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var sp:Sprite = createButton(list[i] as String);
				sp.y = (sp.height + 2) * i;
				parent.addChild(sp);
			}
		}

		private function onMouseUp(event:MouseEvent):void
		{
			var sp:Sprite = event.target as Sprite;
			var pr:Sprite = sp.parent as Sprite;
			trace("sp: " + sp.name + ", pr: " + pr.name);

			switch (pr.name)
			{
				case 'StageDisplayState' :
					stage.displayState = sp.name;
					break;
				case 'StageAlign' :
					stage.align = sp.name;
					break;
				case 'StageQuality' :
					stage.quality = sp.name;
					break;
				case 'StageScaleMode' :
					stage.scaleMode = sp.name;
					break;
			}
			var num:uint = pr.numChildren;
			for (var i:uint = 0; i < num; ++i)
			{
				var ch:Sprite = pr.getChildAt(i) as Sprite;
				drawButtonBg(ch);
			}
			drawButtonBg(sp, true);
		}

		private function createButton(text:String):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.name = text;
			sp.mouseChildren = false;
			sp.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			var tf:TextField = createField();
			tf.text = text;
			sp.addChild(tf);
			drawButtonBg(sp);
			return sp;
		}

		private function createField():TextField
		{
			var tf:TextField = new TextField();
			tf.textColor = 0xFAFAFA;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.x = 2;
			tf.y = 2;
			return tf;
		}

		private function drawButtonBg(sp:Sprite, current:Boolean = false):void
		{
			var color:uint = 0x121212;
			if (current)
			{
				color = 0x656565;
			}
			var gra:Graphics = sp.graphics;
			gra.clear();
			gra.beginFill(color);
			gra.drawRoundRect(0, 0, sp.width + 2, sp.height + 2, 10, 10);
			gra.endFill();
		}
	}
}
