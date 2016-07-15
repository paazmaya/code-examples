/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
  import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.text.*;

	import com.greensock.TweenLite;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '1000', height = '500')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi
	 */
    public class LineStylesTest extends Sprite
	{
		private var lineScales:Array =
		[
			LineScaleMode.HORIZONTAL,
			LineScaleMode.NONE,
			LineScaleMode.NORMAL,
			LineScaleMode.VERTICAL
		];
		private var jointStyles:Array =
		[
			JointStyle.BEVEL,
			JointStyle.MITER,
			JointStyle.ROUND
		];
		private var capsStyles:Array =
		[
			CapsStyle.NONE,
			CapsStyle.ROUND,
			CapsStyle.SQUARE
		];

		private var _cont:Sprite;
		private var _width:Number = 100;
		private var _margin:Number = 12;
		private var _miter:Number = 8;
		private var _field:TextField;

    public function LineStylesTest()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			var format:TextFormat = new TextFormat();
			format.color = 0x121212;
			format.font = "_sans";
			format.size = 12;

			_cont = new Sprite();
			addChild(_cont);

			_field = new TextField();
			_field.autoSize = TextFieldAutoSize.CENTER;
			_field.defaultTextFormat = format;
			_field.multiline = true;
			_field.background = true;
			_field.border = true;
			_field.selectable = false;
			_field.visible = false;
			addChild(_field);

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.UP)
			{
				++_miter;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				--_miter;
			}
			else if (event.keyCode == Keyboard.SPACE)
			{
				drawTriangles();
			}
		}

		private function drawTriangles():void
		{
			removeChildren();
			var lenL:uint = lineScales.length;
			var lenJ:uint = jointStyles.length;
			var lenC:uint = capsStyles.length;
			for (var i:uint = 0; i < lenL; ++i)
			{
				for (var j:uint = 0; j < lenJ; ++j)
				{
					for (var k:uint = 0; k < lenC; ++k)
					{
						var sp:Sprite = createShape(lineScales[i], capsStyles[k], jointStyles[j], _miter);
						sp.x = _margin + (j * lenC + k) * (_width + _margin);
						sp.y = _margin + i * (_width + _margin);
						_cont.addChild(sp);
					}
				}
			}
		}

		private function createShape(lineScale:String, caps:String, joint:String, miter:Number = 10):Sprite
		{
      var sp:Sprite = new Sprite();
			sp.name = "LineScaleMode: " + lineScale + "\nCapsStyle: " + caps + "\nJointStyle: " + joint + "\nMiter: " + miter.toString();
			sp.addEventListener(MouseEvent.MOUSE_OVER, onMouse);
			sp.addEventListener(MouseEvent.MOUSE_OUT, onMouse);
			sp.addEventListener(MouseEvent.CLICK, onMouse);

			var gra:Graphics = sp.graphics;
			gra.lineStyle(8, 0x121212, 1, false, lineScale, caps, joint, miter);
			gra.moveTo(_width / 2, 0);
      gra.lineTo(_width, _width / 2);
      gra.lineTo(0, _width / 2);
      gra.lineTo(_width / 2, 0);

      return sp;
    }

		private function removeChildren():void
		{
			var num:uint = _cont.numChildren;
			for (var i:uint = num; i > 0; --i)
			{
				_cont.removeChildAt(i - 1);
			}
		}

		private function onMouse(event:MouseEvent):void
		{
			var sp:Sprite = event.target as Sprite;
			if (event.type == MouseEvent.MOUSE_OVER)
			{
				_field.text = sp.name;
				_field.x = sp.x;
				_field.y = sp.y + sp.height;
				_field.visible = true;
				swapChildren(_field, getChildAt(numChildren - 1));
			}
			else if (event.type == MouseEvent.MOUSE_OUT)
			{
				//_field.visible = false;
			}
			else if (event.type == MouseEvent.CLICK)
			{
				TweenLite.to(sp, 4, { scaleX: 3, onComplete: function():void
					{ sp.scaleX = 1.0; }
				} );
				TweenLite.to(sp, 4, { scaleY: 3, onComplete: function():void
					{ sp.scaleY = 1.0; },
					delay: 4, overwrite: 0
				} );
			}
		}
    }
}
