{ lib, pkgs, ... }:

let
  # eMudhra mitigation: https://github.com/NixOS/nixpkgs/issues/576485
  # nix-darwin blacklists these roots in /etc/ssl/certs (nix-darwin#1876), but
  # determinate-nixd regenerates /etc/nix/macos-keychain.crt (the daemon's
  # ssl-cert-file) from the macOS root keychain. Strip the same roots from it,
  # matched by subject CN (the keychain names "Comodo AAA Services root"
  # "AAA Certificate Services").
  blacklistedCNs = [
    "AAA Certificate Services"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

  stripKeychainCAs = pkgs.writeShellApplication {
    name = "strip-keychain-cas";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.openssl
    ];
    text = ''
      file="''${1:-/etc/nix/macos-keychain.crt}"
      [ -f "$file" ] || exit 0
      blocked=(${lib.escapeShellArgs blacklistedCNs})

      tmp=$(mktemp "$file.XXXXXX")
      trap 'rm -f "$tmp"' EXIT
      removed=()
      cert=""
      in_cert=0
      while IFS= read -r line || [ -n "$line" ]; do
        if [ "''${line%$'\r'}" = "-----BEGIN CERTIFICATE-----" ]; then
          in_cert=1
          cert=""
        fi
        if [ "$in_cert" = 0 ]; then
          printf '%s\n' "$line" >>"$tmp"
          continue
        fi
        cert+="$line"$'\n'
        [ "''${line%$'\r'}" = "-----END CERTIFICATE-----" ] || continue
        in_cert=0
        cn=$(printf '%s' "$cert" | tr -d '\r' | openssl x509 -noout -subject -nameopt multiline | sed -n 's/^ *commonName *= //p')
        for b in "''${blocked[@]}"; do
          if [ "$cn" = "$b" ]; then
            removed+=("$cn")
            continue 2
          fi
        done
        printf '%s' "$cert" >>"$tmp"
      done <"$file"

      [ "''${#removed[@]}" -gt 0 ] || exit 0
      chmod 0644 "$tmp"
      mv -f "$tmp" "$file"
      trap - EXIT
      printf 'removed from %s: %s\n' "$file" "''${removed[*]}"
    '';
  };
in
{
  # Re-strip whenever determinate-nixd rewrites the file (on start and upgrade).
  launchd.daemons.strip-keychain-cas.serviceConfig = {
    ProgramArguments = [ (lib.getExe stripKeychainCAs) ];
    WatchPaths = [ "/etc/nix" ];
    RunAtLoad = true;
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    ${lib.getExe stripKeychainCAs}
  '';

  environment.etc = {
    "nix/nix.custom.conf" = {
      knownSha256Hashes = [
        "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"
      ];
      text = ''
        # Parallel evaluation (developer preview)
        # Parallelizes nix eval, nix flake check, nix flake show, etc.
        # Set to 0 to use all cores, 1 to disable
        eval-cores = 0

        # Numtide binary cache
        extra-substituters = https://cache.numtide.com
        extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
      '';
    };

    "determinate/config.json".text = builtins.toJSON {
      garbageCollector = {
        strategy = "automatic";
      };
      builder = {
        state = "enabled";
        memoryBytes = 8589934592; # 8 GiB
        cpuCount = 1;
      };
    };
  };
}
