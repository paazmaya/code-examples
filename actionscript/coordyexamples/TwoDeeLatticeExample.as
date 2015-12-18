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

	import com.greensock.TweenNano; // Used for possible tweens

	import com.somerandomdude.coordy.layouts.twodee.Layout2d;
	import com.somerandomdude.coordy.layouts.twodee.Lattice;
	import com.somerandomdude.coordy.constants.LatticeType;
	import com.somerandomdude.coordy.constants.LatticeOrder;
	import com.somerandomdude.coordy.constants.LayoutUpdateMethod;
	import com.somerandomdude.coordy.utils.LayoutTransitioner;
	import com.somerandomdude.coordy.nodes.INode;

	[SWF(backgroundColor = '0x042836', frameRate = '33', width = '600', height = '400')]

	/**
	 * An example of the different parametres of the Lattice layout in 2D.
	 * Using the following libraries:
	 *  - coordy http://somerandomdude.com/projects/coordy/
	 *  - TweenNano http://www.greensock.com/tweennano/
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://www.paazmaya.fi
	 */
  public class TwoDeeLatticeExample extends Sprite
	{
		private const AMOUNT:uint = 60;
		private const MARGIN:uint = 10;
		private const TYPE:Array = [
			LatticeType.DIAGONAL,
			LatticeType.SQUARE
		];
		private const ORDER:Array = [
			LatticeOrder.ORDER_HORIZONTALLY,
			LatticeOrder.ORDER_VERTICALLY
		];


		private var _container:Sprite;
		private var _field:TextField;
		private var _layout:Lattice;

    public function TwoDeeLatticeExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			_container = new Sprite();
			addChild(_container);

			createLayout();
			createField();
			drawItems();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onStageResize);
    }

		private function createLayout():void
		{
			var sqrt:Number = Math.sqrt(AMOUNT);
			trace("sqrt: " + sqrt);
			_layout = new Lattice(
				stage.stageWidth - MARGIN * 2,
				stage.stageHeight - MARGIN * 2,
				Math.ceil(sqrt),
				Math.floor(sqrt)
			);
			_layout.x = MARGIN;
			_layout.y = MARGIN;

			//_layout.updateMethod = LayoutUpdateMethod.NONE;
			//LayoutTransitioner.tweenFunction = tweenItem;
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
				gra.drawCircle(0, 0, Math.random() * 20 + 10);
				gra.endFill();
				//sh.x = Math.random() * stage.stageWidth;
				//sh.y = Math.random() * stage.stageHeight;
				_container.addChild(sh);
				_layout.addNode(sh);
			}
		}

		private function onEnterFrame(event:Event):void
		{
			var num:uint = _container.numChildren;
			for (var i:uint = 0; i < num; ++i)
			{

			}
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				drawItems();
			}
			else if (event.keyCode == Keyboard.UP)
			{
				_layout.latticeType = LatticeType.DIAGONAL;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				_layout.latticeType = LatticeType.SQUARE;
			}
			else if (event.keyCode == Keyboard.LEFT)
			{
				_layout.order = LatticeOrder.ORDER_HORIZONTALLY;
			}
			else if (event.keyCode == Keyboard.RIGHT)
			{
				_layout.order = LatticeOrder.ORDER_VERTICALLY;
			}
			_field.text = "latticeType: " + _layout.latticeType + ", order: " + _layout.order;
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
