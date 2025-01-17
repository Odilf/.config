{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  packages.gui = false;
  packages.users = [
    "uoh"
    "odilf"
  ];

  # For todoist-electron
  # TODO: Make it whitelist, don't allow all
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [
    "ntfs"
    "exfat"
    "hfsplus"
    "ext4"
  ];

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "uoh-server"; # Define your hostname.

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.uoh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  users.users.odilf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  programs.mosh = {
    enable = true;
    openFirewall = true;
  };

  services = rec {
    openssh = {
      enable = true;
      openFirewall = true;
      ports = [ 4652 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [
          "uoh"
          "odilf"
        ];
        UseDns = true;
        PermitRootLogin = "prohibit-password";
      };
    };

    endlessh = {
      enable = true;
      port = 22;
    };

    incipit = {
      enable = true;
      port = 80;
      addr = "0.0.0.0";
      incipit-host = "incipit.odilf.com";
      services = {
        # "files.odilf.com".port = sentouki.port;
        "churri.odilf.com".port = churri.port;
        "photos.odilf.com".port = 2283; # TODO: Change when (or if) immich is properly on nix
        "media.odilf.com".port = 8096; # Hard coded in jellyfin :(
        "git.odilf.com".port = gitea.settings.server.HTTP_PORT;
        "scrutiny.odilf.com".port = scrutiny.settings.web.listen.port;
      };
    };

    samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          "use sendfile" = true;
          "hosts deny" = [ "0.0.0.0/0" ];
          "hosts allow" = [
            "192.168.0."
            "127.0.0.1"
            "localhost"
          ];
        };

        "UOH-ARCHIVE" = {
          path = "/mnt/UOH-ARCHIVE";
          browseable = true;
          "valid users" = [
            "odilf"
            "uoh"
          ];
          "read only" = false;
          writeable = true;
          "fruit:nfs_aces" = true;
          "fruit:aapl" = true;
          "vfs objects" = "fruit streams_xattr";
          "fruit:model" = "MacSamba";
        };

        "mnt" = {
          path = "/mnt";
          browseable = true;
          "valid users" = [
            "odilf"
            "uoh"
          ];
          "read only" = true;
          writeable = true;
          "fruit:nfs_aces" = true;
          "fruit:aapl" = true;
          "vfs objects" = "fruit streams_xattr";
          "fruit:model" = "MacSamba";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    inadyn = {
      enable = true;
      configFile = /etc/inadyn.conf;
    };

    # Broken, it seems :(
    # jellyfin.enable = true;

    churri = {
      enable = true;
      port = 2001;
      host = "0.0.0.0";
      targetDate = "2024-12-27T19:00:00+01:00";
    };

    # `file` is not provided in binary
    # sentouki = {
    #   enable = true;
    #   host = "0.0.0.0";
    #   basePath = "/mnt/";
    # };

    gitea = {
      enable = true;
      appName = "Git on UOH.";
      settings.server.HTTP_PORT = 2780;
      database.type = "postgres";
    };

    # nix-minecraft
    minecraft-servers = {
      enable = true;
      eula = true;

      servers.nina = {
        enable = true;
        openFirewall = true;
        package = pkgs.fabricServers.fabric-1_21_3;
        serverProperties = {
          server-ip = "0.0.0.0";
          server-port = 25565; # To change you need to set up a reverse proxy to forward different `*:25565` requests depending on the host.
          difficulty = "normal";
          gamemode = "survival";
          max-players = 3;
          motd = "Minecraft server, hosted from UOH";
          online-mode = false;
          level-name = "Atlas";
        };

        jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC";

        symlinks = {
          "mods" = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              Lithium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/QhCwdt4l/lithium-fabric-0.14.2-snapshot%2Bmc1.21.3-build.91.jar";
                sha256 = "sha256-BJOMjp49XBUJbhhhXcZUhEIVUpaCSTz5UCmLIJWWDFs=";
              };
              SkinRestorer = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/ghrZDhGW/versions/GSZWlZM2/skinrestorer-2.1.0%2B1.21-fabric.jar";
                sha256 = "sha256-pOH3egWhZ6zy+AnfXiULLLSy2Xwb517dQ5fIbqVPRC0=";
              };
            }
          );
        };
      };
    };

    # Monitoring
    smartd = {
      enable = true;
      devices = [
        # { device = "/dev/disk/by-uuid/65B5-2A38"; } # UOH-ARCHIVE
        { device = "/dev/disk/by-uuid/2f764760-62d4-427e-b33d-b08ae3fcc5b7"; } # TOSHIBA
        { device = "/dev/disk/by-uuid/89bb9652-c89b-40a5-9a76-7e64212b82f0"; } # UOH-MEDIA
        { device = "/dev/disk/by-uuid/0dfd1ee6-692f-4911-8f84-341a9aa75f4a"; } # INTENSO
      ];
    };

    scrutiny = {
      enable = true;
      settings.web.listen.port = 8305;
    };

    cage = {
      enable = true;
      program = "${pkgs.firefox}/bin/firefox";
    };
  };

  # For immich
  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
      allowPing = true;
    };
  };

  fileSystems = {
    "/mnt/UOH-ARCHIVE" = {
      device = "/dev/disk/by-uuid/65B5-2A38";
      fsType = "exfat";
      options = [
        "nofail"
        "uid=1000"
        "gid=1000"
        "dmask=007"
        "fmask=117"
        "x-gvfs-show"
      ];
    };

    "/mnt/TOSHIBA" = {
      device = "/dev/disk/by-uuid/2f764760-62d4-427e-b33d-b08ae3fcc5b7";
      fsType = "ext4";
      options = [
        "nofail"
        "rw"
      ];
    };

    # "/mnt/UOH-MEDIA" = {
    #   device = "/dev/disk/by-uuid/89bb9652-c89b-40a5-9a76-7e64212b82f0";
    #   fsType = "btrfs";
    #   options = [ "nofail" ];
    # };

    "/mnt/INTENSO" = {
      device = "/dev/disk/by-uuid/0dfd1ee6-692f-4911-8f84-341a9aa75f4a";
      fsType = "btrfs";
      options = [ "nofail" ];
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
