{ ... }:

{
  home.file.".cargo/config.toml".text = ''
    [net]
    git-fetch-with-cli = true
  '';
}
