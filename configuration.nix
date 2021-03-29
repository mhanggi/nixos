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

  # Set some package configs
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
       LC_TIME = "de_CH.UTF-8";
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

  environment.variables.TERMINAL = "alacritty";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "audio" "video" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.users.marc = {...} : {
    programs.home-manager.enable = true;

    home.sessionVariables = {
      EDITOR = "vim";
      BROWSER = "firefox";
      TERMINAL = "alacritty";
    };

    # Define some compile arguments
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.wayland = true;

    home.packages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      wofi
      waybar
      imv
    ];

 
    wayland.windowManager.sway = {
      enable = true;
      
      config = {
        modifier = "Mod4";

        input."*" = {
          xkb_layout = "us";
          xkb_variant = "altgr-intl";
        };

        bars = [
          { command = "waybar"; }
        ];

        keybindings = pkgs.lib.mkOptionDefault {
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };

        terminal = "alacritty";
        menu = "wofi --show drun";

        window.border = 2;
        gaps.smartBorders = "off";
        gaps.smartGaps = true;
        gaps.inner = 5;

        # it seems the child border defines the color
        colors = {
          focused = {
            border = "#d5c4a1"; # fg-2 
            background = "#282828"; # bg-0
            text = "#ebdbb2"; # fg-1
            indicator = "#d5c4a1"; # fg-2
            childBorder = "#d5c4a1"; # fg-2
          };

          unfocused = {
            border = "#7c6f64"; # bg-4
            background = "#282828"; # bg-0
            text = "#ebdbb2"; # fg-1
            indicator = "#7c6f64"; # bg-4
            childBorder = "#7c6f64"; # bg-4
          };

          focusedInactive = {
            border = "#7c6f64"; # bg-4
            background = "#282828"; # bg-0
            text = "#ebdbb2"; # fg-1
            indicator = "#7c6f64"; # bg-4
            childBorder = "#7c6f64"; # bg-4
          };

          urgent = {
            border = "#cc241d"; # red-1
            background = "#282828"; # bg-0
            text = "#ee0000"; # fg-1
            indicator = "#cc241d"; # red-1
            childBorder = "#cc241d"; # red-1
          };
        };

        output."*".bg = "~/wallpapers/5m5kLI9.png fill";
      };
    };

    programs.waybar = {
      enable = true;
      settings = [
        {
          modules-left = [ "sway/workspaces" ];
          modules-center = [];
          modules-right = [ "pulseaudio" "memory" "disk" "backlight" "battery" "battery#bat1" "network" "clock" ];

          modules = {
            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };
            clock = {
              format = " {:%a, %d %b %Y - %H:%M}";
              format-alt = " {:%OV/%Y}";
              tooltip = false;
            };
            "battery" = {
              bat = "BAT0";
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-alt = "{icon} {time}";
              format-icons = ["" "" "" "" ""];
            };
            "battery#bat1" = {
              bat = "BAT1";
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-alt = "{icon} {time}";
              format-icons = ["" "" "" "" ""];
            };
            "backlight" = {
              format = "{icon} {percent}%";
              format-icons = [""];
            };
            "disk" = {
              interval = 30;
              format = " {percentage_used}%";
              path = "/";
            };
            "memory" = {
              format = " {used:0.1f} GiB";
            };
            "network" = {
              format-wifi = " {essid} ({signalStrength}%)";
              format-ethernet = " {ipaddr}/{cidr}";
              format-linked = " {ifname} (No IP)";
              format-disconnected = "⚠ Disconnected";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
            };
	    "pulseaudio" = {
		format = "{volume}% {icon}";
		format-bluetooth = "{volume}% {icon}";
		format-muted = "";
		format-icons = {
		  headphone = "";
		  hands-free = "";
		  headset = "";
		  phone = "";
		  portable = "";
		  car = "";
		  default = ["" ""];
		};
		scroll-step = 1;
		on-click = "pavucontrol";
	    };
          };
        }
      ];

      style = ''
        * {
            border: none;
            border-radius: 0;
            font-family: monospace;
            font-size: 14px;
        }        

        window#waybar {
          background: #16191C;
          color: #AAB2BF;
        }

	window#waybar {
	    background-color: #282828;
	    color: #ebdbb2;
	    transition-property: background-color;
	    transition-duration: .5s;
	}

	window#waybar.hidden {
	    opacity: 0.2;
	}

	#workspaces button {
	    padding: 0 5px;
	    background-color: transparent;
	    color: #ebdbb2;
	    border-bottom: 3px solid transparent;
	}

	/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
	#workspaces button:hover {
	    background: rgba(0, 0, 0, 0.2);
	    box-shadow: inherit;
	    border-bottom: 3px solid #d79921;
	}

	#workspaces button.focused {
	    background: rgba(255, 255, 255, 0.1);
	    border-bottom: 3px solid #d79921;
	}

	#workspaces button.urgent {
	    background-color: #eb4d4b;
	}

	#mode {
	    background-color: #444;
	}
       
	#backlight,
	#battery,
	#custom-media,
        #clock,
        #disk,
	#memory,
        #network,
	#network,
	#mode,
	#mpd,
	#pulseaudio {
	    padding-left: 2px;
	    padding-right: 2px;
	    margin-left: 4px;
	    margin-right: 4px;
	}

	@keyframes blink {
	    to {
		background-color: #ffffff;
		color: #000000;
	    }
	}

	#battery.critical:not(.charging) {
	    background-color: #f53c3c;
	    color: #ffffff;
	    animation-name: blink;
	    animation-duration: 0.5s;
	    animation-timing-function: linear;
	    animation-iteration-count: infinite;
	    animation-direction: alternate;
	}

	label:focus {
	    background-color: #000000;
	}

	#network.disconnected {
	    background-color: #f53c3c;
	}

	#pulseaudio.muted {
	}

	#waybar > box:nth-child(2) > box:nth-child(3) > *:not(:first-child) > label {
	  background-image:
	    linear-gradient(@col_border_trans, @col_border_solid 45%, @col_border_solid 55%, @col_border_trans)
	  ;
	  background-size:1px 20%;
	  background-position:0 50%;
	  background-repeat:no-repeat;
	}
      '';
    };
 
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
  
    programs.alacritty = {
      enable = true;
      settings = {
        #background_opacity = 0.95;
        window = {
          padding.x = 10;
          padding.y = 10;
        };      
  
        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xdfbf8e";
          }; 
  
          normal = {
            black =   "0x665c54";
            red =     "0xea6962";
            green =   "0xa9b665";
            yellow =  "0xe78a4e";
            blue =    "0x7daea3";
            magenta = "0xd3869b";
            cyan =    "0x89b482";
            white =   "0xdfbf8e";
          };
  
          bright = {
            black =   "0x928374";
            red =     "0xea6962";
            green =   "0xa9b665";
            yellow =  "0xe3a84e";
            blue =    "0x7daea3";
            magenta = "0xd3869b";
            cyan =    "0x89b482";
            white =   "0xdfbf8e";
          };
        };
      };
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
  #    programs.readline = {
  #      enable = true;
  #      includeSystemConfig = true;
  #      extraConfig = ''
  #        set enable-keypad on
  #      '';
  #    };
  
      # Make things pretty:
  #    services.picom = {
  #      enable = true;
  #      blur = true;
  #      fade = true;
  #      shadow = true;
  #      shadowExclude = [ "focused = 0" ];
  #      extraOptions = ''
  #        shadow-red   = 0;
  #        shadow-green = 0.91;
  #        shadow-blue  = 0.78;
  #        xinerama-shadow-crop = true;
  #      '';
  #      };
  
  #      services.random-background = {
  #        enable = true;
  #        imageDirectory = "%h/backgrounds";
  #        interval = "1h";
  #      };
  #
  #      xresources = {
  #        properties = {
  #          "st.font" = "Monospace-12";
  #          "st.alpha" = "0.95";
  #        };
  #      };
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
#    picom
#    st
#    dmenu
#    zathura
    wget
    vim
    tmux
    pass
    git
    firefox
  ];

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
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

