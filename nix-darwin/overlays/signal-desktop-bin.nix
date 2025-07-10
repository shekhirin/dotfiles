final: prev: {
  signal-desktop-bin = prev.signal-desktop-bin.overrideAttrs (oldAttrs: {
    version = "7.61.0";
    src = prev.fetchurl {
      url = "https://updates.signal.org/desktop/signal-desktop-mac-universal-7.61.0.dmg";
      sha256 = "1n8y45y21cfwcmz27kqbhnkq3sa9vl5qyaxg4qdb3jp8kndpx6n1";
    };
  });
}