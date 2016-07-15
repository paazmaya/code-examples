/**
 * @mxmlc -target-player=10.0.0 -source-path=. -debug
 */
package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
	import flash.system.Security;
    import flash.ui.Keyboard;

    import org.igniterealtime.xiff.conference.*;
    import org.igniterealtime.xiff.core.*;
    import org.igniterealtime.xiff.data.*;
    import org.igniterealtime.xiff.data.im.*;
    import org.igniterealtime.xiff.events.*;
    import org.igniterealtime.xiff.exception.*;
    import org.igniterealtime.xiff.im.*;
    import org.igniterealtime.xiff.util.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Example of roster usage via RTMP connection
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi/
	 */
    public class XIFFExampleRTMP extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "RosterAsking";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;

        private var _connection:XMPPRTMPConnection;
        private var _roster:Roster;

        private var _keepAlive:Timer;
        private var _outputField:TextField;
        private var _inputField:TextField;
        private var _recipientField:TextField;
        private var _rosterCont:Sprite;
        private var _chattingWith:UnescapedJID;
		private var _trafficField:TextField;

        public function XIFFExampleRTMP()
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
            createElements();

            initChat();
        }

        private function createElements():void
		{
			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
            addChild(_trafficField);

            _rosterCont = new Sprite();
			_rosterCont.x = 10;
			_rosterCont.y = 10;
            addChild(_rosterCont);

			_recipientField = createField("recipientField", 10, 40,
				stage.stageWidth - 20, 20);
            addChild(_recipientField);

            _outputField = createField("outputField", 10, 70,
				stage.stageWidth - 20, stage.stageHeight / 2 - 130);
            addChild(_outputField);

            _inputField = createField("inputField", 10,
				_outputField.y + _outputField.height + 10,
				stage.stageWidth - 20, 40);
            _inputField.type = TextFieldType.INPUT;
            _inputField.maxChars = 160;
            _inputField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            addChild(_inputField);

        }

        private function initChat():void
		{
            _connection = new XMPPRTMPConnection();
            _connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
            _connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
            _connection.addEventListener(LoginEvent.LOGIN, onLogin);
            _connection.addEventListener(MessageEvent.MESSAGE, onMessage);
            _connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);
            _connection.addEventListener(PresenceEvent.PRESENCE, onPresence);

            _connection.username = USERNAME;
            _connection.password = PASSWORD;
            _connection.server = SERVER;
            _connection.port = PORT;
            _connection.resource = RESOURCE_NAME;
            _connection.connect();

            _keepAlive = new Timer(2 * 60 * 1000);
            _keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);

            _roster = new Roster(_connection);
            _roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);
            _roster.addEventListener(RosterEvent.SUBSCRIPTION_DENIAL, onRoster);
            _roster.addEventListener(RosterEvent.SUBSCRIPTION_REQUEST, onRoster);
            _roster.addEventListener(RosterEvent.SUBSCRIPTION_REVOCATION, onRoster);
            _roster.addEventListener(RosterEvent.USER_ADDED, onRoster);
            _roster.addEventListener(RosterEvent.USER_AVAILABLE, onRoster);
            _roster.addEventListener(RosterEvent.USER_PRESENCE_UPDATED, onRoster);
            _roster.addEventListener(RosterEvent.USER_REMOVED, onRoster);
            _roster.addEventListener(RosterEvent.USER_SUBSCRIPTION_UPDATED, onRoster);
            _roster.addEventListener(RosterEvent.USER_UNAVAILABLE, onRoster);
        }

        private function messageSend():void
		{
            var txt:String = _inputField.text;
            var message:Message = new Message(_chattingWith.escaped, null, txt, null, Message.TYPE_CHAT);
            if (_connection.loggedIn)
			{
                _connection.send(message);
				message.from = _connection.jid.escaped;
                _inputField.text = "";
                addMessage(message);
            }
        }

        private function buildRosterContent():void
		{
            // Add buttons for each user found in the roster.
			var people:Array = _roster.toArray();
			var len:uint = people.length;
            for (var i:uint = 0; i < len; ++i)
			{
				var item:Sprite = createButton(people[ i ] as RosterItemVO);
				item.x = _rosterCont.width + 10;
				_rosterCont.addChild(item);
            }
        }

        private function createButton(item:RosterItemVO):Sprite
		{
            var sp:Sprite = new Sprite();
            sp.name = item.jid.toString();
            sp.mouseChildren = false;
            sp.buttonMode = true;

            var tx:TextField = new TextField();
            tx.text = item.jid.toString();
            tx.textColor = 0xF2F2F2;
            tx.autoSize = TextFieldAutoSize.LEFT;
            tx.y = 2;
            tx.x = 2;
            sp.addChild(tx);

            var gr:Graphics = sp.graphics;
            gr.beginFill(0x961D18);
            gr.lineStyle(1, 0x1A1A1A);
            gr.drawRoundRect(0, 0, sp.width + 4, 22, 8, 8);
            gr.endFill();

            sp.addEventListener(MouseEvent.CLICK, onMouse);
            sp.addEventListener(MouseEvent.MOUSE_OVER, onMouse);
            sp.addEventListener(MouseEvent.MOUSE_OUT, onMouse);
			return sp;
        }

        private function addMessage(message:Message):void
		{
			var date:Date = new Date();
			_outputField.appendText("[" + date.getHours() + ":"
				+ date.getMinutes() + " | " + message.from.node + " > "
				+ message.to.node + "] " + message.body + "\n");
			_outputField.scrollV = _outputField.maxScrollV;
		}

        private function onKeyUp(event:KeyboardEvent):void
		{
            switch(event.keyCode)
			{
                case Keyboard.ENTER :
                    messageSend();
                    break;
            }
        }

        private function onXiffError(event:XIFFErrorEvent):void
		{
            trace("onXiffError. " + event.toString());
			trace("onXiffError.errorMessage: " + event.errorMessage);
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

            _keepAlive.start();

			var presence:Presence = new Presence(null, _connection.jid.escaped, null, null, null, 1);
            _connection.send(presence);
			trace("Sending presence: " + presence);
        }

        private function onMessage(event:MessageEvent):void
		{
            trace("onMessage. " + event.toString());
            addMessage(event.data);
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
            switch (event.type)
			{
                case RosterEvent.ROSTER_LOADED :
                    buildRosterContent();
                    break;
                case RosterEvent.SUBSCRIPTION_DENIAL :
                    break;
                case RosterEvent.SUBSCRIPTION_REQUEST :
                    // If the JID is in the roster, accept immediately
                    if (_roster.getPresence(event.jid) != null)
					{
                        _roster.grantSubscription(event.jid, true);
                    }
                    break;
                case RosterEvent.SUBSCRIPTION_REVOCATION :
                    break;
                case RosterEvent.USER_ADDED :
                    break;
                case RosterEvent.USER_AVAILABLE :
                    break;
                case RosterEvent.USER_PRESENCE_UPDATED :
                    break;
                case RosterEvent.USER_REMOVED :
                    break;
                case RosterEvent.USER_SUBSCRIPTION_UPDATED :
                    break;
                case RosterEvent.USER_UNAVAILABLE :
                    break;
            }
        }

        private function onMouse(event:MouseEvent):void
		{
            var sp:Sprite = event.target as Sprite;
            var tx:TextField = sp.getChildAt(0) as TextField;
            switch (event.type)
			{
                case MouseEvent.CLICK :
                    _chattingWith = new UnescapedJID(sp.name);
                    _recipientField.text = _chattingWith.bareJID.toString();

                    var ros:RosterItemVO = RosterItemVO.get(_chattingWith);
                    trace(">> Roster data for " + _chattingWith.toString());
                    trace(">> nickname: " + ros.nickname);
                    trace(">> askType: " + ros.askType);
                    trace(">> priority: " + ros.priority);
                    trace(">> show: " + ros.show);
                    trace(">> pending: " + ros.pending);
                    trace(">> status: " + ros.status);
                    trace(">> subscribeType: " + ros.subscribeType);
                    trace(">> uid: " + ros.uid);

					// Could get the presence like this
					trace("JID: " + sp.name + ", Presence: "
						+ _roster.getPresence(new UnescapedJID(sp.name)));

                    break;
                case MouseEvent.MOUSE_OVER :
                    tx.textColor = 0xFF40A1;
                    break;
                case MouseEvent.MOUSE_OUT :
                    tx.textColor = 0xF2F2F2;
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
