# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./gpg.nix
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nixpkgs.overlays = [
    (import ./st-overlay.nix)
  ];

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
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Configure keymap in X11
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;
  services.xserver.windowManager.dwm.enable = true;

  # backlight control
  services.illum.enable = true;

  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;
  hardware.cpu.intel.updateMicrocode = true;

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

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys = {
    enable = true;
    volumeStep = "5%";
  };

  #hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "audio" "video" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.users.marc = {...} : {
    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      userName = "mhanggi";
      userEmail = "29100324+mhanggi@users.noreply.github.com";
      ignores = [ "*~" "*.swp" ];
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      plugins = with pkgs.tmuxPlugins; [ gruvbox prefix-highlight ]; 
    };

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ gruvbox vim-airline vim-nix]; 
      extraConfig = ''
        " This should be enabled by default
        set number
        set incsearch
        set smartcase
        set expandtab

        " Hack supports this so let's use it
        let g:airline_powerline_fonts = 1

        set t_Co=256
        set termguicolors
        " This is only necessary if you use "set termguicolors".
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set background=dark
        colorscheme gruvbox
      '';
    };

    programs.firefox = {
      enable = true;
      extensions =
        with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
          browserpass
        ];
      profiles = {
        home = {
          id = 0;
          settings = {
            "app.update.auto" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.urlbar.placeholderName" = "Qwant";
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
          userChrome = builtins.readFile conf.d/userChrome.css;
        };
      };
    };

    # Enable the delete key in ST
    programs.readline = {
      enable = true;
      includeSystemConfig = true;
      extraConfig = ''
        set enable-keypad on
      '';
    };

    # Make things pretty:
    services.picom = {
      enable = true;
      blur = true;
      fade = true;
      shadow = true;
      shadowExclude = [ "focused = 0" ];
      extraOptions = ''
        shadow-red   = 0;
        shadow-green = 0.91;
        shadow-blue  = 0.78;
        xinerama-shadow-crop = true;
      '';
      };

      services.random-background = {
        enable = true;
        imageDirectory = "%h/backgrounds";
        interval = "1h";
      };

      xresources = {
        properties = {
          "st.font" = "Monospace-12";
          "st.alpha" = "0.95";
        };
      };
  };

    
  home-manager.users.root = {...} : {
    programs.home-manager.enable = true;
    
    programs.git = {
      enable = true;
      userName = "mhanggi";
      userEmail = "29100324+mhanggi@users.noreply.github.com";
    };

  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    picom
    st
    dmenu
    wget
    vim
    tmux
    pass
    git
    firefox
    zathura
  ];

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      hack-font
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

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

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

