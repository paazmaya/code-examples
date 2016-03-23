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
	import org.igniterealtime.xiff.util.*;


	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Attention request by the other party
	 *
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi/xiff-has-now-support-for-xep-0224-attention
	 */
	public class XIFFExampleMessageAttention extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "GetAttention";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;

		/**
		 * How often the keep alive call is made, seconds.
		 */
		private const KEEP_ALIVE_INTERVAL:Number = 30;

		private var _connection:XMPPConnection;
        private var _roster:Roster;
		private var _keepAlive:Timer;
		private var _stateTimer:Timer;
		private var _outputField:TextField;
		private var _inputField:TextField;
        private var _rosterCont:Sprite;
		private var _chattingWith:EscapedJID;
		private var _trafficField:TextField;


		/**
		 * Example of how to use attention property of the Message class.
		 */
		public function XIFFExampleMessageAttention()
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
			createAllFields();
			connect();

            _rosterCont = new Sprite();
            addChild(_rosterCont);

			_keepAlive = new Timer(KEEP_ALIVE_INTERVAL * 1000);
			_keepAlive.addEventListener(TimerEvent.TIMER, onKeepAlive);
		}

		private function connect():void
		{
			_connection = new XMPPConnection();
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
			_connection.addEventListener(LoginEvent.LOGIN, onLogin);
			_connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			_connection.addEventListener(PresenceEvent.PRESENCE, onPresence);

			_connection.username = USERNAME;
			_connection.password = PASSWORD;
			_connection.server = SERVER;
			_connection.port = PORT;
			_connection.resource = RESOURCE_NAME;

            _roster = new Roster(_connection);
            _roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);
            _roster.addEventListener(RosterEvent.USER_ADDED, onRoster);

			_connection.connect();
		}

		private function createAllFields():void
		{
			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
            addChild(_trafficField);

			_outputField = createField("output", stage.stageWidth / 3 - 3,
				3, stage.stageWidth / 3 * 2, stage.stageHeight / 2 - 56);
			addChild(_outputField);

			_inputField = createField("input", stage.stageWidth / 3 - 3,
				_outputField.y + _outputField.height + 3, stage.stageWidth / 3 * 2, 50);
			_inputField.type = TextFieldType.INPUT;
			_inputField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addChild(_inputField);
		}

		private function updateRosterCont():void
		{
			for (var i:uint = 0; i < _rosterCont.numChildren; ++i)
			{
				var sp:Sprite = _rosterCont.getChildAt(i) as Sprite;
				var tx:TextField = sp.getChildByName("jid") as TextField;
				var color:uint = 0x6A6A6A;
				if (_chattingWith && sp.name == _chattingWith.toString())
				{
					color = 0x121212;
				}

				var txtBounds:Rectangle = tx.getBounds(sp);
				var gr:Graphics = sp.graphics;
				gr.clear();
				gr.beginFill(color);
				gr.lineStyle(1, 0xCDCDCD);
				gr.drawRoundRect(0, 0, txtBounds.width + 4 + 10, txtBounds.height + 4, 8, 8);
				gr.endFill();

				var sh:Shape = sp.getChildByName("presence") as Shape;
				gr = sh.graphics;
				gr.clear();
				color = 0xAAAAAA;

				var item:Presence = _roster.getPresence(new UnescapedJID(sp.name)) as Presence;
				if (item != null && item.show != null)
				{
					switch (item.show)
					{
						case Presence.SHOW_CHAT:
							color = 0x00FF44;
							break;

						case Presence.SHOW_DND:
							color = 0xFF4400;
							break;

						case Presence.SHOW_AWAY:
							color = 0x886600;
							break;

						case Presence.SHOW_XA:
							color = 0xDFDFDF;
							break;
					}
				}
				gr.beginFill(color);
				gr.drawCircle(5, 5, 5);
				gr.endFill();
				sh.y = (sp.height - sh.height) / 2;
			}
		}

        private function addMessage(message:Message):void
		{
			var date:Date = new Date();
			if (message.time != null)
			{
				date = message.time;
			}

			_outputField.appendText("[" + DateTimeParser.time2string(date) + " | " +
				message.from.node + " > " + message.to.node + "] " + message.body + "\n");
			_outputField.scrollV = _outputField.maxScrollV;
		}

        private function buildRosterContent():void
		{
			var len:uint = _roster.length;
            for ( var i:uint = 0; i < len; ++i )
			{
				var item:RosterItemVO = _roster.getItemAt(i) as RosterItemVO;
				_rosterCont.addChild(createRosterButton(item.jid.toString(), i));
            }
			updateRosterCont();
        }

        private function createRosterButton(jid:String, counter:uint):Sprite
		{
            var sp:Sprite = new Sprite();
            sp.name = jid;
            sp.mouseChildren = false;
            sp.buttonMode = true;

			var sh:Shape = new Shape();
			sh.name = "presence";
			sh.x = 2;
			sh.y = 2;
			sp.addChild(sh);

            var tx:TextField = new TextField();
			tx.name = "jid";
            tx.text = jid;
            tx.textColor = 0xF2F2F2;
            tx.autoSize = TextFieldAutoSize.LEFT;
            tx.y = 1;
            tx.x = 14;
            sp.addChild(tx);

            sp.addEventListener(MouseEvent.CLICK, onMouse);
            sp.addEventListener(MouseEvent.MOUSE_OVER, onMouse);
            sp.addEventListener(MouseEvent.MOUSE_OUT, onMouse);
			sp.x = 2;
            sp.y = (sp.height + 4) * counter + 2;
			return sp;
        }

		private function onRoster(event:RosterEvent):void
		{
            trace("onRoster. " + event.toString());
            switch (event.type)
			{
                case RosterEvent.ROSTER_LOADED :
                    buildRosterContent();
                    break;
			}
		}

        private function onMouse(event:MouseEvent):void
		{
            var sp:Sprite = event.target as Sprite;
            var tx:TextField = sp.getChildByName("jid") as TextField;
            switch (event.type)
			{
                case MouseEvent.CLICK :
                    _chattingWith = new EscapedJID(sp.name);
					updateRosterCont();
                    break;
                case MouseEvent.MOUSE_OVER :
                    tx.textColor = 0xFF40A1;
                    break;
                case MouseEvent.MOUSE_OUT :
                    tx.textColor = 0xF2F2F2;
                    break;
            }
        }

        private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER )
			{
				// Using shift will add attention
				var useAttention:Boolean = event.shiftKey;

                messageSend(useAttention);
            }
        }

        private function messageSend(useAttention:Boolean = false):void
		{
			var messageSent:Boolean = false;
            var txt:String = _inputField.text;
			if (txt != "")
			{
				var message:Message = new Message(_chattingWith, "hoplaa",
					txt.replace("\n", "").replace("\r", ""),
					null, Message.TYPE_CHAT);
				message.attention = useAttention;

				if (_connection.loggedIn)
				{
					message.from = _connection.jid.escaped;
					_connection.send(message);
					_inputField.text = "";
					addMessage(message);
					messageSent = true;
				}
			}
        }

		private function onKeepAlive(event:TimerEvent):void
		{
			if (_connection.loggedIn)
			{
				_connection.sendKeepAlive();
			}
			else
			{
				connect();
			}
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

			var presence:Presence = new Presence(null, _connection.jid.escaped,
				null, Presence.SHOW_CHAT, "Nice day for a talk", 1);
			_connection.send(presence);

			_keepAlive.start();
		}

		private function onMessage(event:MessageEvent):void
		{
			trace("onMessage. " + event.toString());
			var message:Message = event.data as Message;

			if (message.body != null)
			{
				addMessage(message);
			}
			if (message.attention)
			{
				rosterAttention(message.from.bareJID);
			}
		}

		private function rosterAttention(from:String):void
		{
			var sp:Sprite = _rosterCont.getChildByName(from) as Sprite;
			if (sp != null)
			{
				var w:Number = sp.width;
				var h:Number = sp.height;
				var gra:Graphics = sp.graphics;
				gra.clear();

				gra.beginFill(0xF44000);
				gra.drawRoundRect(0, 0, w, h, 8, 8);
				gra.endFill();

				// After 3 seconds clear the red
				setTimeout(updateRosterCont, 3000);
			}
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
			}
			updateRosterCont();
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
