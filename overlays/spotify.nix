final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src = prev.fetchurl {
      url = "https://download.scdn.co/SpotifyARM64.dmg";
      sha256 = "sha256-bs+rSMfIFG0FyHGDUtuk6tSbd5l6r6qUNH20hQQjZC0=";
    };
  });
}
