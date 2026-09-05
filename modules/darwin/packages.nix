{ pkgs, ... }:

let
  openlogi = pkgs.openlogi.overrideAttrs (oldAttrs: {
    cargoBuildFlags = oldAttrs.cargoBuildFlags ++ [ "--package=openlogi-agent" ];

    postInstall = (oldAttrs.postInstall or "") + ''
      agent="$release_target/openlogi-agent"
      helper="$out/Applications/OpenLogi.app/Contents/Library/LoginItems/OpenLogiAgent.app/Contents"

      install -Dm755 "$agent" "$out/bin/openlogi-agent"
      install -Dm755 "$agent" "$helper/MacOS/openlogi-agent"
      install -Dm644 crates/openlogi-gui/bundle/agent-release/Info.plist "$helper/Info.plist"
      install -Dm644 crates/openlogi-gui/icon/AppIcon.icns "$helper/Resources/AppIcon.icns"

      substituteInPlace "$helper/Info.plist" \
        --replace-fail '<string>0.0.0</string>' '<string>${oldAttrs.version}</string>'
    '';
  });
in
{
  home.packages = [
    openlogi
    pkgs._1password-cli
  ];
}
