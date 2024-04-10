return {
  environment = "local",
  reloader = {
    user = "reloader",
    password = "test",
  },
  modules = {
    test = {
      user = "test",
      password = "test",
      http = {
        port = 9011,
      },
      box = {
        listen = 3301,
        replication_synchro_quorum = "N/2 + 1",
        replication_synchro_timeout = 10,
        replication = { "test:test@localhost:3301" },
        election_mode = "candidate",
        memtx_use_mvcc_engine = false,
        read_only = false
      },
      dependencies = {}
    },
  }
}