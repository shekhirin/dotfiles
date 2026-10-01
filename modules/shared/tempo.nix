{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system isDarwin isLinux;

  platform =
    {
      aarch64-darwin = {
        target = "aarch64-apple-darwin";
        hash = "sha256-fWexmMY9Hp4NMxfDbpMDXcgHe/GKpKBcy43OHv+R/08=";
        wallet = "darwin-arm64";
        walletHash = "sha256-wBQs4UieQsA2b0/+L3zVQFgvHtiArzuPUonKij7eV0o=";
      };
      x86_64-linux = {
        target = "x86_64-unknown-linux-gnu";
        hash = "sha256-5MimrcRc1jpf/OCvWPXI3hGE2OMsRTY1d271wNLym7k=";
        wallet = "linux-amd64";
        walletHash = "sha256-IO2uBA4xrtE74XAZAVUehEgci7xAC8d8MKi5vAHhV5w=";
      };
    }
    .${system};

  tempo = pkgs.stdenv.mkDerivation rec {
    pname = "tempo";
    version = "1.15.0";
    walletVersion = "0.11.0";

    src = pkgs.fetchurl {
      url = "https://github.com/tempoxyz/tempo/releases/download/v${version}/tempo-v${version}-${platform.target}.tar.gz";
      inherit (platform) hash;
    };

    # `tempo wallet` dispatches to `tempo-wallet` next to the running binary.
    wallet = pkgs.fetchurl {
      url = "https://cli.tempo.xyz/extensions/tempo-wallet/v${walletVersion}/tempo-wallet-${platform.wallet}";
      hash = platform.walletHash;
    };

    sourceRoot = ".";
    # tempo-wallet is a Bun single-file executable with its payload appended to the binary.
    dontStrip = true;

    nativeBuildInputs =
      lib.optionals isDarwin [ pkgs.darwin.autoSignDarwinBinariesHook ]
      # wrapBuddy patches ELF binaries without rewriting their layout, which keeps Bun's payload intact.
      ++ lib.optionals isLinux [ inputs.llm-agents.packages.${system}.wrapBuddy ];

    buildInputs = lib.optionals isLinux [
      pkgs.stdenv.cc.cc.lib
      pkgs.systemdLibs
    ];

    installPhase = ''
      install -Dm755 tempo-v${version}-${platform.target} $out/bin/tempo
      install -Dm755 ${wallet} $out/bin/tempo-wallet
    ''
    # The darwin release links against Homebrew's libusb.
    + lib.optionalString isDarwin ''
      install_name_tool -change \
        /opt/homebrew/opt/libusb/lib/libusb-1.0.0.dylib \
        ${pkgs.libusb1}/lib/libusb-1.0.0.dylib \
        $out/bin/tempo
    '';
  };
in
{
  home.packages = [ tempo ];
}
