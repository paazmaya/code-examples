/**
 * @mxmlc -target-player=10.0.0 -debug -source-path=D:/AS3libs
 */
package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.ui.*;

    import org.papervision3d._cameras.Camera3D;
    import org.papervision3d.core.*;
    import org.papervision3d.core.render.data.RenderStatistics;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.view.Viewport3D;

    import com.greensock.TweenLite;

    [SWF(backgroundColor = '0x042836', frameRate = "33", width = "970", height = "500")]

	/**
     * PaperVision3D example to show how multiple views can be rendered
     * https://code.google.com/p/papervision3d/
     *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://www.paazmaya.fi
	 */
    public class MultiView extends Sprite
	{
        private var _scene:Scene3D;
        private var _cameras:Array;
        private var _views:Array;
        private var _renderer:BasicRenderEngine;
        private var _center:DisplayObject3D;
        private var _cube:Cube;
        private var _format:TextFormat;
        private var _currentZoom:Number = 1.0;

        [Embed(source = "../assets/nrkis.ttf", fontFamily = "nrkis")]
        public var nrkis:String;

        public function MultiView()
		{
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.HIGH;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
            _renderer = new BasicRenderEngine();

            _scene = new Scene3D();

            _center = new DisplayObject3D();
            _center.name = "_center";
            _scene.addChild(_center);

            _format = new TextFormat();
            _format.font = "nrkis";
            _format.bold = true;
            _format.align = TextFormatAlign.LEFT;
            _format.color = 0x010101;
            _format.size = 13;

            createViews();

            createCameras();

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

            var list:Object = {};
            var locs:Array = ["all", "front", "back", "right", "left", "top", "bottom"];
			var len:uint = locs.length;
            for (var i:uint = 0; i < len; ++i)
			{
                var sp:Sprite = new Sprite();
                sp.name = String(locs[i]);

                var gra:Graphics = sp.graphics;
                gra.lineStyle(1, 0x000000);
                gra.beginFill(Math.random() * 0xFFFFFF);
                gra.drawRect(0, 0, 200, 100);

                var tx:TextField = new TextField();
                tx.defaultTextFormat = _format;
                tx.embedFonts = true;
                tx.text = sp.name;
                tx.width = 100;
                sp.addChild(tx);
                list[sp.name] = new MovieMaterial(sp, true);
                //list[locs[i]] = new ColorMaterial(Math.random() * 0xFFFFFF, 1.0, true);
            }

            var materials:MaterialsList = new MaterialsList(list);
            _cube = new Cube(materials, 200, 300, 100, 4, 4, 4);
            _scene.addChild(_cube);
        }

        private function createViews():void
		{
            _views = [];
            var settings:Array = [
                { w: 640, h: 480, x: 0, y: 1 },
                { w: 320, h: 240, x: 642, y: 1 },
                { w: 320, h: 240, x: 642, y: 242 }
            ];

            var len:uint = settings.length;
            for (var i:uint = 0; i < len; ++i)
			{
                var opts:Object = settings[i] as Object;

                var view:Viewport3D = new Viewport3D(opts.w, opts.h);
                view.name = "Viewport " + i.toString();
                view.x = opts.x;
                view.y = opts.y;
                view.graphics.lineStyle(1, 0x000000);
                view.graphics.drawRect(0, 0, opts.w - 1, opts.h - 1);
                addChild(view);

                var tx:TextField = new TextField();
                tx.defaultTextFormat = _format;
                tx.embedFonts = true;
                tx.name = "title";
                tx.width = opts.w;
                view.addChild(tx);

                var rx:TextField = new TextField();
                rx.defaultTextFormat = _format;
                rx.embedFonts = true;
                rx.multiline = true;
                rx.wordWrap = true;
                rx.name = "render";
                rx.width = opts.w;
                rx.height = 32;
                rx.y = opts.h - 32;
                view.addChild(rx);

                _views.push(view);
            }
        }

        private function createCameras():void
		{
            _cameras = [];

            var cams:Array = [
                { x: 0, y: 0, z: 200, name: "Front" },
                { x: 0, y: 0, z: -200, name: "Back" },
                { x: 1, y: 200, z: 0, name: "Top" }, // x non zero to get out from the box.
                { x: 1, y: -200, z: 0, name: "Bottom" },
                { x: 200, y: 0, z: 0, name: "Right" },
                { x: -200, y: 0, z: 0, name: "Left" },
                { x: 160, y: 160, z: 160, name: "Angular" } // Extra camera for special angle.
            ];

            var len:uint = cams.length;
            for (var i:uint = 0; i < len; ++i)
			{
                var opts:Object = cams[i] as Object;

                var cam:Camera3D = new Camera3D(_center, _currentZoom);
                cam.name = opts.name;
                cam.x = opts.x;
                cam.y = opts.y;
                cam.z = opts.z;
                _cameras.push(cam);
            }
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }

        private function onEnterFrame(event:Event):void
		{
            var len:uint = _views.length;

            for (var i:uint = 0; i < len; ++i)
			{
                var view:Viewport3D = _views[i] as Viewport3D;
                var cam:Camera3D = _cameras[i] as Camera3D;
                if (view.name == "Viewport 0")
				{
                    cam.zoom = _currentZoom * 2;
                }
                else
				{
                    cam.zoom = _currentZoom;
                }

                var title:TextField = view.getChildByName("title") as TextField;
                title.text = view.name + " - " + cam.name + " - Zoom: " + cam.zoom.toFixed(2);

                var stat:RenderStatistics = _renderer.renderScene(_scene, cam, view);
                var render:TextField = view.getChildByName("render") as TextField;
                render.text = stat.toString();
            }
        }

        private function onKeyUp(event:KeyboardEvent):void
		{
            var cam:Camera3D;
            switch(event.keyCode)
			{
                case Keyboard.LEFT:
                    // rotate camera array
                    cam = _cameras.shift() as Camera3D;
                    _cameras.push(cam);
                    break;

                case Keyboard.RIGHT:
                    // rotate camera array
                    cam = _cameras.pop() as Camera3D;
                    _cameras.unshift(cam);
                    break;

                case 82: // r
                    // Rotate the object
                    TweenLite.to(_cube, 1, {rotationY: "+90"});
                    break;
            }
        }

        private function onMouseWheel(event:MouseEvent):void
		{
            _currentZoom += event.delta / 100;
        }
    }
}
