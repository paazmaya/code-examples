/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
  import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '800', height = '600')]

	/**
	 * Test the matrix usage related to bitmap fill.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
    public class BitmapFillMatrix extends Sprite
    {
		private var _filled:Shape;
		private var _spotTrans:Shape;
		private var _spotDelta:Shape;
		private var _bitmapData:BitmapData;
		private var _timer:Timer;
		private var _field:TextField;
		private var _interval:Number = 60;
		private var _rotation:Number = 12;
		private var _width:Number = 600;
		private var _height:Number = 500;
		private var _scaling:Number = 1.0;

		// http://www.flickr.com/photos/paazio/2448433179/in/set-72157604775480332/
		[Embed(source = "2448433179_08c51ff095.jpg", mimeType = "image/jpeg")]
		private var Wugies:Class;

    public function BitmapFillMatrix()
    {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			_filled = new Shape();
			_filled.x = (stage.stageWidth - _width) / 2;
			_filled.y = (stage.stageHeight - _height) / 3;
			addChild(_filled);

			_spotTrans = new Shape();
			drawCircle(_spotTrans.graphics);
			addChild(_spotTrans);

			_spotDelta = new Shape();
			drawCircle(_spotDelta.graphics, 0xF46644);
			addChild(_spotDelta);

			var bm:Bitmap = new Wugies() as Bitmap;
			_bitmapData = bm.bitmapData.clone();

			_field = new TextField();
			_field.width = _width;
			_field.height = 40;
			_field.x = _filled.x;
			_field.y = _filled.y + _height + 10;
			_field.multiline = true;
			_field.border = true;
			_field.borderColor = 0x121212;
			_field.background = true;
			_field.backgroundColor = 0xF1F1F1;
			_field.wordWrap = true;
			addChild(_field);

			draw();

			_timer = new Timer(_interval);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouse);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		private function drawCircle(gra:Graphics, fillColor:uint = 0xF1F1F1, lineColor:uint = 0x121212):void
		{
			gra.lineStyle(1, lineColor);
			gra.beginFill(fillColor);
			gra.drawCircle(0, 0, 4);
			gra.endFill();
		}

		/**
		 * Toggles the timer. Alternatively can toggle the mouse move listener.
		 * @param	event
		 */
		private function onMouse(event:MouseEvent):void
		{
			if (event.type == MouseEvent.MOUSE_DOWN)
			{
				//_timer.start();
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			else if (event.type == MouseEvent.MOUSE_UP)
			{
				//_timer.stop();
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}

		private function onKey(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.LEFT :
					_rotation -= 2;
					break;
				case Keyboard.RIGHT :
					_rotation += 2;
					break;
				case Keyboard.UP :
					_scaling += 0.1;
					break;
				case Keyboard.DOWN :
					_scaling -= 0.1;
					break;
			}
			draw();
		}

		private function onMouseMove(event:MouseEvent):void
		{
			draw();
		}

		private function onTimer(event:TimerEvent):void
		{
			draw();
		}

		private function draw():void
		{
			var mat:Matrix = new Matrix();
			mat.tx = stage.mouseX - _filled.x;
			mat.ty = stage.mouseY - _filled.y;
			mat.rotate((_rotation / 180) * Math.PI);
			// mat.scale(a, d);
			mat.a = _scaling; // scaleX
			mat.d = _scaling; // scaleY
			//mat.b = Math.tan(19); // y screw
			//mat.c = Math.tan(0); // x screw
			_field.text = mat.toString();

			var posMouse:Point = new Point(stage.mouseX, stage.mouseY);

			var posTrans:Point = mat.transformPoint(posMouse);
			_spotTrans.x = posTrans.x;
			_spotTrans.y = posTrans.y;

			var posDelta:Point = mat.deltaTransformPoint(posMouse);
			_spotDelta.x = posDelta.x;
			_spotDelta.y = posDelta.y;

			var gra:Graphics = _filled.graphics;
			gra.clear();
			gra.lineStyle(1, 0x121212);
			gra.beginBitmapFill(_bitmapData, mat, false, true);
			gra.drawRect(0, 0, _width, _height);
			gra.endFill();
        }
    }
}
