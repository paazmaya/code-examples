/**
 * @mxmlc -target-player=10.0.0 -debug
 */
package
{
  import flash.display.*;
  import flash.events.Event;

  [SWF(backgroundColor = '0xF8F8F8',
    frameRate = '33', width = '360', height = '220')]

  /**
   * @license http://creativecommons.org/licenses/by-sa/4.0/
   * @author Juga Paazmaya
   * @see http://www.paazmaya.fi
   */
  public class FlagFinland extends Sprite
  {
    private var heightUnits:uint = 11;
    private var widthUnits:uint = 18;
    private var measures:Array = [4, 3, 4, 5, 3, 10];
    /*
    The measures are counted as shown here.
    Each line represents one unit.
    Counterclockwise.
     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    |         |     |                   |
    |         |     |                   |
    |         |     |                   |
    |_ _ _ _ _|     |_ _ _ _ _ _ _ _ _ _|
    |                                   |
    |                                   |
    |_ _ _ _ _       _ _ _ _ _ _ _ _ _ _|
    |         |     |                   |
    |         |     |                   |
    |         |     |                   |
    |_ _ _ _ _|_ _ _|_ _ _ _ _ _ _ _ _ _|
    */

    public function FlagFinland()
    {
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.quality = StageQuality.MEDIUM;
      stage.addEventListener(Event.RESIZE, onResize);
      loaderInfo.addEventListener(Event.INIT, init);
    }

    private function init(event:Event):void
    {
      drawFlag();
    }

    private function onResize(event:Event):void
    {
      drawFlag();
    }

    private function drawFlag():void
    {
      var unit:Number = stage.stageWidth / widthUnits;
      var gra:Graphics = this.graphics;
      gra.clear();
      gra.beginFill(0x223399);
      gra.moveTo(0, unit * measures[0]);
      gra.lineTo(0, unit * measures[1] + unit *
        measures[0]);
      gra.lineTo(unit * measures[3], unit *
        measures[1] + unit * measures[0]);
      gra.lineTo(unit * measures[3], unit *
        heightUnits);
      gra.lineTo(unit * measures[3] + unit *
        measures[4], unit * heightUnits);
      gra.lineTo(unit * measures[3] + unit *
        measures[4], unit * measures[1] + unit *
        measures[0]);
      gra.lineTo(unit * widthUnits, unit *
        measures[1] + unit * measures[0]);
      gra.lineTo(unit * widthUnits, unit *
        measures[0]);
      gra.lineTo(unit * measures[3] + unit *
        measures[4], unit * measures[0]);
      gra.lineTo(unit * measures[3] + unit *
        measures[4], 0);
      gra.lineTo(unit * measures[3], 0);
      gra.lineTo(unit * measures[3], unit *
        measures[0]);
      gra.lineTo(0, unit * measures[0]);
      gra.endFill();
    }
  }
}
