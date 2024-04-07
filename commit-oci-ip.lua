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

-- get the compute instance's port(usually 443) and shadowsocks password
local cmd    = "curl --insecure --key $HOME/.oci/oci_api_key.pem sftp://ubuntu@%s/etc/shadowsocks-rust/config.json"
local config = shout(cmd:format(publicip))
config = assert(json.decode(config))

local ip    = res['ip-address']
local port  = config.server_port
local userinfo  = b64.encode(config.method .. ':' .. config.password)
local prefix    = "%16%03%01%00%C2%A8%01%01" -- TLS ClientHello	
local ss_uri    = string.format("ss://%s@%s:%d/?outline=1&prefix=%s", userinfo, ip, port, prefix)

local urimsg = table.concat
{
  '\27[33;92m',
  [[
    -================================================================================================-
    |  Shadow Socks SIP002 URI:                                                                      |
    |    %-91.91s |
    -================================================================================================-
  ]],
  '\27[33;0m'
}
print(urimsg:format(ss_uri))

-- commit updated ip to repo
local file = assert(io.open('./oci-osaka.txt', 'wb'))
file:write(urimsg)
file:close()

sh 'git status'
sh 'git commit -m "Updated oci public ip"'
