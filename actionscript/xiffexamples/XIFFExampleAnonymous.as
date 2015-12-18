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

  import org.igniterealtime.xiff.core.*;
  import org.igniterealtime.xiff.data.*;
  import org.igniterealtime.xiff.events.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Simple example of an anonymous access to a XMPP server
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://www.paazmaya.fi/xiff-chat-part-1
	 */
  public class XIFFExampleAnonymous extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "random";
		private const RESOURCE_NAME:String = "AnonymousFP";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;

    private var _connection:XMPPConnection;
    private var _keepAlive:Timer;
    private var _outputField:TextField;
    private var _inputField:TextField;
    private var _chattingWith:EscapedJID = new EscapedJID("apina@" + SERVER);
		private var _trafficField:TextField;

        public function XIFFExampleAnonymous()
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

            _outputField = createField("outputField", 10, 10,
				stage.stageWidth - 20, stage.stageHeight / 2 - 80);
            addChild(_outputField);

            _inputField = createField("inputField", 10, stage.stageHeight / 2 - 60,
				stage.stageWidth - 20, 50);
            _inputField.type = TextFieldType.INPUT;
            _inputField.maxChars = 160;
            _inputField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            addChild(_inputField);
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

        private function messageSend():void
		{
            var txt:String = _inputField.text;
            var message:Message = new Message(_chattingWith, null, txt, null, Message.TYPE_CHAT);
            if (_connection.loggedIn)
			{
				message.from = _connection.jid.escaped;
                _connection.send(message);
                _inputField.text = "";
                addMessage(message);
            }
        }

        private function initChat():void
		{
            _connection = new XMPPConnection();

            _connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
            _connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
            _connection.addEventListener(LoginEvent.LOGIN, onLogin);
            _connection.addEventListener(MessageEvent.MESSAGE, onMessage);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);

            _connection.useAnonymousLogin = true;
            _connection.server = SERVER;
            _connection.port = PORT;
			_connection.username = USERNAME;
            _connection.resource = RESOURCE_NAME;
            _connection.connect(XMPPConnection.STREAM_TYPE_STANDARD);

            _keepAlive = new Timer(2 * 60 * 1000);
            _keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);
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

			var presence:Presence = new Presence(null, _connection.jid.escaped);
            _connection.send(presence);
        }

        private function onMessage(event:MessageEvent):void
		{
            trace("onMessage. " + event.toString());
            addMessage(event.data);
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
