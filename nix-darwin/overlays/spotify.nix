final: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      prev.fetchurl {
        url = "https://web.archive.org/web/20250707084518/https://download.scdn.co/SpotifyARM64.dmg";
        sha256 = "1cwfxlg4vzd4v2agp4xgsgnyj5jrxyf1i9c7gciq0v2wihrpzqka";
      }
    else
      oldAttrs.src;
  });
}