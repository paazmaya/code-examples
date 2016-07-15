/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.Event;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '420', height = '400')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
	public class RoundedCornersTest extends Sprite
	{
		private var _radius:Number = 40;
		private var _margin:Number = 25;
		private var _width:Number = 340;
		private var _height:Number = 150;

		public function RoundedCornersTest()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			var gra:Graphics = graphics;

			gra.beginFill(0x121212);
			gra.drawRoundRect(_margin, _margin, _width, _height,
				_radius, _radius);
			gra.endFill();

			gra.beginFill(0xF4F4F4);
			gra.drawRoundRectComplex(_margin, _margin * 2 + _height,
				_width, _height,
				_radius, _radius,
				_radius, -_radius);
			gra.endFill();

			// Lines for clearer visual presentation
			gra.lineStyle(1, 0xF84828, 0.8);
			gra.moveTo(_margin + _radius, 0);
			gra.lineTo(_margin + _radius, stage.stageHeight);
			gra.moveTo(_margin + _width - _radius, 0);
			gra.lineTo(_margin + _width - _radius, stage.stageHeight);
			gra.moveTo(0, _margin + _radius);
			gra.lineTo(stage.stageWidth, _margin + _radius);
			gra.moveTo(0, _margin + _radius);
			gra.lineTo(stage.stageWidth, _margin + _radius);
			gra.moveTo(0, _margin + _height - _radius);
			gra.lineTo(stage.stageWidth, _margin + _height - _radius);
			gra.moveTo(0, _margin * 2 + _height + _radius);
			gra.lineTo(stage.stageWidth, _margin * 2 + _height + _radius);
			gra.moveTo(0, _margin * 2 + _height * 2 - _radius);
			gra.lineTo(stage.stageWidth, _margin * 2 + _height * 2 - _radius);
		}
	}
}
