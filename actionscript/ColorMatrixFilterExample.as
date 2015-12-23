/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;

	[SWF(backgroundColor = '0x042836', frameRate = '33',
		width = '880', height = '500')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://www.paazmaya.fi
	 */
  public class ColorMatrixFilterExample extends Sprite
	{
		private var _original:Bitmap;

		/**
		 * Matrixes of red, green, blue, gray.
		 * 1, 0, 0, 0, 0, (red )
		 * 0, 1, 0, 0, 0, (green)
		 * 0, 0, 1, 0, 0, (blue)
		 * 0, 0, 0, 1, 0  (alpha)
		 */
		private var _matrises:Array =
		[
			[
				1, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 1, 0
			],
			[
				0, 0, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 1, 0
			],
			[
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 1, 0, 0,
				0, 0, 0, 1, 0
			],
			[
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0,   0,    0,    1, 0
			]
		];

		private var _transforms:Array =
		[
			new ColorTransform(0.7, 0.7, 0.7, 1),
			new ColorTransform(0.3, 0.4, 0.5, 1),
			new ColorTransform(1.2, 1.1, 1.2, 1)
		];

		// http://picasaweb.google.com/olavic/Korkeasaari20080701
		[Embed(source = "Korkeasaari2008-07-01_059.jpg", mimeType = "image/jpeg")]
		private var Pollot:Class;

    public function ColorMatrixFilterExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			_original = new Pollot() as Bitmap;
			addChild(_original);

			var len:uint = _matrises.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var mt:Array = _matrises[i] as Array;
				var bmi:Bitmap = new Bitmap(_original.bitmapData.clone());
				bmi.x = i * bmi.width;
				bmi.y = bmi.height;
				addChild(bmi);

				var filter:ColorMatrixFilter = new ColorMatrixFilter(mt);
				bmi.filters = [filter];
			}

			var total:uint = _transforms.length;
			for (var j:uint = 0; j < total; ++j)
			{
				var bmj:Bitmap = new Bitmap(_original.bitmapData.clone());
				bmj.x = j * bmj.width;
				bmj.y = 2 * bmj.height;
				addChild(bmj);

				bmj.transform.colorTransform = _transforms[j];
			}
    }
  }
}
