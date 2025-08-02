final: prev: {
  # Notion overlay to fix auto-update issues
  # TODO: Remove this overlay once https://github.com/nix-community/nixpkgs-update/issues/468 is resolved
  # and auto-update works properly in nixpkgs
  notion-app = prev.notion-app.overrideAttrs (oldAttrs: {
    version = "4.15.3";
    src = prev.fetchurl {
      url = "https://desktop-release.notion-static.com/Notion-4.15.3-universal.dmg";
      sha256 = "sha256-Go8g7s3vupw5ep+NOh9StJ2gaGKe38oICaJO+x/kPUk=";
    };
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.undmg ];
  });
}
