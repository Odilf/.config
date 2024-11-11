{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  config = lib.mkIf (config.gui && isDarwin) {
    environment.variables.SHELL = "fish";

    system.defaults = {
      dock.magnification = true;
      dock.largesize = 68;
      dock.tilesize = 64;
      dock.orientation = "right";

      dock.showhidden = true; # Translucent hidden icons
      dock.show-recents = false; # Don't show recents
      # TODO: Add persistenct dock applications

      # Zoom thingy with ^ (control).
      # universalaccess.closeViewScrollWheelToggle = true;

      # Login thing
      loginwindow.GuestEnabled = true;
      loginwindow.LoginwindowText = "Yo.";

      NSGlobalDomain.ApplePressAndHoldEnabled = false;
    };

    # TouchID for sudo 
    security.pam.enableSudoTouchIdAuth = true;

    environment.systemPackages = [
      pkgs.iina # Media player (should be in something in packages...)
    ];

    homebrew = {
      casks = [
        "sol" # App launcher
        "surfshark" # VPN
        "mechvibes" # cross-platform, but not in nixpkgs...
        "betterdisplay" # macos specific
        "battery" # Keep battery at specific percentage
      ];
    };

    services = {
      aerospace = {
        enable = true;
        settings =
          # TODO: uggo
          let
            tomlCfg = builtins.fromTOML (builtins.readFile ../../../aerospace/aerospace.toml);
            cfg = tomlCfg // {
              mode.main.binding = tomlCfg.mode.main.binding // {
                alt-enter = "exec-and-forget SHELL=fish open -n ${pkgs.alacritty}/Applications/Alacritty.app";
              };

              # TODO: Do I need to set them explicitly? Or is it only to override them?
              start-at-login = false;
              after-login-command = [ ];
              after-startup-command = [ ];
            };
          in
          cfg;
      };
    };
  };
}