{ pkgs, lib, ... }:

let
  version = "2025.2";
  root = "/mnt/nvme/Xilinx/${version}/Vivado";
  vendorLibraryPath = lib.concatStringsSep ":" [
    "${root}/lib/lnx64.o"
    "${root}/lib/lnx64.o/SuSE"
    "${root}/lib/lnx64.o/Rhel/10"
    "${root}/lib/lnx64.o/Rhel/9"
    "${root}/lib/lnx64.o/Ubuntu/24"
    "${root}/lib/lnx64.o/Ubuntu/22"
  ];
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
        libpng
        libuuid
        ncurses5
        nettools
        pixman
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
      env LD_LIBRARY_PATH="${vendorLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
        LIBRARY_PATH=/usr/lib \
        C_INCLUDE_PATH=/usr/include \
        CPLUS_INCLUDE_PATH=/usr/include \
        CMAKE_LIBRARY_PATH=/usr/lib \
        CMAKE_INCLUDE_PATH=/usr/include \
        ${root}/bin/vivado "$@"
    '';
  };
  desktopLauncher = pkgs.writeShellApplication {
    name = "vivado-desktop";
    runtimeInputs = [
      launcher
      pkgs.coreutils
    ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/vivado"
      mkdir -p "$state_dir"
      cd "$state_dir"
      exec ${lib.getExe launcher} -log "$state_dir/vivado.log" -journal "$state_dir/vivado.jou" "$@"
    '';
  };
  desktopEntry = ''
    [Desktop Entry]
    Type=Application
    Name=Vivado ${version}
    Comment=Vivado ${version}
    Icon=${root}/doc/images/vivado_logo.png
    Exec=${lib.getExe desktopLauncher}
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
