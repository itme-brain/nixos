let
  daemonDir = "/var/lib/bitcoin";

in
''
  network = "bitcoin"

  electrum_rpc_addr = "127.0.0.1:50001"

  cookie-file = "${daemonDir}/.cookie"

  db_dir = "/var/lib/electrs/db"

  log_filters = "INFO"
  timestamp = true

  daemon-rpc-addr = "127.0.0.1:8332"
  daemon-p2p-addr = "127.0.0.1:8333"
  daemon-dir = "${daemonDir}"
''
