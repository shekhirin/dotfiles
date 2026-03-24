{
  aerospaceVersion ? "0.0.0-npv12",
  aerospaceRev ? "16edd0854d7780c679baa4067ca5ef3d0438d9f0",
  aerospaceHash ? "sha256-M50QQY8tkqwtLo+ivbR4P3xWssTXJL7nLNbqn1vdaRE=",
}:
final: prev:
let
  src = prev.fetchFromGitHub {
    owner = "npv12";
    repo = "AeroSpace";
    rev = aerospaceRev;
    hash = aerospaceHash;
    fetchSubmodules = true;
  };
in
{
  aerospace = prev.runCommand "aerospace-${aerospaceVersion}" {
    __noChroot = true;

    meta = {
      description = "i3-like tiling window manager for macOS (npv12 fork)";
      homepage = "https://github.com/npv12/AeroSpace";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.darwin;
      mainProgram = "aerospace";
    };
  } ''
    export PATH="/usr/bin:/usr/sbin:/bin:$PATH"
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    export SDKROOT="$(/usr/bin/xcrun --show-sdk-path)"
    export HOME="$TMPDIR"

    cp -r ${src} src
    chmod -R u+w src
    cd src

    # Generate version and git hash files
    cat > Sources/Common/versionGenerated.swift <<SWIFT
    public let aeroSpaceAppVersion = "${aerospaceVersion}"
    SWIFT

    cat > Sources/Common/gitHashGenerated.swift <<SWIFT
    public let gitHash = "${aerospaceRev}"
    public let gitShortHash = "${builtins.substring 0 7 aerospaceRev}"
    SWIFT

    # Generate subcommand descriptions
    {
      echo "let subcommandDescriptions = ["
      for file in docs/aerospace-*.adoc; do
        if echo "$file" | grep -q 'exec-and-forget'; then continue; fi
        subcommand=$(basename "$file" | sed 's/^aerospace-//' | sed 's/\.adoc$//')
        desc="$(grep :manpurpose: "$file" | sed -E 's/:manpurpose: //' || true)"
        echo "    [\"  $subcommand\", \"$desc\"],"
      done
      echo "]"
    } > Sources/Cli/subcommandDescriptionsGenerated.swift

    # Build CLI (disable Swift PM's own sandbox which fails under nix build users)
    /usr/bin/swift build -c release --arch arm64 --product aerospace --disable-sandbox

    # Build .app via xcodebuild (requires full Xcode)
    /usr/bin/xcrun xcodebuild \
      clean build \
      -scheme AeroSpace \
      -destination "generic/platform=macOS" \
      -configuration Release \
      -derivedDataPath .xcode-build \
      CODE_SIGN_IDENTITY="-" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO

    # Install
    mkdir -p $out/Applications
    cp -r .xcode-build/Build/Products/Release/AeroSpace.app $out/Applications/

    mkdir -p $out/bin
    cp .build/apple/Products/Release/aerospace $out/bin/

    # Ad-hoc sign
    /usr/bin/codesign -s - $out/bin/aerospace 2>/dev/null || true
  '';
}
