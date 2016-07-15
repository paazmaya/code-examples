/**
 * @mxmlc -target-player=10.0.0 -source-path=. -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
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
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSEngine;


	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * A simple test to see which features of Gtalk could be accessed.
	 * https://github.com/timkurvers/as3-crypto
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi/xiff-chat-part-8-gtalk
	 */
	public class XIFFExampleGoogleTalk extends Sprite
	{
		private const SERVER:String = "talk.google.com";
		private const DOMAIN:String = "gmail.com";
		private const PORT:int = 5222;
		private const USERNAME:String = "olavic";
		private const PASSWORD:String = "kissanviikset";
		private const RESOURCE_NAME:String = "xiff";
		private const CHECK_POLICY:Boolean = true;

		private var _connection:XMPPTLSConnection;
		private var _config:TLSConfig;
		private var _roster:Roster;
		private var _keepAlive:Timer;

		private var _trafficField:TextField;

		private var _rosterCont:Sprite;
		private var _vcards:Array = [];

		public function XIFFExampleGoogleTalk()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}

		private function onInit(event:Event):void
		{
			if (CHECK_POLICY)
			{
				Security.loadPolicyFile("xmlsocket://" + SERVER + ":" + PORT);
			}

			initChat();
		}

		private function initChat():void
		{
			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
            addChild(_trafficField);

			createConnection();

			_roster = new Roster(_connection);
			_roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);

			_connection.connect();

			_keepAlive = new Timer(2 * 60 * 1000); // 2 minutes
			_keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);
		}


		private function createConnection():void
		{
			_config = new TLSConfig( TLSEngine.CLIENT );
			_config.ignoreCommonNameMismatch = true;
			_config.trustSelfSignedCertificates = false; // make sure this is false due to a bug in as3crypto

			_connection = new XMPPTLSConnection();
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(LoginEvent.LOGIN, onLogin);
			_connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
			_connection.addEventListener(PresenceEvent.PRESENCE, onPresence);

			_connection.config = _config;
			_connection.server = SERVER;
			_connection.domain = DOMAIN;
			_connection.username = USERNAME;
			_connection.password = PASSWORD;
			_connection.port = PORT;
			_connection.resource = RESOURCE_NAME;
			_connection.tls = true;

			// Once TLS is negotiated, Plain is allowed
			_connection.enableSASLMechanism(Plain.MECHANISM, Plain);
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
			_trafficField.appendText(getTimer() + " - incoming: " +
				event.data.toString() + "\n\n");
		}

		private function onOutgoingData(event:OutgoingDataEvent):void
		{
			_trafficField.appendText(getTimer() + " - outgoing: " +
				event.data.toString() + "\n\n");
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
