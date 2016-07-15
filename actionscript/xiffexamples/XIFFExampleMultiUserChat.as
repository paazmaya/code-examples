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
    import org.igniterealtime.xiff.data.disco.*;
    import org.igniterealtime.xiff.events.*;
    import org.igniterealtime.xiff.exception.*;
    import org.igniterealtime.xiff.data.muc.*;
    import org.igniterealtime.xiff.util.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Multi user chat / room example
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see https://paazmaya.fi/xiff-chat-part-3-chat-room
	 */
    public class XIFFExampleMultiUserChat extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "MUCroom";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;

        private var _connection:XMPPConnection;
        private var _browser:Browser;
        private var _room:Room;
        private var _keepAlive:Timer;

        private var _outputField:TextField;
        private var _inputField:TextField;
		private var _buttonContainer:Sprite;
		private var _trafficField:TextField;

		private var _conferenceServer:String = "";

        public function XIFFExampleMultiUserChat()
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

            _outputField = createField("outputField", 2, 2,
				(stage.stageWidth - 4) / 2, stage.stageHeight / 2 - 34);
            addChild(_outputField);

            _inputField = createField("inputField", 2,
				stage.stageHeight / 2 - 30, stage.stageWidth - 4, 28);
            _inputField.type = TextFieldType.INPUT;
            _inputField.maxChars = 160;
            _inputField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            addChild(_inputField);

			_buttonContainer = new Sprite();
			_buttonContainer.x = stage.stageWidth / 2 + 2;
			_buttonContainer.y = 2;
			addChild(_buttonContainer);
        }

        private function addGroupMessage(message:Message):void
		{
            var date:Date = new Date();
			if (message.time != null)
			{
				date = message.time;
			}
			var from:String = message.from.resource ? message.from.resource: message.from.node;
			_outputField.appendText("[" + date.getHours() + ":"
				+ date.getMinutes() + " | " + from
				+ "] " + message.body + "\n");
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

        private function messageSend():void
		{
            var txt:String = _inputField.text;
            if (_connection.loggedIn && _room.isActive)
			{
                _room.sendMessage(txt);
                _inputField.text = "";
            }
        }

        private function initChat():void
		{
            _connection = new XMPPConnection();
            _connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
            _connection.addEventListener(LoginEvent.LOGIN, onLogin);
            _connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
            _connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);

            _connection.username = USERNAME;
            _connection.password = PASSWORD;
            _connection.server = SERVER;
            _connection.port = PORT;
            _connection.resource = RESOURCE_NAME;
            _connection.connect();

            _keepAlive = new Timer(2 * 60 * 1000);
            _keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);

            _room = new Room(_connection);
            _room.addEventListener(RoomEvent.ADMIN_ERROR, onRoom);
            _room.addEventListener(RoomEvent.AFFILIATIONS, onRoom);
            _room.addEventListener(RoomEvent.BANNED_ERROR, onRoom);
            _room.addEventListener(RoomEvent.CONFIGURE_ROOM, onRoom);
            _room.addEventListener(RoomEvent.DECLINED, onRoom);
            _room.addEventListener(RoomEvent.GROUP_MESSAGE, onRoom);
            _room.addEventListener(RoomEvent.LOCKED_ERROR, onRoom);
            _room.addEventListener(RoomEvent.MAX_USERS_ERROR, onRoom);
            _room.addEventListener(RoomEvent.NICK_CONFLICT, onRoom);
            _room.addEventListener(RoomEvent.PASSWORD_ERROR, onRoom);
            _room.addEventListener(RoomEvent.PRIVATE_MESSAGE, onRoom);
            _room.addEventListener(RoomEvent.REGISTRATION_REQ_ERROR, onRoom);
            _room.addEventListener(RoomEvent.ROOM_JOIN, onRoom);
            _room.addEventListener(RoomEvent.ROOM_LEAVE, onRoom);
            _room.addEventListener(RoomEvent.SUBJECT_CHANGE, onRoom);
            _room.addEventListener(RoomEvent.USER_BANNED, onRoom);
            _room.addEventListener(RoomEvent.USER_DEPARTURE, onRoom);
            _room.addEventListener(RoomEvent.USER_JOIN, onRoom);
            _room.addEventListener(RoomEvent.USER_KICKED, onRoom);
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

			var presence:Presence = new Presence(null, _connection.jid.escaped,
				null, Presence.SHOW_CHAT, "Gimme room", 2);
            _connection.send(presence);

            var serverJID:EscapedJID = new EscapedJID(SERVER);
            _browser = new Browser(_connection);
            _browser.getServiceItems(serverJID, serviceItemsCall);
            //_browser.getServiceInfo(serverJID, serviceInfoCall);
        }

        private function onRoom(event:RoomEvent):void
		{
            trace("onRoom. " + event.toString());
            switch (event.type)
			{
                case RoomEvent.ADMIN_ERROR :
                    break;
                case RoomEvent.AFFILIATIONS :
                    break;
                case RoomEvent.BANNED_ERROR :
                    break;
                case RoomEvent.CONFIGURE_ROOM :
                    break;
                case RoomEvent.DECLINED :
                    break;
                case RoomEvent.GROUP_MESSAGE :
                    // Could also use MessageEvent event of the XMPPConnection.
					trace("event.data is Message: " + (event.data is Message) + ", data: " + event.data);
					addGroupMessage(event.data as Message);
                    break;
                case RoomEvent.LOCKED_ERROR :
                    break;
                case RoomEvent.MAX_USERS_ERROR :
                    break;
                case RoomEvent.NICK_CONFLICT :
                    break;
                case RoomEvent.PASSWORD_ERROR :
                    break;
                case RoomEvent.PRIVATE_MESSAGE :
                    break;
                case RoomEvent.REGISTRATION_REQ_ERROR :
                    break;
                case RoomEvent.ROOM_JOIN :
                    break;
                case RoomEvent.ROOM_LEAVE :
                    break;
                case RoomEvent.SUBJECT_CHANGE :
                    break;
                case RoomEvent.USER_BANNED :
                    break;
                case RoomEvent.USER_DEPARTURE :
                    break;
                case RoomEvent.USER_JOIN :
                    break;
                case RoomEvent.USER_KICKED :
                    break;
            }
        }

        private function createButton(txt:String, jid:String, counter:uint, xPos:Number = 0):void
		{
            var sp:Sprite = new Sprite();
            sp.name = jid;
            sp.mouseChildren = false;
            sp.buttonMode = true;
			sp.alpha = 0.6;

            var tx:TextField = new TextField();
            tx.text = txt;
            tx.textColor = 0xE3E3C9;
            tx.autoSize = TextFieldAutoSize.LEFT;
            tx.y = 2;
            tx.x = 2;
            sp.addChild(tx);

            var gr:Graphics = sp.graphics;
            gr.beginFill(0x961D18);
            gr.lineStyle(1, 0xE3E3C9);
            gr.drawRoundRect(0, 0, sp.width + 4, 22, 8, 8);
            gr.endFill();

			if (txt == "Public Chatrooms")
			{
				_conferenceServer = jid;
				sp.addEventListener(MouseEvent.CLICK, onConferenceMouse);
				sp.alpha = 1.0;
			}
			else if (_conferenceServer != "" && jid.split("@").pop() == _conferenceServer)
			{
				sp.addEventListener(MouseEvent.CLICK, onRoomMouse);
				sp.alpha = 1.0;
			}
			sp.x = xPos;
			sp.y = sp.height * counter;
			_buttonContainer.addChild(sp);
        }

        private function onConferenceMouse(event:MouseEvent):void
		{
            var jid:EscapedJID = new EscapedJID(_conferenceServer);
            _browser.getServiceItems(jid, serviceItemsCall);
        }

        private function onRoomMouse(event:MouseEvent):void
		{
            var jid:EscapedJID = new EscapedJID(event.target.name);
			if (_room.isActive)
			{
				_room.leave();
			}
			_room.roomJID = jid.unescaped;
			_room.join();
        }

        public function serviceItemsCall(iq:IQ):void
		{
			trace("serviceItemsCall. iq: " + iq);
			var xPos:Number = _buttonContainer.width;
            var extensions:Array = iq.getAllExtensions();
            for (var s:int = 0; s < extensions.length; ++s)
			{
                var disco:ItemDiscoExtension = extensions[s];
                var items:Array = disco.items;
                trace(">> serviceItemsCall. round " + s + ". items.length: " + items.length);
                for (var i:uint = 0; i < items.length; ++i)
				{
                    var obj:DiscoItem = items[i] as DiscoItem;
                    createButton(obj.name, obj.jid, i, xPos);
                    trace(">> name: " + obj.name + ", jid: " + obj.jid + ", node: " + obj.node);
                }
            }
        }

        public function serviceInfoCall(iq:IQ):void
		{
            var extensions:Array = iq.getAllExtensions();
            for (var s:int = 0; s < extensions.length; ++s)
			{
                var disco:InfoDiscoExtension = extensions[s];
                var features:Array = disco.features;
                for (var r:int = 0; r < features.length; ++r)
				{
					var feat:DiscoFeature = features[r] as DiscoFeature;
                    trace("** serviceInfoCall. " + r + ", var: " + feat.varName);
                }
                var identities:Array = disco.identities;
                for (var i:int = 0; i < identities.length; ++i)
				{
                    var ident:DiscoIdentity = identities[i] as DiscoIdentity;
                    trace("** serviceInfoCall. name: " + ident.name + ", type: " + ident.type + ", category: " + ident.category);
                }
            }
        }

        private function onKeepAliveLoop(event:TimerEvent):void
		{
            if (_connection.loggedIn)
			{
                _connection.sendKeepAlive();
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
