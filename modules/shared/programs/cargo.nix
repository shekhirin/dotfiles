_:

{
  # Set via env instead of ~/.cargo/config.toml: a home-manager symlink there
  # breaks tools that edit the file in place (e.g. Aegis).
  home.sessionVariables.CARGO_NET_GIT_FETCH_WITH_CLI = "true";
}
