/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.*;
	import flash.ui.Keyboard;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '600', height = '400')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi
	 */
	public class TextFieldTabbing extends Sprite
	{
		private var _format:TextFormat = new TextFormat("Verdana", 10, 0x121212);

		private var _enableTab:Boolean = true;

		public function TextFieldTabbing()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			createFields();
			stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		private function onKey(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				_enableTab = !_enableTab;
				createFields();
			}
		}

		private function onFieldFocus(event:FocusEvent):void
		{
			var field:TextField = event.target as TextField;
			swapChildren(field, getChildAt(numChildren - 1));
		}

		private function createFields():void
		{
			// Clear existing if any
			var num:int = numChildren - 1;
			while (num >= 0)
			{
				removeChildAt(num);
				--num;
			}

			var limit:uint = 55;
			for (var i:uint = 0; i < limit; ++i)
			{
				var field:TextField = createField("This is " + i, Math.random() * 0xFFFFFF);
				field.tabIndex = i;
				field.addEventListener(FocusEvent.FOCUS_IN, onFieldFocus);
				field.x = Math.random() * (stage.stageWidth - field.width);
				field.y = Math.random() * (stage.stageHeight - field.height);
				addChild(field);
			}
		}

		private function createField(text:String, bgColor:uint, borderColor:uint = 0x000000):TextField
		{
			var field:TextField = new TextField();
			field.background = true;
			field.backgroundColor = bgColor;
			field.border = true;
			field.borderColor = borderColor;
			field.defaultTextFormat = _format;
			field.text = text;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.type = TextFieldType.INPUT;

			// Is true if TextField.type == TextFieldType.INPUT
			field.tabEnabled = _enableTab;

			return field;
		}
	}
}
