#!/usr/bin/env lua
require 'sh'

-- download base64 and json lua libraries
sh 'wget -O base64.lua https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua'
sh 'wget -O dkjson.lua http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=6c6486a4a589ed9ae70654a2821e956650299228'

-- Install OCI
sh 'wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh'
sh 'bash install.sh --accept-all-defaults'

-- Copy OCI config to right place
sh 'mkdir -p ~/.oci'
sh 'cp ./config ~/.oci/'
sh 'chmod 600 ~/.oci/config'  -- tighten permissions so oci doesn't complain

-- Copy OCI ssh privatekey auth to right place
json = require 'dkjson'
local ocisecrets = assert(json.decode(os.getenv "OCI_SECRETS"))

-- Replace '~' with HOME directory
function expandhome(secrets)
  local home = sh.env "HOME"
  local files = {}
  for f, payload in pairs(secrets) do
    local file = f:gsub("^~", home)
    files[file] = payload
  end
  return files
end
ocisecrets = expandhome(ocisecrets)

-- Write output files from CI secrets
b64 = require 'base64'
for f, payload in pairs(ocisecrets) do
  file = assert( io.open(f, 'wb') )
  file:write(b64.decode(payload))
  file:close()
  sh('chmod 600 ' .. f)
end
