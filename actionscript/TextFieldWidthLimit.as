/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '400', height = '200')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
	public class TextFieldWidthLimit extends Sprite
	{
		/*
		 * Word warp before the limit is reached
		 */
		private const WIDTH_LIMIT:Number = 320;

		private var _format:TextFormat;
		private var _field:TextField;
		private var _background:Shape;

		// -----
		private var _lines:TextField;
		// -----

		public function TextFieldWidthLimit()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			_background = new Shape();
			_background.x = 10;
			_background.y = 10;
			addChild(_background);

			_format = new TextFormat();
			_format.font = "Verdana";
			_format.color = 0x000000;
			_format.bold = true;
			_format.size = 12;
			_format.align = TextFormatAlign.LEFT;

			_field = new TextField();
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.antiAliasType = AntiAliasType.ADVANCED;
			_field.defaultTextFormat = _format;
			_field.type = TextFieldType.INPUT;
			_field.width = WIDTH_LIMIT;
			_field.multiline = true;
			_field.wordWrap = true;
			_field.text = "Advanced anti-aliasing allows font faces to be rendered at very high quality at small sizes.\n\nAdvanced anti-aliasing is not recommended for very large fonts (larger than 48 points).";
			_field.x = _background.x;
			_field.y = _background.y;
			_field.addEventListener(TextEvent.TEXT_INPUT, onTextChange);
			addChild(_field);

			graphics.lineStyle(1, 0xFFFFFF, 0.5);
			graphics.moveTo(WIDTH_LIMIT + _background.x, 0);
			graphics.lineTo(WIDTH_LIMIT + _background.x, stage.stageHeight);

			// -----
			_lines = new TextField();
			_lines.autoSize = TextFieldAutoSize.RIGHT;
			_lines.border = true;
			_lines.borderColor = 0x000000;
			_lines.background = true;
			_lines.backgroundColor = 0xFFFFFF;
			_lines.y = stage.stageHeight - 22;
			_lines.x = stage.stageWidth - 8;
			addChild(_lines);
			// -----

			drawBackground();
		}

		private function drawBackground():void
		{
			var rect:Rectangle = _field.getRect(this);
			var w:Number = 0;

			// -----
			_lines.text = _field.numLines.toString();
			// -----

			var num:uint = _field.numLines;
			for (var i:uint = 0; i < num; ++i)
			{
				var metr:TextLineMetrics = _field.getLineMetrics(i);
				if (metr.width > w)
				{
					w = metr.width;
				}
				trace("Line " + i + " width: " + metr.width);
			}

			if (w >= WIDTH_LIMIT)
			{
				w = WIDTH_LIMIT;
			}

			_field.width = w;
			_field.height = _field.textHeight;

			var gra:Graphics = _background.graphics;
			gra.clear();
			gra.beginFill(0xFFFFFF);
			gra.lineStyle(1, 0x000000);
			gra.drawRoundRect(0, 0, _field.width + 2, _field.height + 2, 6, 6);
			gra.endFill();
		}

		private function onTextChange(event:TextEvent):void
		{
			drawBackground();
		}
	}
}
