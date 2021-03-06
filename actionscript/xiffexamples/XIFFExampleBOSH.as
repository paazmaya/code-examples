/**
 * @mxmlc -target-player=10.0.0 -source-path=. -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;

	import org.igniterealtime.xiff.auth.*;
	import org.igniterealtime.xiff.conference.*;
	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.browse.*;
	import org.igniterealtime.xiff.data.im.*;
	import org.igniterealtime.xiff.data.muc.*;
	import org.igniterealtime.xiff.data.vcard.*;
	import org.igniterealtime.xiff.events.*;
	import org.igniterealtime.xiff.im.*;
	import org.igniterealtime.xiff.util.*;
	import org.igniterealtime.xiff.vcard.*;
	import org.igniterealtime.xiff.vcard.VCard;


	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * BOSH connection
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi/xiff-example-9-bosh-connection
	 */
	public class XIFFExampleBOSH extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:int = 7077; // XMPPBOSHConnection.HTTP_PORT;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "BindingHTTP";
		private const CHECK_POLICY:Boolean = true;

		private var _connection:XMPPBOSHConnection;
		private var _roster:Roster;
		private var _keepAlive:Timer;

		private var _statField:TextField;
		private var _statTimer:Timer;
		private var _trafficField:TextField;

		private var _rosterCont:Sprite;
		private var _vcards:Array = [];

		private var _outgoingNonCompressed:uint = 0;
		private var _incomingNonCompressed:uint = 0;

		public function XIFFExampleBOSH()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			if (CHECK_POLICY)
			{
				//Security.loadPolicyFile("http://" + SERVER + ":" + PORT + "/crossdomain.xml");
				Security.loadPolicyFile("http://" + SERVER + "/crossdomain.xml");
				Security.loadPolicyFile("http://" + SERVER + ":5111" + "/crossdomain.xml");
			}
			initChat();
		}

		private function initChat():void
		{
			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
      addChild(_trafficField);

			_statField = createField("statField", 2, 2, 300, 70);
      addChild(_statField);

      _statTimer = new Timer(2 * 1000);
      _statTimer.addEventListener(TimerEvent.TIMER, onStatTimer);
			_statTimer.start();

			createConnection();

			_roster = new Roster(_connection);
			_roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);

			_connection.connect();

			_keepAlive = new Timer(2 * 60 * 1000); // 2 minutes
			_keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);
		}


		private function createConnection():void
		{
			_connection = new XMPPBOSHConnection();
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(LoginEvent.LOGIN, onLogin);
			_connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
			_connection.addEventListener(PresenceEvent.PRESENCE, onPresence);

			_connection.server = SERVER;
			_connection.username = USERNAME;
			_connection.password = PASSWORD;
			_connection.port = PORT;
			_connection.resource = RESOURCE_NAME;
		}

		private function onDisconnect(event:DisconnectionEvent):void
		{
			trace("onDisconnect. " + event.toString());
			_keepAlive.stop();
		}

		private function onXiffError(event:XIFFErrorEvent):void
		{
			trace("onXiffError. " + event.toString());
			trace("onXiffError. errorMessage: " + event.errorMessage);
		}

		private function onIncomingData(event:IncomingDataEvent):void
		{
			_incomingNonCompressed += event.data.length;
			_trafficField.appendText(getTimer() + " - incoming: " + event.data.toString() + "\n\n");
		}

		private function onOutgoingData(event:OutgoingDataEvent):void
		{
			_outgoingNonCompressed += event.data.length;
			_trafficField.appendText(getTimer() + " - outgoing: " + event.data.toString() + "\n\n");
		}

		private function onLogin(event:LoginEvent):void
		{
			trace("onLogin. " + event.toString());

			var presence:Presence = new Presence(null, _connection.jid.escaped);
			_connection.send(presence);

			_keepAlive.start();
		}

		private function onMessage(event:MessageEvent):void
		{
			trace("onMessage. " + event.toString());
			trace("onMessage. time: " + event.data.time);
		}

    private function onPresence(event:PresenceEvent):void
		{
			trace("onPresence. " + event.toString());
			var len:uint = event.data.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var presence:Presence = event.data[i] as Presence;
				trace("onPresence. " + i + " show: " + presence.show);
				trace("onPresence. " + i + " type: " + presence.type);
				trace("onPresence. " + i + " status: " + presence.status);
				trace("onPresence. " + i + " from: " + presence.from);
				trace("onPresence. " + i + " to: " + presence.to);

				switch (presence.type)
				{
					case Presence.TYPE_SUBSCRIBE :
						// Automatically add all those to _roster whom have requested to be our friend.
						_roster.grantSubscription(presence.from.unescaped, true);
						break;
					case Presence.TYPE_SUBSCRIBED :
						break;
				}
			}
		}

    private function onRoster(event:RosterEvent):void
		{
      trace("onRoster. " + event.toString());
			trace("onRoster. data: " + event.data);
      switch (event.type)
			{
        case RosterEvent.ROSTER_LOADED :
          break;
        case RosterEvent.USER_ADDED :
          break;
      }
    }

		private function onKeepAliveLoop(event:TimerEvent):void
		{
			_connection.sendKeepAlive();
		}

		private function onStatTimer(event:TimerEvent):void
		{
			if (_connection != null)
			{
				_statField.text = "Compressed / Uncompressed\n"
					+ "Incoming KB: " + Math.round(_connection.incomingBytes / 1024) + " / "
					+ Math.round(_incomingNonCompressed / 1024) + "\n"
					+ "Outgoing KB: " + Math.round(_connection.outgoingBytes / 1024) + " / "
					+ Math.round(_outgoingNonCompressed / 1024) + "\n";
			}
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
