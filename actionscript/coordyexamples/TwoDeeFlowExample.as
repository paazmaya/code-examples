/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package coordyexamples
{
  import flash.display.*;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import com.somerandomdude.coordy.layouts.twodee.Layout2d;
	import com.somerandomdude.coordy.layouts.twodee.Flow;
	import com.somerandomdude.coordy.constants.FlowAlignment;
	import com.somerandomdude.coordy.constants.FlowDirection;
	import com.somerandomdude.coordy.constants.FlowOverflowPolicy;
	import com.somerandomdude.coordy.nodes.INode;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '800', height = '600')]

	/**
	 * An example of the different parametres of the Lattice layout in 2D.
	 * Get the library in question, coordy, from
	 *   http://somerandomdude.com/projects/coordy/
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi
	 */
  public class TwoDeeFlowExample extends Sprite
	{
		private const AMOUNT:uint = 60;
		private const MARGIN:uint = 10;
		private const ALIGNMENT:Array = [
			FlowAlignment.BOTTOM_CENTER,
			FlowAlignment.BOTTOM_LEFT,
			FlowAlignment.BOTTOM_RIGHT,
			FlowAlignment.MIDDLE_CENTER,
			FlowAlignment.MIDDLE_LEFT,
			FlowAlignment.MIDDLE_RIGHT,
			FlowAlignment.TOP_CENTER,
			FlowAlignment.TOP_LEFT,
			FlowAlignment.TOP_RIGHT
		];
		private const DIRECTION:Array = [
			FlowDirection.HORIZONTAL,
			FlowDirection.VERTICAL
		];
		private const POLICY:Array = [
			FlowOverflowPolicy.ALLOW_OVERFLOW,
			FlowOverflowPolicy.HIDE_OVERFLOW,
			FlowOverflowPolicy.IGNORE_OVERFLOW
		];


		private var _container:Sprite;
		private var _field:TextField;
		private var _layout:Flow;

        public function TwoDeeFlowExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			_container = new Sprite();
			addChild(_container);

			createField();
			createLayout();
			drawItems();

			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
        }

		private function createLayout():void
		{
			var sqrt:Number = Math.sqrt(AMOUNT);
			trace("sqrt: " + sqrt);
			_layout = new Flow(
				stage.stageWidth - MARGIN * 2,
				stage.stageHeight - MARGIN * 2
			);
			_layout.x = MARGIN;
			_layout.y = MARGIN;
			setFieldText();
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

		private function setFieldText():void
		{
			_field.text = "align: " + _layout.align + ", placementDirection: " +
				_layout.placementDirection + ", overflowPolicy: " + _layout.overflowPolicy +
				", paddingX: " + _layout.paddingX + ", paddingY: " + _layout.paddingY
		}

		private function drawItems():void
		{
			var num:uint = _container.numChildren;
			while (num > 0)
			{
				--num;
				var item:DisplayObject = _container.getChildAt(num);
				var node:INode = _layout.getNodeByLink(item);
				_layout.removeNode(node);
				_container.removeChild(item);
			}

			for (var i:uint = 0; i < AMOUNT; ++i)
			{
				var sh:Shape = new Shape();
				var gra:Graphics = sh.graphics;
				gra.beginFill(Math.random() * 0xFFFFFF);
				gra.drawCircle(0, 0, Math.random() * 30 + 10);
				gra.endFill();
				_container.addChild(sh);
				_layout.addNode(sh);
			}
		}

		/**
		 * Each arrow key will command individual array.
		 * @param	event
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				drawItems();
			}
			else if (event.keyCode == Keyboard.UP)
			{
				_layout.align = nextInArray(_layout.align, ALIGNMENT);
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				_layout.placementDirection = nextInArray(_layout.placementDirection, DIRECTION);
			}
			else if (event.keyCode == Keyboard.LEFT)
			{
				_layout.overflowPolicy = nextInArray(_layout.overflowPolicy, POLICY);
			}
			else if (event.keyCode == Keyboard.RIGHT)
			{
				//_layout.align = nextInArray(_layout.align, ALIGNMENT);
			}
			else if (event.keyCode == Keyboard.HOME)
			{
				++_layout.paddingX;
				++_layout.paddingY;
			}
			else if (event.keyCode == Keyboard.END)
			{
				--_layout.paddingX;
				--_layout.paddingY;
			}
			setFieldText();
		}

		private function nextInArray(current:String, list:Array):String
		{
			var index:int = list.indexOf(current);
			if (index !== -1)
			{
				++index;
				if (index == list.length)
				{
					index = 0;
				}
				return list[index];
			}
			return "";
		}

		private function onStageResize(event:Event):void
		{
			_field.width = stage.stageWidth - MARGIN * 2;
			_layout.width = stage.stageWidth - MARGIN * 2;
			_layout.height = stage.stageHeight - MARGIN * 2;
			//drawItems();
		}
    }
}
