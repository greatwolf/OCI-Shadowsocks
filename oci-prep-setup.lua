#!/usr/bin/env lua
require 'util.sh'

-- download base64 and dkjson for lua
sh 'sudo wget --directory-prefix=/usr/local/share/lua/5.4 https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua'
sh 'sudo wget -O /usr/local/share/lua/5.4/dkjson.lua http://dkolf.de/dkjson-lua/dkjson-2.7.lua'

-- Install OCI-CLI
sh
[[
  wget -NO - \
  https://github.com/oracle/oci-cli/releases/download/v3.45.0/oci-cli-3.45.0.zip | jar x
]]
sh 'pip3 install ./oci-cli/oci_cli-3.45.0-py3-none-any.whl'

-- Copy OCI config to right place
dofile 'oci-config-swap.lua'

-- Set user and email for git
sh 'git config --global user.name "greatwolf"'
sh 'git config --global user.email "github.greatwolf@mamber.net"'

-- Copy OCI ssh privatekey auth to right place
json = require 'dkjson'
local secret_env  = sh.env "OCI_SECRETS"
local secret_file = io.open '/content/drive/MyDrive/OCI_SECRETS'
if secret_file then
  secret_file = secret_file:read '*all'
end
local ocisecrets = assert(secret_env or secret_file, "Could not find OCI_SECRETS")
ocisecrets = assert(json.decode(ocisecrets), "Could not parse OCI_SECRETS")

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
