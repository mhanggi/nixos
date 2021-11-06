# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.pulseaudio = true;
  nixpkgs.config.wayland = true;
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "t560"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
  networking.interfaces.wwp0s20f0u2c2.useDHCP = true;
  networking.firewall = {
     enable = true;
     allowPing = false;
     allowedTCPPorts = [];
     allowedUDPPorts = [];
     logRefusedConnections = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # GB starts the week on Monday
      LC_TIME = "en_GB.UTF-8";
      LC_PAPER = "de_CH.UTF-8";
      LC_MEASUREMENT= "de_CH.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # backlight control
  services.illum.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };

  hardware.sane.enable = true;
  hardware.bluetooth.enable = true;
  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
 #   "acpi_backlight=native"
  ];
  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  services.tlp.enable = true;

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
  security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
          subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
  '';

  services.borgbackup.jobs."t560" = {
    paths = [
      "/home/marc"
    ];
    exclude = [
      "/home/*/Maildir"
      "/home/*/.cache"
      "/home/*/.config"
      "/home/*/Downloads"
      # temporary files created by cargo and `go build`
      "**/target"
      "/home/*/go/bin"
      "/home/*/go/pkg"
    ];
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
    repo = builtins.readFile ../secrets/borgbase-t560-repo.nix;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = ["0/2:00:00"]; #every two hours
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "audio" "video" "networkmanager" "scanner" "lp" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    procps
    cryptsetup
    yubikey-personalization
    pcsclite
    parted
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      lmodern # latex font
      hack-font
      font-awesome
      dejavu_fonts
      source-code-pro
      source-sans-pro
      source-serif-pro
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Source Code Pro" ];
        sansSerif = [ "Source Sans Pro" ];
        serif     = [ "Source Serif Pro" ];
      };
    };
  };


  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
    autorun = false;
    videoDrivers = [ "modesetting" ];
    useGlamor = true;
    libinput.enable = true; # Touchpad support
    displayManager.startx.enable = true;
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
