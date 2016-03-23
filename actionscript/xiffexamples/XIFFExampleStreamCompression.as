/**
 * @mxmlc -target-player=11 -source-path=. -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.ui.Keyboard;
	import flash.system.Security;

	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.auth.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.events.*;
	import org.igniterealtime.xiff.conference.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.im.*;
	import org.igniterealtime.xiff.data.browse.*;
	import org.igniterealtime.xiff.data.im.*;
	import org.igniterealtime.xiff.data.muc.*;
	import org.igniterealtime.xiff.data.vcard.*;
	import org.igniterealtime.xiff.util.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * A test to use the new compression feature in XIFF
	 * with statistics comparison to non compressed.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi/xiff-finally-supports-stream-compression
	 */
	public class XIFFExampleStreamCompression extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:int = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "Compression";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;
		private const COMPRESS:Boolean = true;

		private var _compressor:ICompressor = new Zlib();
		private var _connection:XMPPConnection;
		private var _roster:Roster;
		private var _keepAlive:Timer;

		private var _statField:TextField;
		private var _statTimer:Timer;
		private var _trafficField:TextField;

		private var _outgoingNonCompressed:uint = 0;
		private var _incomingNonCompressed:uint = 0;

		public function XIFFExampleStreamCompression()
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
			_connection = new XMPPConnection();
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(LoginEvent.LOGIN, onLogin);
			_connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
			_connection.addEventListener(PresenceEvent.PRESENCE, onPresence);

			_connection.enableExtensions(RosterExtension);

			_connection.server = SERVER;
			_connection.username = USERNAME;
			_connection.password = PASSWORD;
			_connection.port = PORT;
			_connection.resource = RESOURCE_NAME;
			_connection.compress = COMPRESS;
			_connection.compressor = _compressor;
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
			_incomingNonCompressed += event.data.length;
		}

		private function onOutgoingData(event:OutgoingDataEvent):void
		{
			_trafficField.appendText(getTimer() + " - outgoing: " +
				event.data.toString() + "\n\n");
			_outgoingNonCompressed += event.data.length;
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

		private function onRoster(event:RosterEvent):void
		{
			trace("onRoster. " + event.toString());
			trace("onRoster. data: " + event.data);
			switch (event.type)
			{
				case RosterEvent.ROSTER_LOADED :
					break;
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
