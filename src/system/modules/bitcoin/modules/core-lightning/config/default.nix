{ home, ... }:

''
###
##        Core Lightning Configurations
###
##  Edit this file to your desired configurations
##        Edit this files name to `config`
###
##    To view all documentation & options run:
##          `man lightningd config`
###

#
#               General Settings
#

# Give your node a name
alias=SnooPingasUsual
# Pick your favorite color as a hex code
rgb=FFFF00

# Set the network for Core Lightning to sync to, Bitcoin Mainnet for most users
# Omit this field if the config file is in a network directory such as `.lightning/bitcoin`
network=bitcoin

# Run `lightningd` as a background daemon
# Omit to run `lighntningd` in the console
# Requires `log-file` path specified
daemon

# Omit this field for log output in the console.
log-file=${home}/log
# Set to debug for more verbose output
log-level=info

# Uncomment `encrypted-hsm` to password encrypt your `hsm_secret`
# You must supply the password on startup if you choose to do this
#encrypted-hsm

experimental-onion-messages
experimental-offers


#
#               Networking Settings
#

# INBOUND connections on default PORT 9735 | 0.0.0.0 for clearnet, localhost+torhiddenservice for tor
addr=127.0.0.1:9735
# Peers can find your tor address here
announce-addr=
# Bind Core Lightning RPC server to localhost PORT 9734
bind-addr=127.0.0.1:9734
# Configure proxy/tor for OUTBOUND connections. Omit if not using a proxy/tor
proxy=127.0.0.1:9050
# Force all outbound connections through the proxy/tor
always-use-proxy=true


#                 Channel Settings
# !! Please read the manual before editing these !!
# !!  and for a full list of available options   !!

# Removes capacity limit for channel creation
large-channels
# Base fee to charge for every payment which passes through in MILLISATOSHI (1/1000 of a satoshi)
fee-base=0
# In millionths (10 is 0.001%, 100 is 0.01%, 1000 is 0.1% etc.)
fee-per-satoshi=0
# Minimum value, in SATOSHI, to accept for channel open requests
min-capacity-sat=10000
# Sets the minimum HTLC value for new channelsi
htlc-minimum-msat=1000000
# Blockchain confirmations required for channel to be considered valid
funding-confirms=3
# Max number of HTLC channels can handle in each direction
max-concurrent-htlcs=30


#   Plugins allow you to extend Core Lightnings functionality
# They can be loaded on startup by creating a `plugins` directory
#     Or individually loaded with `plugin=/path/to/plugin`
#
#       For a community curated list of plugins visit:
#         "https://github.com/lightningd/plugins"

plugin-dir=${home}/plugins
''
