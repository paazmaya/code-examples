/**
 * @mxmlc -target-player=11 -source-path=. -debug
 */
package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
    import flash.utils.Timer;
	import flash.system.Security;
    import flash.ui.Keyboard;
	import flash.xml.*;
	
	import org.igniterealtime.xiff.util.*;

	[SWF(backgroundColor = '0x11262B', frameRate = '33', width = '400', height = '200')]

	/**
	 * Test the stream compression of XIFF
	 */
    public class ZlibCompressionTest extends Sprite
	{
		private var _compressor:Zlib;
		private var _compressor2:Zlib2;
		
		private var streamOpenClient:String = "78da54ce410e82301085e1ab34b3776a35516c28ec3c811ea0e0046a604ada89e1f8a275e36a36ff973775bbce937a51ca21b203837b50c47d7c041e1cdc6fd75d056d536749e4675b8eda0867074fdf75946c3f0562012571f397039a5385068f6728dd0f39184516ab35c94869c58231a64197207f7b3bf9cf3031fc3fd5bc010000ffff";
		
		private var streamOpenServer:String = "78da8c90514f83301485ff0ab92f3c41658b6e36c0429c9a25b219b73df8d8c1056aa0605bcc7ebe45c646344b7cba6dcf39f77ebdfee25895d6174ac56b11d89e7b635b28923ae5220fecfdeec999db8bd0575a22ab685f2c1311ea7409a0d0baa184a02e501edd0f7638a0746b9993dea0a0f707d04b3429390a0d56266b93f6ee27ae7737773d773a038ba701a0974ea6e98cfde468c90c08a08033241848382365c8742b51857e8549c10457951a06b652508e3aa30d93068476fd44579ac6514c95300a85cbd5f3e376e7c4cb5b9f5c5e4786d79768b5bea245ebcdfa3ddeecb757f487b728fed3fa7236f4acd5c5c07ddae86895c32f09ff743a2790d0979873a551fe2f35b8bb24f9bdbb6f000000ffff";
		
		private var streamOpenFlash:String = "78da558e4de82301085afd2ccdea9d544b1a1b0f347a808213a88129692786e38bd68dab97bc7cefa76ed779522f4a3944766070f8ab88f8fc08383fbedbaaba06dea2c89fc6c8ba82dc2d9c1d3771d25db4f8158a0b83fc4c128b258ad49464a2b1614631a741322889dbdee580e654a1c1e3f9db6027ff192686ff53cd1b137037ee";
		
		private var streamOpenXml:String = '<?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" to="192.168.1.37" xml:lang="en" version="1.0">';
		
        public function ZlibCompressionTest()
		{
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

			loaderInfo.addEventListener(Event.INIT, onInit);
		}
		
		private function onInit(event:Event):void
		{
			_compressor = new Zlib();
			_compressor2 = new Zlib2();
			
			var testString:String = "Hello there! Get your hand off me you dirty ape! Who said that? Anyone?";

			/*
			var ba:ByteArray = new ByteArray();
			ba = Hex.writeBytes(ba, streamOpenServer);
			trace("-------- Openfire");
			readZlibInfo(ba);
			*/
			
			var baZlib:ByteArray = new ByteArray();
			baZlib.writeUTFBytes(testString);
			baZlib = _compressor.compress(baZlib);
			trace("-------- JZlib. Endian: " + baZlib.endian);
			readZlibInfo(baZlib);
			
			var baZlib2:ByteArray = new ByteArray();
			baZlib2.writeUTFBytes(testString);
			baZlib2 = _compressor2.compress(baZlib2);
			trace("-------- JZlib another. Endian: " + baZlib2.endian);
			readZlibInfo(baZlib2);
			
			//ba.uncompress(CompressionAlgorithm.ZLIB);
			//trace("uncompress ba: " + ba.readUTFBytes(ba.length));
			
			var baFlashNative:ByteArray = new ByteArray();
			baFlashNative.writeUTFBytes(testString);
			baFlashNative.compress(CompressionAlgorithm.ZLIB); // makes it bigEndian....
			trace("-------- Native Flash 10: compress(CompressionAlgorithm.ZLIB). Endian: " + baFlashNative.endian);
			readZlibInfo(baFlashNative);
			
			


			/*
			var baUn:ByteArray = _compressor.uncompress(ba);
			trace("baUn: " + baUn.toString());
			
			var baUn2:ByteArray = _compressor2.uncompress(ba);
			trace("baUn2: " + baUn2.toString());
			*/
			
			
			// streamOpenClient
			// <?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" to="192.168.1.37" xmlns:stream="http://etherx.jabber.org/s

			// streamOpenServer
			// <?xml version='1.0' encoding='UTF-8'?><stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" from="192.168.1.37" id="e1d23d7a" xml:lang="en" version="1.0"><stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>DIGEST-MD5
			
			// streamOpenFlash
			// <?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" to="192.16

			/*
			
			var baOut:ByteArray = new ByteArray();
			baOut.writeUTFBytes(streamOpenXml);
			var baOutCo:ByteArray = _compressor.compress(baOut);
			trace("baOutCo: " + Hex.readBytes(baOutCo));
			
			
			var baOutCoUn:ByteArray = _compressor.uncompress(baOutCo);
			trace("baOutCoUn: " + baOutCoUn.toString());
			*/
			
			// streamOpenXml
			// baOutCoUn: <?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" to="192.16

			
			//readZlibInfo(baOutCo);
			
			// Z_DEFAULT_COMPRESSION
			// 789c558e4de82301085afd2ccdea9d544b1a1b0f347a808213a88129692786e38bd68dab97bc7cefa76ed779522f4a3944766070f8ab88f8fc08383fbedbaaba06dea2c89fc6c8ba82dc2d9c1d3771d25db4f8158a0b83fc4c128b258ad49464a2b1614631a741322889dbdee580e654a1c1e3f9db6027ff192686ff53cd1b137037ee
			
			// Z_BEST_COMPRESSION
			// 78da558e4de82301085afd2ccdea9d544b1a1b0f347a808213a88129692786e38bd68dab97bc7cefa76ed779522f4a3944766070f8ab88f8fc08383fbedbaaba06dea2c89fc6c8ba82dc2d9c1d3771d25db4f8158a0b83fc4c128b258ad49464a2b1614631a741322889dbdee580e654a1c1e3f9db6027ff192686ff53cd1b137037ee
			
			/*
			var helloText:String = "Hello there!";
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(helloText);
			trace("helloText in HEX: " + Hex.readBytes(data)); // 48656c6c6f20746865726521
			data.clear();
			data = Hex.writeBytes(data, "48656c6c6f20746865726521");
			data.position = 0;
			trace("HEX to string: " + data.readUTFBytes(data.length)); // Hello there!
			*/
			
			// Try to uncompress this
			// 78da54c84ba8020145d0ad3cee3cc5fe85ba97caa214dcba0761fd3bc3236da4f48459619d13c81a85b2edb2ab41cbb53105dce44dd32c18a694f6ff70639ad1c53d2d83f52bdd6ef3a7c275f8fe7621f45f826bc96dd42f000ffff
			// 78da54c84ba82145d0ad3cee3cc5fe85ba97caa214dcba761fd3bc3236da4f48459619d13c81a85b2edb2ab41cbb5315dce44dd32c18a694f6ff70639ad1c53d2d83f52bdd6ef3a7c275f8fe7621f45f826bc96dd42f0f24622f51
			var afterFailure:ByteArray = new ByteArray();
			afterFailure.endian = Endian.BIG_ENDIAN;
			writeBytes(afterFailure, "78da54c84ba8020145d0ad3cee3c7f5159a89be98790666560bb8f869de131fea0fca4d9629d33c84f165a88aa52de71e2c64af986c3593acee4079fff576a1c9b66eae04cf271a512b67859dc671c4a4869f812dc19eeff7200ffff");
			var calculate:ByteArray = new ByteArray();
			calculate.endian = Endian.BIG_ENDIAN;
			calculate.writeBytes(afterFailure, 2, afterFailure.length - 4);
			var adlerCalculated:uint = calculateAdler32(calculate);
			var resulted:ByteArray = new ByteArray();
			resulted.endian = Endian.BIG_ENDIAN;
			afterFailure.position = 0;
			resulted.writeBytes(afterFailure, 0, 2);
			calculate.position = 0;
			resulted.writeBytes(calculate, 0, calculate.length);
			resulted.writeUnsignedInt(adlerCalculated);
			
			resulted.position = 0;
			trace("resulted before: " + readBytes(resulted));
			resulted.position = 0;
			resulted.uncompress(CompressionAlgorithm.ZLIB);
			resulted.position = 0;
			trace("resulted: " + resulted.readUTFBytes(resulted.length));
		}
		
		/**
		 * Read zlib header and adler32
		 * @param	ba
		 * @see http://tools.ietf.org/html/rfc1950
		 */
		private function readZlibInfo(ba:ByteArray):void
		{
			ba.position = 0;
			ba.endian = Endian.BIG_ENDIAN;
			
			var cmf:uint = ba.readUnsignedByte();
			var flg:uint = ba.readUnsignedByte();
			
			// CMF (compression method and info)
			trace("readZlibInfo. CMF should be 0x78 : 0x" + cmf.toString(16) + ", binary: " + cmf.toString(2));
			trace("readZlibInfo. CMF.CM : " + cmf.toString(2).substring(0, 4)); // Compression method
			trace("readZlibInfo. CMF.CINFO : " + cmf.toString(2).substring(4, 8)); // Compression info
			
			// FLG (check bits, preset dict, compression level)
			trace("readZlibInfo. FLG might be be 0xda : 0x" + flg.toString(16) + ", binary: " + flg.toString(2));
			trace("readZlibInfo. FLG.FCHECK : " + flg.toString(2).substring(0, 5));
			trace("readZlibInfo. FLG.FDICT : " + flg.toString(2).substring(5, 6));
			trace("readZlibInfo. FLG.FLEVEL : " + flg.toString(2).substring(6, 8));
			
			// Adler32 checksum
			ba.position = Math.max(0, ba.length - 4);
			var adler32:uint = ba.readUnsignedInt(); // 32-bit
			trace("readZlibInfo. Adler32 : 0x" + adler32.toString(16));
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.BIG_ENDIAN;
			var lenHeader:uint = Math.min(24, ba.length);
			var lenAdler:uint = Math.min(24, ba.length);
			while (0 < lenAdler)
			{
				while (0 < lenHeader)
				{
					var dataLen:int = ba.length - (lenAdler + lenHeader);
					if (dataLen > 0)
					{
						data.clear();
						data.writeBytes(ba, lenHeader, dataLen);
						var calcA:uint = calculateAdler32(data);
						if (adler32 == calcA)
						{
							trace("calculated Adler32 : " + lenHeader + " " + lenAdler + " 0x" + calcA.toString(16));
						}
					}
					lenHeader--;
				}
				lenAdler--;
				lenHeader = Math.min(24, ba.length);
			}
			
		}
/*
-------- Openfire
readZlibInfo. CMF should be 0x78 : 0x78, binary: 1111000
readZlibInfo. CMF.CM : 1111
readZlibInfo. CMF.CINFO : 000
readZlibInfo. FLG might be be 0xda : 0xda, binary: 11011010
readZlibInfo. FLG.FCHECK : 11011
readZlibInfo. FLG.FDICT : 0
readZlibInfo. FLG.FLEVEL : 10
readZlibInfo. Adler32 : 0xffff0000
-------- Native Flash 10: compress(CompressionAlgorithm.ZLIB)
readZlibInfo. CMF should be 0x78 : 0x78, binary: 1111000
readZlibInfo. CMF.CM : 1111
readZlibInfo. CMF.CINFO : 000
readZlibInfo. FLG might be be 0xda : 0xda, binary: 11011010
readZlibInfo. FLG.FCHECK : 11011
readZlibInfo. FLG.FDICT : 0
readZlibInfo. FLG.FLEVEL : 10
readZlibInfo. Adler32 : 0x4e04b41c
*/

		/**
		 * http://en.wikipedia.org/wiki/Adler-32#Example_implementation
		 * @param	data
		 * @return
		 */
		private function calculateAdler32(data:ByteArray):uint
		{
			var modAdler:uint = 65521;

			data.position = 0;
			var a:uint = 1;
			var b:uint = 0;
			var len:uint = data.length;
			for (var index:uint = 0; index < len; ++index)
			{
				a = (a + data.readUnsignedByte()) % modAdler;
				b = (b + a) % modAdler;
			}
			return (b << 16) | a;
		}
		
		/**
		 * Write the given hex string to the bytearray
		 *
		 * @param	ba
		 * @param	byteStr
		 * @return
		 */
		private function writeBytes(ba:ByteArray, hex:String):ByteArray
		{
			ba.position = ba.length;
			var len:uint = hex.length;
			trace("writeBytes. len: " + len);
			for (var i:uint = 0; i < len; i += 2)
			{
				var byte:uint = uint("0x" + hex.substr(i, 2));
				ba.writeByte(byte);
			}
			return ba;
		}
		
		/**
		 * Read the bytes of the given bytearray and convert to a hex string
		 *
		 * @param	ba
		 * @param	byteStr
		 * @return
		 */
		private function readBytes(ba:ByteArray):String
		{
			var hex:String = "";
			ba.position = 0;
			var len:uint = ba.length;
			trace("readBytes. len: " + len);
			for (var i:uint = 0; i < len; ++i)
			{
				var byte:uint = ba.readUnsignedByte();
				//trace("readBytes. byte " + i + ": " + byte + " -- " + byte.toString(16));
				hex += byte.toString(16).substr(-2);
			}
			return hex;
		}
	}
}


//
