
package {
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;

    [SWF(backgroundColor = '0x006599', frameRate = '33', width = '500', height = '330')]

    public class ContentScroll extends Sprite {

        private var backGlow:Shape;
        private var slider:Sprite;
        private var slideRect:Rectangle;
        private var bar:Sprite;
        private var masker:Shape;
        private var content:Sprite;

        private var sliderDragged:Boolean = false;
        private var arrowUpperDown:Boolean = false;
        private var arrowLowerDown:Boolean = false;
        private var arrowDownTimer:Timer;

        [Embed(source = 'ContentScrollSymbols.swc', symbol = 'Arrow')]
        private var Arrow:Class;
        [Embed(source = 'ContentScrollSymbols.swc', symbol = 'Bar')]
        private var Bar:Class;
        [Embed(source = 'ContentScrollSymbols.swc', symbol = 'Slider')]
        private var Slider:Class;

        public function ContentScroll() {
            backGlow = new Shape();
            this.addChild(backGlow);

            bar = new Bar() as Sprite;
            bar.x = 20;
            bar.y = 20;
            this.addChild(bar);

            var upper:Sprite = new Arrow() as Sprite;
            upper.name = "upper";
            upper.buttonMode = true;
            upper.x = 20;
            upper.y = bar.y - upper.height / 2;
            upper.addEventListener(MouseEvent.MOUSE_DOWN, onArrowMouse);
            upper.addEventListener(MouseEvent.MOUSE_UP, onArrowMouse);
            this.addChild(upper);

            var lower:Sprite = new Arrow() as Sprite;
            lower.name = "lower";
            lower.buttonMode = true;
            lower.x = 20;
            lower.y = upper.y + upper.height + bar.height;
            lower.scaleY = -1;
            lower.addEventListener(MouseEvent.MOUSE_DOWN, onArrowMouse);
            lower.addEventListener(MouseEvent.MOUSE_UP, onArrowMouse);
            this.addChild(lower);

            content = new Sprite();
            content.x = 50;
            content.y = 10;
            this.addChild(content);

            masker = new Shape();
            masker.x = content.x;
            masker.y = content.y;
            this.addChild(masker);

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.load(new URLRequest("http://www.paazmaya.fi/icons/square230x230.png"));
            content.addChild(loader);

            slider = new Slider() as Sprite;
            slider.buttonMode = true;
            slider.x = bar.x;
            slider.y = bar.y + slider.height / 2;
            slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderMouse);
            slider.addEventListener(MouseEvent.MOUSE_UP, onSliderMouse);
            this.addChild(slider);

            slideRect = new Rectangle(bar.x, bar.y + slider.height / 2,
              0, bar.height - slider.height);

            arrowDownTimer = new Timer(60);
            arrowDownTimer.addEventListener(TimerEvent.TIMER, onArrowTimer);

            this.addEventListener(Event.ADDED_TO_STAGE, onStageAdded);
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onStageAdded(evt:Event):void {
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, true);
        }

        private function onLoad(evt:Event):void {
            masker.graphics.clear();
            masker.graphics.beginFill(0xFF6633);
            masker.graphics.drawRoundRect(0, 0, content.width,
              bar.height + 20, 24, 24);
            masker.graphics.endFill();
            content.mask = masker;

            backGlow.x = masker.x - 2;
            backGlow.y = masker.y - 2;
            backGlow.graphics.beginFill(0xFFFFFF);
            backGlow.graphics.drawRoundRect(0, 0, masker.width + 4,
              masker.height + 4, 24, 24);
            backGlow.graphics.endFill();
            backGlow.filters = [new GlowFilter(0xFFFFFF, 1, 20, 20)];
        }

        private function onSliderMouse(evt:MouseEvent):void {
            if (evt.type == MouseEvent.MOUSE_DOWN) {
                slider.startDrag(false, slideRect);
                sliderDragged = true;
            }
            else if (evt.type == MouseEvent.MOUSE_UP) {
                slider.stopDrag();
                sliderDragged = false;
            }
        }

        private function onStageMouseUp(evt:MouseEvent):void {
            if (evt.eventPhase != EventPhase.BUBBLING_PHASE && sliderDragged) {
                slider.stopDrag();
                sliderDragged = false;
            }
        }

        private function onArrowMouse(evt:MouseEvent):void {
            var cur:Sprite = evt.target as Sprite;

            if (evt.type == MouseEvent.MOUSE_DOWN) {
                if (cur.name == "lower") {
                    arrowLowerDown = true;
                }
                else if (cur.name == "upper") {
                    arrowUpperDown = true;
                }
                arrowDownTimer.start();
            }
            else if (evt.type == MouseEvent.MOUSE_UP) {
                arrowUpperDown = false;
                arrowLowerDown = false;
                arrowDownTimer.stop();
            }
        }

        private function onMouseWheel(evt:MouseEvent):void {
            slider.y -= evt.delta * 2;
            checkLimits();
        }

        private function checkLimits():void {
            if (slider.y > slideRect.y + slideRect.height) {
                slider.y = slideRect.y + slideRect.height;
            }
            else if (slider.y < slideRect.y) {
                slider.y = slideRect.y;
            }
        }

        private function onArrowTimer(evt:TimerEvent):void {
            if (arrowUpperDown) {
                slider.y -= 10;
            }
            else if (arrowLowerDown) {
                slider.y += 10;
            }
            checkLimits();
        }

        private function onEnterFrame(evt:Event):void {
            content.y = ((slider.y - slideRect.y) / slideRect.height) *
              (masker.height - content.height) + masker.y;
        }
    }
}
