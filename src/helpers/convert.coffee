import { encode as decodeUTF8, decode as encodeUTF8 } from "@dashkite/utf8"
import { decode as decodeBase64, encode as encodeBase64 } from "@dashkite/base64"

fromJSON = (json) -> JSON.parse json
toJSON = (value) -> JSON.stringify value

Encoders =
  bytes: Fn.identity
  base64: encodeBase64
  json: Fn.pipe [ encodeUTF8, toJSON ]
  utf8: encodeUTF8

Decoders =
  bytes: Fn.identity
  base64: decodeBase64
  json: Fn.pipe [ fromJSON, UInt8Array.from ]
  utf8: decodeUTF8

convert = Fn.curry ({ from, to }, value) -> ( Encoders[ to ] ( Decoders[ from ] value ) )

export { convert }