final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src = prev.fetchurl {
      url = "https://download.scdn.co/SpotifyARM64.dmg";
      sha256 = "sha256-x9lpcQI1kZc4OIvQBhKXmI7t/2DIDbzufZhpNCKTxPA=";
    };
  });
}