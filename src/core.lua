-- Compatibility shim: require('titogramlua.core') now forwards to require('titogramlua')
io.stderr:write('[titogramlua] DEPRECATED: require("titogramlua.core") is deprecated, use require("titogramlua") instead\n')
return require('titogramlua')
