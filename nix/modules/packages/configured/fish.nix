{
  lib,
  config,
  pkgs,
  ...
}:
let
  utils = import ../../utils.nix { inherit pkgs lib config; };
in
{
  options.packages.configured.fish = {
    enabled = lib.mkEnableOption "fish";
  };

  config = utils.eachHome {
    # Maybe necessary for completions? (https://discourse.nixos.org/t/how-to-use-completion-fish-with-home-manager/23356/3)
    xdg.configFile."fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";

    programs = {
      eza.enable = true;
      eza.enableFishIntegration = false; # `la` does `eza -a` but I want `eza -l`

      zoxide.enable = true;
      starship.enable = true;
      thefuck.enable = true;
    };

    programs.fish = {
      enable = true;

      preferAbbrs = true;
      interactiveShellInit = ''
        set fish_greeting
        enable_transience # (from starship)

        ${pkgs.pfetch}/bin/pfetch 
      '';

      shellAbbrs = {
        # Keep muscle memmory but use new versions
        ls = "eza";
        la = "eza -l";
        lt = "eza --tree";
        grep = "rg";
        cat = "bat";
        vim = "nvim";

        # Actual abbreviations of long commands
        e = "nvim";
        g = "git";
        c = "cargo";

        ## Git
        gc = "git commit";
        gC = "git commit --amend";
        gp = "git push";
        gP = "git pull";
        gl = "git log --graph";
        gd = "git diff";
        gD = "git diff --staged";
        gs = "git status";

        ## Nix
        ns = "nix shell nixpkgs#";
        # rebuild = let
        #   inherit (pkgs.stdenv.hostPlatform) isDarwin;
        #   command = if isDarwin then "darwin-rebuild" else "sudo nixos-rebuild";
        #   host-raw = config.networking.hostName; # TODO: This will not be correct probably
        #   host = if host-raw == null then "" else host-raw; # TODO: Is there really no "null or" concept in nix?
        # in "${command} switch --flake github:odilf/dotfiles?dir=nix#${host}";
      };
    };
  };
}
