require 'util.sh'
require 'util.oci'
require 'util.dump'
json = require 'dkjson'

-- get compartment-id & availability-domain
local res = oci 'iam availability-domain list'
local compartmentid = res["compartment-id"]
local availdomain   = res.name

-- get public ip address
res = oci('network public-ip list',
          '--compartment-id', compartmentid,
          '--scope AVAILABILITY_DOMAIN',
          '--availability-domain', availdomain,
          '--lifetime', 'EPHEMERAL')
local publicip = res['ip-address']

local cmd    = "curl --insecure --key $HOME/.oci/oci_api_key.pem sftp://ubuntu@%s/etc/shadowsocks-rust/config.json"
local config = shout(cmd:format(publicip))
config = assert(json.decode(config))
dump(config)
