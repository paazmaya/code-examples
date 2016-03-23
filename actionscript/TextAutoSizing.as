/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.text.*;

	[SWF( backgroundColor = '0x042836', frameRate = '33', width = '600', height = '400')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi
	 */
	public class TextAutoSizing extends Sprite
	{
		private var median:Shape;

		private var autosizes:Array = [
			TextFieldAutoSize.CENTER,
			TextFieldAutoSize.LEFT,
			TextFieldAutoSize.NONE,
			TextFieldAutoSize.RIGHT
		];

		private var alings:Array = [
			TextFormatAlign.CENTER,
			TextFormatAlign.JUSTIFY,
			TextFormatAlign.LEFT,
			TextFormatAlign.RIGHT
		];

		public function TextAutoSizing()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			median = new Shape();
			median.x = stage.stageWidth / 2;
			addChild(median);

			var gra:Graphics = median.graphics;
			gra.lineStyle(2, 0x0066FF);
			gra.lineTo(0, stage.stageHeight);

			var k:uint = 0;
			var lenS:uint = autosizes.length;
			var lenL:uint = alings.length;
			for (var i:uint = 0; i < lenS; ++i)
			{
				for (var j:uint = 0; j < lenL; ++j)
				{
					var field:TextField = createTextField(autosizes[i], alings[j]);
					field.y = 24 * (k) + 10;
					field.text = "This text field has autosize: " + field.autoSize
						+ " and align: " + field.defaultTextFormat.align + ".";
					addChild(field);
					++k;
				}
			}
		}

		private function createTextField(auto:String, align:String):TextField
		{
			var format:TextFormat = new TextFormat();
			format.align = align;
			format.color = 0x000000;
			format.size = 12;

			var field:TextField = new TextField();
			field.background = true;
			field.backgroundColor = 0xFFFFFF;
			field.border = true;
			field.borderColor = 0x000000;
			field.autoSize = auto;
			field.defaultTextFormat = format;
			field.type = TextFieldType.INPUT;
			field.x = median.x;
			return field;
		}
	}
}
