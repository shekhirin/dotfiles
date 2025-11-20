_:

{
  # Tempo service for distributed tracing
  services.tempo = {
    enable = true;

    settings = {
      server = {
        http_listen_port = 3200;
        grpc_listen_port = 3201;
      };
      distributor.receivers.otlp.protocols.grpc.endpoint = "127.0.0.1:4317";
      storage = {
        trace = {
          backend = "local";
          local = {
            path = "/var/lib/tempo";
          };
          wal = {
            path = "/var/lib/tempo/wal";
          };
        };
      };
    };
  };
}
