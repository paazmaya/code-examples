# Code Examples

> Code examples originally posted at paazmaya.fi or its predecessors


## Actionscript

For compiling try to use Flex SDK

Might need a `crossdomain.xml` file in the root of the server:

```xml
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="master-only"/>
  <allow-access-from domain="*" to-ports="*"/>
  <allow-http-request-headers-from domain="*" headers="*" />
</cross-domain-policy>
```

Colors used in the examples are mostly from [Kuler: shark wrangler](http://kuler.adobe.com/#themeID/425255).

```
0x042836 background
0x8B8C7D borders
0xE3E3C9 buttons text color, borders, bg for fields
0xFFFEE7
0x961D18 button bg, field borders

0x121212 black used for text color when not a button.
```



## JavaScript


## License

MIT and http://creativecommons.org/licenses/by-sa/4.0/
