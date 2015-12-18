package
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.text.*;
	import flash.system.Security;

	import com.yahoo.maps.api.*;
	import com.yahoo.maps.api.core.location.LatLon;
	import com.yahoo.maps.api.markers.Marker;
	import com.yahoo.maps.webservices.geocoder.events.*;
	import com.yahoo.maps.webservices.geocoder.GeocoderResultSet;
	import com.yahoo.maps.api.widgets.*;

	[SWF(backgroundColor = '0x006599', frameRate = '33', width = '700', height = '500')]

	/**
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://developer.yahoo.com/flash/maps/classreference/
	 */
	public class YahooMapWhereWasThis extends Sprite
	{
		private const YAHOO_MAP_ID:String = "R.UMBIXV34GzNHIQHZIbjtEEfPldx2rR72SL8QXg8Myf2deCtQo5eaHugwKfp8g-";
		private const POLICY_URL:String = "http://www.yahoo.com/crossdomain.xml";
		private const MINIMAP_SIZE:Number = 200;

		private var view:Sprite;
		private var map:YahooMap;
		private var miniview:Sprite;
		private var minimap:YahooMap;
		private var wolf:Sprite;
		private var mark:Marker;

		/**
		 * Center of the map. Defaults to the Olympic Stadium of Helsinki, Finland.
		 */
		private var _center:LatLon = new LatLon(60.186929111472885, 24.927334785461426);
		private var _title:String = "Helsinki Olympic Stadium";

		public function YahooMapWhereWasThis()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM;

			Security.loadPolicyFile(POLICY_URL);

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, onResize);

			if (stage.loaderInfo.parameters.lat != undefined && stage.loaderInfo.parameters.lat != "")
			{
				_center.lat = parseFloat(stage.loaderInfo.parameters.lat);
			}
			if (stage.loaderInfo.parameters.lng != undefined && stage.loaderInfo.parameters.lng != "")
			{
				_center.lon = parseFloat(stage.loaderInfo.parameters.lng);
			}
			if (stage.loaderInfo.parameters.title != undefined && stage.loaderInfo.parameters.title != "")
			{
				_title = String(stage.loaderInfo.parameters.title);
			}

			view = new Sprite();
			view.name = "view";
			addChild(view);

			miniview = new Sprite();
			miniview.name = "miniview";
			addChild(miniview);

			var gra:Graphics = miniview.graphics;
			gra.lineStyle(2, 0x000000);
			gra.beginFill(0x006599);
			gra.drawRoundRect(0, 0, MINIMAP_SIZE, MINIMAP_SIZE, 10, 10);
			gra.endFill();

			miniview.x = stage.stageWidth - (MINIMAP_SIZE + 2);
			miniview.y = stage.stageHeight - (MINIMAP_SIZE + 2);

			createMaps();
		}

		private function createMaps():void
		{
			map = new YahooMap();
			map.addEventListener(YahooMapEvent.MAP_INITIALIZE, onMapInitialize);
			map.addEventListener(YahooMapEvent.MAP_MOVE, onMapMove);
			map.init(YAHOO_MAP_ID, stage.stageWidth, stage.stageHeight);
			view.addChild(map);

			var mapType:MapTypeWidget = new MapTypeWidget(map);
			view.addChild(mapType);
		}

		private function onResize(event:Event):void
		{
			if (map != null)
			{
				map.setSize(stage.stageWidth, stage.stageHeight);
			}
			miniview.x = stage.stageWidth - (MINIMAP_SIZE + 2);
			miniview.y = stage.stageHeight - (MINIMAP_SIZE + 2);
			swapChildren(miniview, getChildAt(numChildren - 1));
		}

		private function onMapInitialize(event:YahooMapEvent):void
		{
			map.addPanControl();
			map.addZoomWidget();
			map.addScaleBar();

			map.zoomLevel = 4;
			map.centerLatLon = _center;

			_center.addEventListener(GeocoderEvent.GEOCODER_FAILURE, onGeocoderEvent);
			_center.addEventListener(GeocoderEvent.GEOCODER_SUCCESS, onGeocoderEvent);
			_center.reverseGeocode();

			var spot:Shape = new Shape();
			spot.name = "spot";
			spot.graphics.lineStyle(1, 0x121212, 0.5);
			spot.graphics.beginFill(0xFF6600, 0.5);
			spot.graphics.drawCircle(0, 0, 16);
			spot.graphics.endFill();

			var format:TextFormat = new TextFormat("Verdana", 12, 0x121212, true);

			var field:TextField = new TextField();
			field.name = "field";
			field.defaultTextFormat = format;
			field.mouseEnabled = false;
			field.multiline = true;
			field.text = _title;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.x = -field.width / 2;
			field.y = -field.height / 2;
			field.filters = [new GlowFilter(0x006599, 1, 10, 10)];

			mark = new Marker();
			mark.addChild(spot);
			mark.addChild(field);
			mark.latlon = map.centerLatLon;
			map.markerManager.addMarker(mark);

			minimap = new YahooMap();
			minimap.addEventListener(YahooMapEvent.MAP_INITIALIZE, onMinimapInitialize);
			minimap.init(YAHOO_MAP_ID, MINIMAP_SIZE - 4, MINIMAP_SIZE - 4);
			minimap.x = 2;
			minimap.y = 2;
			miniview.addChild(minimap);
		}

		private function onMinimapInitialize(event:YahooMapEvent):void
		{
			minimap.addCrosshair();
			minimap.zoomLevel = 10;
			minimap.centerLatLon = _center;
		}

		private function onGeocoderEvent(event:GeocoderEvent):void
		{
			var res:GeocoderResultSet = event.data as GeocoderResultSet;

			var field:TextField = mark.getChildByName("field") as TextField;
			field.appendText("\n" + _center.address.address);
			field.y = -field.height / 2;
		}

		private function onMapMove(event:YahooMapEvent):void
		{
			if (minimap != null)
			{
				minimap.centerLatLon = map.centerLatLon;
			}
		}
	}
}
