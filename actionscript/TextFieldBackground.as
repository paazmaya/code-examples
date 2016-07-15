/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
    import flash.display.*;
	import flash.events.Event;
    import flash.events.TextEvent;
    import flash.geom.Rectangle;
    import flash.text.*;

    [SWF( backgroundColor = '0x042836', frameRate = '33', width = '400', height = '200')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
    public class TextFieldBackground extends Sprite
	{
        private var _format:TextFormat;
        private var _field:TextField;
        private var _background:Shape;

        public function TextFieldBackground()
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
            _field.multiline = true;
            _field.text = "Ichiban ni narukoto wa kesshite kantan dewanai.\nThe best never comes easy.";
            _field.x = _background.x;
            _field.y = _background.y;
            _field.addEventListener(TextEvent.TEXT_INPUT, onTextChange);
            addChild(_field);

            drawBackground();
        }

        private function drawBackground():void
		{
            var rect:Rectangle = _field.getRect(this);

            var gra:Graphics = _background.graphics;
            gra.clear();
            gra.beginFill(0xFFFFFF);
            gra.lineStyle(1, 0x000000);
            gra.drawRoundRect(0, 0, rect.width, rect.height, 6, 6);
			gra.endFill();
        }

        private function onTextChange(event:TextEvent):void
		{
            drawBackground();
        }
    }
}
