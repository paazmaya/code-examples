/**
 * @mxmlc -target-player=10.0.0 -source-path=D:/AS3libs
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.system.*;

	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;

	[SWF(backgroundColor = '0xF1F2F3', frameRate = '33', width = '800', height = '600')]

	/**
	 * Testing TweenLite by passing on balls at the screen.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi
	 */
	public class TweenLiteTestBalls extends Sprite
	{
		private var _cacheAsBitmap:Boolean = false;
		private var _concurrentTweens:uint = 10;
		private var _cont:Sprite;
		private var _field:TextField;
		private var _movingCount:int = 0;
		private var _timer:Timer;
		private var _totalAmount:uint = 2000;
		private var _tweenTime:Number = 0.5;

		/**
		 * There should be concurrently going some ten tweens.
		 */
		public function TweenLiteTestBalls()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		/**
		 * Wait until all the functions of this application are available.
		 * @param	event
		 */
		private function onInit(event:Event):void
		{
			TweenPlugin.activate([FastTransformPlugin]);

			stage.addEventListener(KeyboardEvent.KEY_UP, onKey);

			_cont = new Sprite();
			_cont.cacheAsBitmap = false;
			addChild(_cont);

			_field = new TextField();
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.background = true;
			_field.text = "_cacheAsBitmap: " + _cacheAsBitmap;
			addChild(_field);

			drawSprites();

			_timer = new Timer(_concurrentTweens * _tweenTime);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}

		/**
		 * Timer is repeated every ~50 milliseconds.
		 * Randomly choose some ~10 balls and move them to random positions.
		 * @param	event
		 */
		private function onTimer(event:TimerEvent):void
		{
			var num:uint = _cont.numChildren;
			var total:uint = _concurrentTweens;
			var start:int = Math.round(Math.random() * (num - _concurrentTweens));
			if (start < 0)
			{
				start = 0;
			}
			if (num < (_concurrentTweens + start))
			{
				total = num - start;
			}
			for (var i:uint = 0; i < total; ++i)
			{
				var sp:Sprite = _cont.getChildAt(start + i) as Sprite;
				if (sp != null)
				{
					var xt:Number = Math.random() * stage.stageWidth;
					var yt:Number = Math.random() * stage.stageHeight;

					sp.cacheAsBitmap = _cacheAsBitmap;

					_cont.swapChildrenAt(start + i, num - 1);

					TweenLite.to(sp, _tweenTime, { fastTransform: { x: xt, y: yt },
						ease: Quart.easeInOut, onStart: onMoveStart, onComplete: onMoveEnd } );
				}
			}
			_field.text = "_cacheAsBitmap: " + _cacheAsBitmap + ". Mem: "
				+ Math.round(System.totalMemory / 1024 / 1024 * 10) / 10 + " MB. Concurrent: "
				+ _movingCount + ". Total: " + _totalAmount;
		}

		/**
		 * Increase the counter to be displayed of the concurrent tweens.
		 */
		private function onMoveStart():void
		{
			++_movingCount;
		}

		/**
		 * After the tween has completed, reduce the number of concurrent tweens.
		 */
		private function onMoveEnd():void
		{
			--_movingCount;
		}

		/**
		 * As per user interaction, the bitmap caching can be toggled.
		 * So can full screen.
		 * @param	event
		 */
		private function onKey(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				_cacheAsBitmap = !_cacheAsBitmap;
			}
			else if (event.keyCode == Keyboard.ENTER)
			{
				if (stage.displayState == StageDisplayState.NORMAL)
				{
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}
				else
				{
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}

		/**
		 * Create a decent amount of balls.
		 */
		private function drawSprites():void
		{
			for (var i:uint = 0; i < _totalAmount; ++i)
			{
				var sp:Sprite = createBall(i);
				_cont.addChild(sp);
			}
		}

		/**
		 * Create a sprite, draw its contents elsewhere.
		 * @param	index
		 * @return
		 */
		private function createBall(index:uint):Sprite
		{
			var margin:Number = 20;
			var sp:Sprite = new Sprite();
			sp.name = "sp_" + index;
			sp.mouseChildren = false;
			sp.x = Math.random() * (stage.stageWidth - margin) + margin / 2;
			sp.y = Math.random() * (stage.stageHeight - margin) + margin / 2;
			drawCircle(sp.graphics);
			sp.cacheAsBitmap = _cacheAsBitmap;
			return sp;
		}

		/**
		 * Draw the ball in the given graphics object, which can be taken from a Sprite for example.
		 * @param	gra
		 */
		private function drawCircle(gra:Graphics):void
		{
			var radius:Number = Math.random() * 20 + 5;
			gra.clear();
			gra.lineStyle(1, 0x121212);
			gra.beginFill(randomColor());
			gra.drawCircle(0, 0, radius);
			gra.endFill();
		}

		/**
		 * Calculate a random color, either limited within a certain hardcoded limit or all possibilities.
		 * @param	limited
		 * @return
		 */
		private function randomColor(limited:Boolean = false):uint
		{
			var rgb:uint;

			if (limited)
			{
				var r:int = Math.round(100 + Math.random() * 155);
				var g:int = Math.round(125 + Math.random() * 60);
				var b:int = Math.round(Math.random() * 10);
				rgb = (r << 16 | g << 8 | b);
			}
			else
			{
				rgb = Math.random() * 0xFFFFFF;
			}

			return rgb;
		}
	}
}
