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
	import flash.external.ExternalInterface;

	import org.igniterealtime.xiff.conference.*;
	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.events.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Multi user chat invitations
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi/xiff-chat-part-4-invitations
	 */
	public class XIFFExampleRoomInvitations extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "InviteMe";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;

		private var _connection:XMPPConnection;
		private var _listener:InviteListener;
        private var _keepAlive:Timer;
		private var _trafficField:TextField;

		public function XIFFExampleRoomInvitations()
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

			_trafficField = createField("trafficField", 2, stage.stageHeight / 2,
				stage.stageWidth - 4, stage.stageHeight / 2 - 2);
            addChild(_trafficField);

			connect();

            _keepAlive = new Timer(2 * 60 * 1000);
            _keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);
		}

		private function connect():void
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
		}

		private function drawInvDialog(roomName:String, user:String):void
		{
			var sp:Sprite = new Sprite();
			sp.name = roomName;
			sp.mouseChildren = false;
			sp.x = 10 + 20 * numChildren;
			sp.y = 10 + 20 * numChildren;
			sp.addEventListener(MouseEvent.MOUSE_OVER, onInvDialogMouse);
			sp.addEventListener(MouseEvent.CLICK, onInvDialogMouse);

			var w:Number = 300;
			var h:Number = 100;

			var gra:Graphics = sp.graphics;
			gra.beginFill(0x0066FF);
			gra.drawRoundRect(0, 0, w, h, 10, 10);
			gra.endFill();
			gra.beginFill(0x3399FF);
			gra.drawRoundRect(5, 5, w - 10, h - 10, 10, 10);
			gra.endFill();

			var format:TextFormat = new TextFormat("Verdana", 12, 0x121212);

			var field:TextField = new TextField();
			field.name = "field";
			field.multiline = true;
			field.wordWrap = true;
			field.text = "You have been invited to a conference room [" + roomName + "] by user [" + user + "]";
			field.x = 7;
			field.y = 7;
			field.width = sp.width - 14;
			field.height = sp.height - 14;
			sp.addChild(field);

			addChild(sp);
		}

		private function onInvDialogMouse(event:MouseEvent):void
		{
			var sp:Sprite = event.target as Sprite;

			if (event.type == MouseEvent.MOUSE_OVER)
			{
				swapChildren(sp, getChildAt(numChildren - 1));
			}
			else if (event.type == MouseEvent.CLICK)
			{
				var room:Room = new Room(_connection);
				room.roomJID = new UnescapedJID(sp.name);
				room.join();
			}
		}

		private function onInvited(event:InviteEvent):void
		{
			drawInvDialog(event.room.roomJID.toString(), event.from.toString());
		}

		private function onLogin(event:LoginEvent):void
		{
            _keepAlive.start();

			_listener = new InviteListener(_connection);
			_listener.addEventListener(InviteEvent.INVITED, onInvited);

			var presence:Presence = new Presence(null, _connection.jid.escaped, null, null, null, 1);
			_connection.send(presence);
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
