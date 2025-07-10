final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      prev.fetchurl {
        url = "https://download.scdn.co/SpotifyARM64.dmg";
        sha256 = "0rjjm1al8alkdvkrwg328wcya97kqcyh4mamzlif5872vrs1wy4n";
      }
    else
      oldAttrs.src;
  });
}