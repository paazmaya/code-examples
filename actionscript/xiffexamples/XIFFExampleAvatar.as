/**
 * @mxmlc -target-player=11.0.0 -source-path=. -debug
 */
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.system.Security;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.FileReference;
	import org.igniterealtime.xiff.vcard.IVCardPhoto;

	import org.igniterealtime.xiff.conference.*;
	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.im.*;
	import org.igniterealtime.xiff.data.vcard.*;
	import org.igniterealtime.xiff.events.*;
	import org.igniterealtime.xiff.im.*;
	import org.igniterealtime.xiff.util.*;
	import org.igniterealtime.xiff.vcard.*;


	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '800', height = '800')]

	/**
	 * Avatar image loading from users in roster.
	 * @license http://creativecommons.org/licenses/by-sa/4.0/
	 * @author Juga Paazmaya
	 * @see http://paazmaya.fi/xiff-chat-part-6-avatar-image
	 */
  public class XIFFExampleAvatar extends Sprite
	{
		private const SERVER:String = "192.168.1.37";
		private const PORT:uint = 5444;
		private const USERNAME:String = "flasher";
		private const PASSWORD:String = "flasher";
		private const RESOURCE_NAME:String = "AvatarTest";
		private const CHECK_POLICY:Boolean = true;
		private const POLICY_PORT:uint = 5229;
		private const COMPRESS:Boolean = false;

    private var _connection:XMPPConnection;
    private var _roster:Roster;
		private var _vcards:Object = {};
    private var _keepAlive:Timer;
    private var _rosterCont:Sprite;
		private var _statField:TextField;
		private var _statTimer:Timer;
		private var _format:TextFormat = new TextFormat("Verdana", 12, 0xF4F4F4);
		private var _trafficField:TextField;

		private var _fileRef:FileReference;
		private var _selectingPhotoForJid:String;

		/**
		 * @see http://xmpp.org/registrar/namespaces.html
		 * @see https://support.process-one.net/doc/display/MESSENGER/XMPP+Namespaces
		 */
		public function XIFFExampleAvatar()
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

			_statField = new TextField();
			_statField.name = "statField";
			_statField.defaultTextFormat = _format;
			_statField.multiline = true;
			_statField.wordWrap = true;
			_statField.width = 300;
			_statField.height = 40;
      addChild(_statField);

      _statTimer = new Timer(2 * 1000);
      _statTimer.addEventListener(TimerEvent.TIMER, onStatTimer);
			_statTimer.start();

			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.SELECT, onPhotoSelected);
			_fileRef.addEventListener(Event.COMPLETE, onFileLoaded);

      connect();
    }

    private function connect():void
		{
      _connection = new XMPPConnection();
      _connection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onXiffError);
      _connection.addEventListener(LoginEvent.LOGIN, onLogin);
      _connection.addEventListener(PresenceEvent.PRESENCE, onPresence);
			_connection.addEventListener(DisconnectionEvent.DISCONNECT, onDisconnect);
			_connection.addEventListener(IncomingDataEvent.INCOMING_DATA, onIncomingData);
			_connection.addEventListener(OutgoingDataEvent.OUTGOING_DATA, onOutgoingData);

			_connection.username = USERNAME;
			_connection.password = PASSWORD;
			_connection.server = SERVER;
			_connection.port = PORT;
			_connection.resource = RESOURCE_NAME;
			_connection.compress = COMPRESS;
			_connection.connect();

      _roster = new Roster(_connection);
      _roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);
      _roster.addEventListener(RosterEvent.USER_ADDED, onRoster);

      _keepAlive = new Timer(2 * 60 * 1000);
      _keepAlive.addEventListener(TimerEvent.TIMER, onKeepAliveLoop);
    }

		private function visualiseRoster():void
		{
			_rosterCont = new Sprite();
			_rosterCont.name = "rosterCont";
			_rosterCont.y = _statField.height;
			addChild(_rosterCont);

			var roster:Array = _roster.toArray();
			var len:uint = roster.length;
			for (var i:uint = 0; i < len; ++i)
			{
				var item:RosterItemVO = roster[i] as RosterItemVO;
				var box:Sprite = createUserBox(item);
				box.x = 10 + 40 * i;
				box.y = 10 + 30 * i;
				_rosterCont.addChild(box);

				var vCard:VCard = VCard.getVCard(_connection, item.jid);
				vCard.addEventListener(VCardEvent.LOADED, onVCard);
				vCard.addEventListener(VCardEvent.SAVED, onVCard);
				vCard.addEventListener(VCardEvent.SAVE_ERROR, onVCard);
				_vcards[item.jid.toString()] = vCard;
			}
		}

    private function createUserBox(item:RosterItemVO):Sprite
		{
      var sp:Sprite = new Sprite();
      sp.name = item.jid.bareJID;
      sp.mouseChildren = false;
      sp.buttonMode = true;

			var bm:Bitmap = new Bitmap(new BitmapData(100, 100));
			bm.name = "avatar";
			bm.bitmapData.perlinNoise(40, 60, 4, 4, true, false);
			bm.x = 2;
			bm.y = 2;
			sp.addChild(bm);

      var tx:TextField = new TextField();
			tx.name = "jid";
			tx.defaultTextFormat = _format;
      tx.text = item.jid.bareJID;
			tx.multiline = true;
			tx.wordWrap = true;
      tx.x = 104;
      tx.y = 2;
			tx.width = 170;
      sp.addChild(tx);

			drawBoxBackground(sp);

	    sp.addEventListener(MouseEvent.MOUSE_OVER, onMouse);
	    sp.addEventListener(MouseEvent.MOUSE_OUT, onMouse);
	    sp.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
	    sp.addEventListener(MouseEvent.MOUSE_UP, onMouse);
			sp.addEventListener(MouseEvent.CLICK, onMouse);
			return sp;
        }

		private function drawBoxBackground(sp:Sprite, color:uint = 0x3A3A3A):void
		{
      var gr:Graphics = sp.graphics;
			gr.clear();
      gr.beginFill(color);
      gr.lineStyle(1, 0x1A1A1A);
      gr.drawRoundRect(0, 0, sp.width + 4, sp.height + 4, 8, 8);
      gr.endFill();
		}

		private function updateUserBox(item:VCard):void
		{
			var loader:Loader = new Loader();
			loader.name = item.jid.bareJID;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAvatarLoaderComplete);
			loader.loadBytes(item.photo.bytes);
		}

		private function onAvatarLoaderComplete(event:Event):void
		{
			var info:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = info.loader;

			var sp:Sprite = _rosterCont.getChildByName(loader.name) as Sprite;
			if (sp != null)
			{
				var bm:Bitmap = sp.getChildByName("avatar") as Bitmap;
				if (bm != null)
				{
					// Wanna get a square
					var scale:Number = Math.max(bm.width / loader.width, bm.height / loader.height);
					var mat:Matrix = new Matrix();
					mat.scale(scale, scale);
					mat.tx = bm.width - scale * loader.width;
					mat.ty = bm.height - scale * loader.height;
					trace("onAvatarLoaderComplete. mat: " + mat);

					try
					{
						// Security violation if running standalone...
						bm.bitmapData.draw(loader, mat);
					}
					catch (error:SecurityError)
					{
						trace("SecurityError on image drawing: " + error.getStackTrace());
					}
					finally
					{
						loader.transform.matrix = mat;
						sp.addChild(loader);
					}
				}
			}
		}

    private function onVCard(event:VCardEvent):void
		{
      trace("onVCard. " + event.toString());
			if ((event.type == VCardEvent.LOADED || event.type == VCardEvent.SAVED)
				&& event.vcard.photo != null)
			{
				updateUserBox(event.vcard);
			}
			else if (event.type == VCardEvent.SAVE_ERROR)
			{
				// Triggered only by _vCardSent in VCard.
				trace("onVCard. SAVE_ERROR. " + event.vcard);
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
					visualiseRoster();
          break;
        case RosterEvent.USER_ADDED :
          break;
        }
    }

    private function onMouse(event:MouseEvent):void
		{
      var sp:Sprite = event.target as Sprite;
			var color:uint = 0x3A3A3A;
			if (event.type == MouseEvent.MOUSE_OVER)
			{
				color = 0x9A9A9A;
				_rosterCont.swapChildren(sp, _rosterCont.getChildAt(_rosterCont.numChildren - 1));
      }
			else if (event.type == MouseEvent.MOUSE_DOWN)
			{
				color = 0x121212;
				sp.startDrag();
			}
			else if (event.type == MouseEvent.MOUSE_UP)
			{
				color = 0x9A9A9A;
				sp.stopDrag();
			}
			else if (event.type == MouseEvent.CLICK)
			{
				if (sp.globalToLocal(new Point(mouseX, mouseY)).x < 100)
				{
					// Select new photo and send it for saving
					var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
					_fileRef.browse([imagesFilter]);
					_selectingPhotoForJid = sp.name;
				}
			}
			drawBoxBackground(sp, color);
    }

    private function onPhotoSelected(event:Event):void
		{
			_fileRef.load();
    }

		private function onFileLoaded(event:Event):void
		{
			// Save to VCard...

			var suffix:String = _fileRef.name.substring(_fileRef.name.lastIndexOf(".") + 1);
			if (suffix == "jpg")
			{
				suffix = "jpeg";
			}

			var photo:VCardPhoto = new VCardPhoto();
			photo.bytes = _fileRef.data;
			photo.type = "image/" + suffix;

			var vcard:VCard = _vcards[_selectingPhotoForJid] as VCard;
			vcard.photo = photo;

			var vcardExt:VCardExtension = vcard.createExtension();

			trace("vcardExt: " + vcardExt.toString());

			vcard.saveVCard(_connection);
		}

		private function onFileReferenceError(event:SecurityErrorEvent):void
		{
			trace("SecurityErrorEvent");
		}

		private function onFileReferenceIOError(event:IOErrorEvent):void
		{
			trace("IOErrorEvent");
		}

  	private function onKeepAliveLoop(event:TimerEvent):void
		{
			_connection.sendKeepAlive();
    }

		private function onStatTimer(event:TimerEvent):void
		{
			if (_connection != null)
			{
				_statField.text = "Incoming: " + Math.round(_connection.incomingBytes / 1024) + " KB\n"
					+ "Outgoing: " + Math.round(_connection.outgoingBytes / 1024) + " KB";
			}
		}

    private function onLogin(event:LoginEvent):void
		{
      trace("onLogin. " + event.toString());
      _keepAlive.start();

			var presence:Presence = new Presence(null, _connection.jid.escaped, null, null, null, 1);
      _connection.send(presence);
    }

		private function onDisconnect(event:DisconnectionEvent):void
		{
      trace("onDisconnect. " + event.toString());
      _keepAlive.stop();
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
