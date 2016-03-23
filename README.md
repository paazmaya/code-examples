# Code Examples

> Code examples originally posted at paazmaya.fi or its predecessors


## [Actionscript](./actionscript/)

[Stories tagged with `actionscript` at paazmaya.fi](http://paazmaya.fi/tag-actionscript).

For compiling try to use [Flex SDK](http://flex.apache.org/).

Examples located in the `coordyexamples` directory require
[the `coordy` library](https://github.com/somerandomdude/coordy) to be available.

Examples located in the `gsexamples` directory require
[the `GreenSock-AS3` library](https://github.com/greensock/GreenSock-AS3) to be available.

Examples located in the `xiffexamples` directory require
[the `XIFF` library](https://github.com/igniterealtime/XIFF) to be available.

In addition to the above, few examples need the [PaperVision3D library](https://code.google.com/p/papervision3d/)

```sh
find . -maxdepth 3 -type f -name '*.as' -printf '\n%h\n' \
 -exec sh -c 'mxmlc -target-player=11.1.0 -source-path=. {}' ';'
```

Make sure to have any player version specific SWC files available, copied as
`frameworks/libs/player/<version.major>.<version.minor>/playerglobal.swc`, and
can be downloaded from:

```
http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_2.swc
http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal10_3.swc
http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal11_1.swc
http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal12_0.swc
http://download.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal13_0.swc
```

Sometimes there might be a need to get a version which is not yet released, which
are usually available at
[Adobe Labs](http://labs.adobe.com/technologies/flashruntimes/flashplayer/).

Might need a `crossdomain.xml` file in the root of the web server:

```xml
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="master-only"/>
  <allow-access-from domain="*" to-ports="*"/>
  <allow-http-request-headers-from domain="*" headers="*" />
</cross-domain-policy>
```

Colors used in the examples are mostly from [Kuler: shark wrangler](https://color.adobe.com/shark-wrangler-color-theme-425255/).

```
0x042836 background
0x8B8C7D borders
0xE3E3C9 buttons text color, borders, bg for fields
0xFFFEE7
0x961D18 button bg, field borders

0x121212 black used for text color when not a button.
```


## [C++, Qt and QML](./cpp-qt-qml/)

[Stories tagged with `qt` at paazmaya.fi](http://paazmaya.fi/tag-qt) and
[stories tagged with `qml` at paazmaya.fi](http://paazmaya.fi/tag-qml).

Some of the QML examples need Qt 4.7 with some experimental plugins from Qt Labs (that does not
exist any more) while others use Qt 5, but have no been tested after 5.1 came out.

## [JavaScript](./javascript/)

[Stories tagged with `javascript` at paazmaya.fi](http://paazmaya.fi/tag-javascript).

## License

MIT and http://creativecommons.org/licenses/by-sa/4.0/
