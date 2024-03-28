#!/usr/bin/env lua
require 'sh'

-- download base64 and json lua libraries
sh 'sudo wget --directory-prefix=/usr/local/share/lua/5.4 https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua'
sh 'sudo wget -O $HOME/dkjson.lua http://dkolf.de/dkjson-lua/dkjson-2.7.lua'

-- Install OCI
sh 'wget --directory-prefix=$HOME https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh'
sh 'bash $HOME/install.sh --accept-all-defaults'

-- Copy OCI config to right place
sh 'mkdir -p ~/.oci'
sh 'cp ./config ~/.oci/'
sh 'chmod 600 ~/.oci/config'  -- tighten permissions so oci doesn't complain

-- Add "~/bin" to env PATH so oci's accessible
local GH_PATH = io.open(sh.env "GITHUB_PATH", 'ab')
GH_PATH:write(sh.env "HOME" .. "/bin")
GH_PATH:close()

-- Copy OCI ssh privatekey auth to right place
json = require 'dkjson'
local ocisecrets = assert(json.decode(sh.env "OCI_SECRETS"))

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
