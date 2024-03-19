#!/usr/bin/env lua
require 'sh'

-- download base64 and json lua libraries
sh 'wget -O base64.lua https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua'
sh 'wget -O dkjson.lua http://dkolf.de/src/dkjson-lua.fsl/raw/dkjson.lua?name=6c6486a4a589ed9ae70654a2821e956650299228'

-- Install OCI
sh 'wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh'
sh 'bash install.sh --accept-all-defaults'

print(os.getenv "JSON_SECRETS")
