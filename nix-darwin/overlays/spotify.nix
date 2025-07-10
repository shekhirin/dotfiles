final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src = prev.fetchurl {
      url = "https://download.scdn.co/SpotifyARM64.dmg";
      sha256 = "0rjjm1al8alkdvkrwg328wcya97kqcyh4mamzlif5872vrs1wy4n";
    };
  });
}