{ pkgs, lib, ... }:

let
  version = "2025.2";
  root = "/mnt/nvme/Xilinx/${version}/Vivado";
  launcher = pkgs.buildFHSEnv {
    name = "fpga-tools";
    targetPkgs =
      pkgs: with pkgs; [
        bash
        coreutils
        fontconfig
        freetype
        gcc
        glib
        graphviz
        gtk2
        gtk3
        libuuid
        ncurses5
        nettools
        stdenv.cc.cc
        unzip
        libx11
        libxext
        libxft
        libxi
        libxrender
        libxtst
        libxcb
        zlib
      ];
    runScript = ''
      env LIBRARY_PATH=/usr/lib \
        C_INCLUDE_PATH=/usr/include \
        CPLUS_INCLUDE_PATH=/usr/include \
        CMAKE_LIBRARY_PATH=/usr/lib \
        CMAKE_INCLUDE_PATH=/usr/include \
        ${root}/bin/vivado "$@"
    '';
  };
  desktopEntry = ''
    [Desktop Entry]
    Type=Application
    Name=Vivado ${version}
    Comment=Vivado ${version}
    Icon=${root}/doc/images/vivado_logo.png
    Exec=${lib.getExe launcher}
    Terminal=false
    Categories=Development;Engineering;
    StartupNotify=true
  '';
in
{
  home.packages = [
    launcher
  ];

  home.file.".local/share/applications/Vivado ${version}.desktop".text = desktopEntry;
  home.file."Desktop/Vivado ${version}.desktop" = {
    text = desktopEntry;
    executable = true;
  };
}
