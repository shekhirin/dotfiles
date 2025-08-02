final: prev: {
  signal-desktop-bin = prev.signal-desktop-bin.overrideAttrs (oldAttrs: {
    version = "7.62.0";
    src = prev.fetchurl {
      url = "https://updates.signal.org/desktop/signal-desktop-mac-universal-7.62.0.dmg";
      sha256 = "1lifvx599ab44dw9njigj5iw89yri5wrdn1i5b5qzx9s9968zgqp";
    };
  });
}
