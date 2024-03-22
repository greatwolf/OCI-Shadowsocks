#!/usr/bin/env lua
require 'sh'

-- download base64 and json lua libraries
sh 'wget -O base64.lua https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua'
sh 'wget -O dkjson.lua http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=6c6486a4a589ed9ae70654a2821e956650299228'

-- Install OCI
sh 'wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh'
sh 'bash install.sh --accept-all-defaults'

sh 'mkdir -p ~/.oci'

-- Copy OCI config to right place
sh 'cp ./config ~/.oci/'

-- Copy OCI ssh privatekey auth to right place
json = require 'dkjson'
local jsonsecrets = assert( os.getenv "JSON_SECRETS" )
jsonsecrets = json.decode(jsonsecrets)

b64 = require 'base64'
for file, payload in pairs(jsonsecrets) do
  file = assert( io.open(file, 'wb') )
  file:write(b64.decode(payload))
end
