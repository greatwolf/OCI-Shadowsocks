require 'util.sh'
require 'util.oci'
require 'util.dump'

b64   = require 'base64'
json  = require 'dkjson'

-- get compartment-id & availability-domain
local iam = table.remove(oci 'iam availability-domain list')
local compartmentid = iam["compartment-id"]
local availdomain   = iam.name

-- filter out servers not running Shadowsocks
local instances = oci('compute instance list-vnics',
                      '--compartment-id', compartmentid)
                  :filter(function(v)
                    return  v['public-ip'] and v['display-name']:match '^Shadowsocks'
                  end)

-- get compute instance's shadowsocks config
local ss_uri  = instances
                :map(function(v)
                  local ip = v['public-ip']
                  local cmd = "curl -s --insecure --key $HOME/.oci/oci_api_key.pem sftp://ubuntu@%s/etc/shadowsocks-rust/config.json"
                  local config = shout(cmd:format(ip))
                  config = assert(json.decode(config))
                  config.ip = ip
                  return config
                end)
                :map(function(config)
                  -- encode SIP002 URI
                  local port  = config.server_port
                  local userinfo  = b64.encode(config.method .. ':' .. config.password)
                  local prefix    = "%16%03%01%00%C2%A8%01%01" -- TLS ClientHello

                  return string.format("ss://%s@%s:%d/?outline=1&prefix=%s", userinfo, config.ip, port, prefix)
                end)

-- write SIP002 URI to file and print to stdout
local file = assert(io.open('./oci-osaka.txt', 'wb'))
local urimsg = table.concat
{
  '\27[33;92m',
  [[
    -================================================================================================-
    Shadow Socks SIP002 URI:
    %-s
    -================================================================================================-
  ]],
  '\27[33;0m'
}
ss_uri = table.concat(ss_uri, '\n')
print(urimsg:format(ss_uri))
file:write(ss_uri)
file:close()

-- commit updated ip to repo
sh 'git status'
sh 'git add *.txt'
sh 'git commit -m "Updated oci public ip"'
sh 'git push'
