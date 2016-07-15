/**
 * @mxmlc -target-player=10.0.0 -source-path=. -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.text.*;
	import flash.utils.*;
	import flash.ui.*;

	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.im.*;
	import org.igniterealtime.xiff.events.*;
	import org.igniterealtime.xiff.im.*;


	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * How to registers a new user
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi/
	 */
	public class XIFFExampleRegistration extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const RESOURCE_NAME:String = "InBandRegistrant";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;


		private var _connection:XMPPConnection;
        private var _registrator:InBandRegistrator;
		private var _keepAlive:Timer;
		private var _outputField:TextField;
		private var _inputField:TextField;
        private var _rosterCont:Sprite;
		private var _chattingWith:EscapedJID;
		private var _trafficField:TextField;

		/**
		 *
		 */
		public function XIFFExampleRegistration()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			if (CHECK_POLICY)
			{
				Security.loadPolicyFile("xmlsocket://" + SERVER + ":" + POLICY_PORT);
			}
			connect();
			createAllFields();

		}

		private function connect():void
		{
			_connection = new XMPPConnection();
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			_connection.addEventListener(ConnectionSuccessEvent.CONNECT_SUCCESS, onConnected);

			_connection.server = SERVER;
			_connection.port = PORT;

            _registrator = new InBandRegistrator(_connection);
            _registrator.addEventListener(RegistrationSuccessEvent.REGISTRATION_SUCCESS, onRegistrator);
            _registrator.addEventListener(ChangePasswordSuccessEvent.PASSWORD_SUCCESS, onRegistrator);
            _registrator.addEventListener(RegistrationFieldsEvent.REG_FIELDS, onRegistrator);

			_connection.connect();
		}

		private function createAllFields():void
		{
			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
            addChild(_trafficField);
		}

		private function onConnected(event:ConnectionSuccessEvent):void
		{
			_registrator.getRegistrationFields();
		}


		private function onRegistrator(event:Event):void
		{
            trace("onRegistrator. " + event.toString());
            switch (event.type)
			{
                case RegistrationSuccessEvent.REGISTRATION_SUCCESS :
                    break;
                case ChangePasswordSuccessEvent.PASSWORD_SUCCESS :
                    break;
                case RegistrationFieldsEvent.REG_FIELDS :
					drawRegistrationForm(RegistrationFieldsEvent(event).fields);
                    break;
			}
		}

		private function drawRegistrationForm(fields:Array):void
		{
			var sp:Sprite = new Sprite();
			sp.name = "reg_form";

			var len:uint = fields.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var label:TextField = new TextField();
				label.defaultTextFormat = new TextFormat("Verdana", 12, 0xf4f4f4);
				label.text = fields[i];
				label.x = 2;
				label.y = 30 * i;
				sp.addChild(label);
				var field:TextField = createField(fields[i], 80, label.y, stage.stageWidth / 3 * 2, 26);
				sp.addChild(field);
			}

			addChild(sp);
		}

		private function onIncomingData(event:IncomingDataEvent):void
		{
			_trafficField.appendText(getTimer() + " - incoming: " +
				event.data.toString() + "\n\n");
		}

		private function onOutgoingData(event:OutgoingDataEvent):void
		{
			_trafficField.appendText(getTimer() + " - outgoing: " +
				event.data.toString() + "\n\n");
		}

		private function onDisconnect(event:DisconnectionEvent):void
		{
			trace("onDisconnect. " + event.toString());
		}

		private function onXiffError(event:XIFFErrorEvent):void
		{
            trace("onXiffError. " + event.toString());
			trace("onXiffError.errorMessage: " + event.errorMessage);
		}

		private function createField(name:String, xPos:Number,
			yPos:Number, w:Number, h:Number):TextField
		{
			var format:TextFormat = new TextFormat("Verdana", 12, 0x121212);
			var bgColor:uint = 0xE3E3C9;
			var borderColor:uint = 0x961D18;

			var field:TextField = new TextField();
			field.name = name;
			field.defaultTextFormat = format;
			field.background = true;
			field.backgroundColor = bgColor;
			field.border = true;
			field.borderColor = borderColor;
            field.multiline = true;
			field.wordWrap = true;
			field.mouseWheelEnabled = true;
			field.x = xPos;
			field.y = yPos;
			field.width = w;
			field.height = h;

			return field;
		}
	}
}
