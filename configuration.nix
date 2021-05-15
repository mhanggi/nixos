# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/master.tar.gz"; 
      #sha256 = "1jf5rdxyqk6q8x4x81n15bnn0z0158y2g9wnl2d2yxxv15rgdlbi";
    }){
      inherit pkgs;
    };
  };

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

  services.pcscd.enable = true;
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
      keep-daily = 7;
      keep-weekly = 4;
      keep-monthly = 12;
    };
    repo = "irh34ju7@irh34ju7.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = "daily";
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

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
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_WEBRENDER = 1; # Enable Servo Engine
      MOZ_DBUS_REMOTE= 1;
    };

    home.stateVersion = "21.03";

    home.sessionPath = [
      "~/.local/bin"
    ];

    # Define some compile arguments
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.wayland = true;

    home.packages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      gnome3.adwaita-icon-theme # to prevent GTK warnings
      gruvbox-dark-icons-gtk
      dconf # required for home-manager gtk.*
      mako # notification daemon
      imv
      bc
      simple-scan
      neofetch
      sc-im
      w3m
      urlscan
      youtube-dl
      (texlive.combine { inherit (texlive) scheme-basic enumitem fontawesome etoolbox pgf metafont; })
    ];

    gtk = {
      enable = true;
      theme.package = pkgs.gruvbox-dark-gtk;
      theme.name = "gruvbox-dark";
      iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
      iconTheme.name = "oomox-gruvbox-dark";
    };

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
          "XF86Calculator" = "exec alacritty -e bc";
          "XF86HomePage" = "exec firefox";
          "XF86Tools" = "exec alacritty -e sudo ~/.local/bin/nixconf.sh"; #FN-F9
          "XF86Search" = "exec alacritty -e lf"; # FN-F10
         # "XF86Display" = "exec bla" # FN-F7
         # "XF86LaunchA" = "exec firefox"; # FN-F11
         # "XF86Explorer" = "exec alacritty -e lf"; # FN-F12
         # "Print" = "exec alacritty"; # Print Screen
        };

        terminal = "alacritty";
        menu = "rofi -show drun";

        window.border = 1;
        gaps.smartBorders = "off";
        gaps.smartGaps = false;
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
          modules-left = [ "sway/workspaces" "custom/sep" "mpd" ];
          modules-center = ["clock"];
          modules-right = [ "pulseaudio" "custom/sep" "memory" "custom/sep" "disk" "custom/sep" "backlight" "custom/sep" "battery" "custom/sep" "battery#bat1" "custom/sep" "network" ];

          modules = {
            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };
            "mpd" = {
              format = "  {title}i - {artist}";
            };
            "clock" = {
              format = " {:%a, %d %b %Y - %H:%M}";
              format-alt = " {:Week %OV - %Y}";
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
		format = "{icon} {volume}%";
		format-bluetooth = "{icon} {volume}%";
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
            "custom/sep" = {
               format = "|";
               interval = "once";
               tooltip = false;
            };
          };
        }
      ];

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: monospace;
          font-size: 12px;
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
	  border-top: 3px solid transparent;
	}

	/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
	#workspaces button:hover {
	  background: rgba(0, 0, 0, 0.2);
	  box-shadow: inherit;
	  border-top: 3px solid #d79921;
	}

	#workspaces button.focused {
	  background: rgba(255, 255, 255, 0.1);
	  border-top: 3px solid #d79921;
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
        #network,
        #network,
        #mode,
        #mpd,
        #memory,
        #pulseaudio {
	  padding-left: 2px;
	  padding-right: 2px;
	  margin-left: 5px;
	  margin-right: 5px;
	}

        #backlight {
          color: #d3869b;
        }

        #battery {
          color: #83a598;
        }

        #clock {
          color: #fabd2f;
        }

        #disk {
          color: #b8bb26;
        }

        #network {
          color: #b8bb26;
        }

	#pulseaudio {
          color: #fb4934;
        }

        #memory {
          color: #8ec07c;
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

        #custom-separator {
          color: #1B5E20;
          margin: 0 5px;
        }
      '';
    };

    programs.bash = {
      enable = true;
       shellAliases = {
         vi = "vim";
       };
    };

    programs.password-store = {
      enable = true;
      settings = {
        #PASSWORD_STORE_DIR = "$XDG_DATA_HOME/.password-store";
        PASSWORD_STORE_DIR = "/home/marc/.password-store";
      };
    };

    programs.git = {
      enable = true;
      userName = "mhanggi";
      userEmail = "29100324+mhanggi@users.noreply.github.com";
      ignores = [ "*~" "*.swp" ];
      extraConfig = {
        core = { editor = "vim"; };
      };
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

    programs.gpg.enable = true;
    services.gpg-agent.enable = true;
    services.gpg-agent.enableScDaemon = true;
    services.gpg-agent.pinentryFlavor = "curses";
    services.gpg-agent.enableSshSupport = true;
    services.gpg-agent.sshKeys = [ "0x8D0AF893B6C583F6" ];
  
    programs.alacritty = {
      enable = true;
      settings = {

        window = {
          padding.x = 10;
          padding.y = 10;
        };      

        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
          save_to_clipboard = true;
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
      package = pkgs.firefox-wayland;
      extensions =
        with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
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
            "gfx.webrender.all" = true;
            "widget.wayland-dmabuf-vaapi.enabled" = true;
            "media.ffvpx.enabled" = false;
          };
          userChrome = builtins.readFile conf.d/userChrome.css;
        };
      };
    };

    programs.rofi = {
      enable = true;
      package = pkgs.nur.repos.metadark.rofi-wayland; # rofi with wayland support
      pass.enable = true;
      pass.stores =[ "/home/marc/.password-store" ];
      width = 520;
      padding = 10;
      lines = 18;
      font = "monospace 10";
      separator = "none";
      borderWidth = 1;
      scrollbar = false;
      colors = {
        window = {
          background = "#282828";
          border = "#ebdbb2";
          separator = "#ebdbb2";
        };

        rows = {
          normal = {
            background = "#282828";
            foreground = "#ebdbb2";
            backgroundAlt = "#282828";
            highlight = {
              background = "#d79921";
              foreground = "#282828";
            };
          };
        };
      };
    };

    programs.lf = {
      enable = true;
      settings.color256 = true;
      settings.preview = true;
    };

    programs.neomutt = {
      enable = true;
      sort = "reverse-date-received";
      binds = [
        {
          key = "\\ck";
          action = "sidebar-prev";
          map = [ "index" "pager" ];
        }
        {
          key = "\\cj";
          action = "sidebar-next";
          map = [ "index" "pager" ];
        }
        {
          key = "\\co";
          action = "sidebar-open";
          map = [ "index" "pager" ];
        }
        {
          key = "\\cp";
          action = "sidebar-prev-new";
          map = [ "index" "pager" ];
        }
        {
          key = "\\cn";
          action = "sidebar-next-new";
          map = [ "index" "pager" ];
        }
        {
          key = "B";
          action = "sidebar-toggle-visible";
          map = [ "index" "pager" ];
        }
        {
          key = "<Tab>";
          action = "complete-query";
          map = [ "editor" ];
        }
      ];
      macros = [
        {
          key = "O";
          action = "<shell-escape>mbsync -a<enter>"; # Sync all email
          map = [ "index" ];
        }
        {
          key = "\\cb";
          action = "<pipe-message> urlscan<Enter>"; # Call urlscan to extract URLs
          map = [ "pager" ];
        }
      ];

      sidebar = {
        enable = true;
        format = "%D%?F? [%F]?%* %?N?%N/? %?S?%S?";
        width = 20;
        shortPath = true;
      };

      extraConfig = ''
        set mailcap_path = ~/.config/neomutt/mailcap # point to mailcap file
        set mime_type_query_command = "file --mime-type -b %s"
        set date_format="%Y/%m/%d %H:%M"
        set index_format="%2C %Z %?X?A& ? %D %-15.15F %s (%-4.4c)"
        set query_command = "abook --mutt-query '%s'"
        set rfc2047_parameters = yes    # RFC2047 MIME params used by Outlook
        set sleep_time = 0              # Pause 0 seconds for informational messages
        set markers = no                # Disables the `+` displayed at line wraps
        set mark_old = no               # Unread mail stay unread until read
        set mime_forward = yes          # attachments are forwarded with mail
        set wait_key = no               # mutt won't ask "press key to continue"
        set fast_reply                  # skip to compose when replying
        set fcc_attach                  # save attachments with the body
        set forward_format = "Fwd: %s"  # format of subject when forwarding
        set forward_quote               # include message in forwards
        set reverse_name                # reply as whomever it was to
        set include                     # include message in replies
        auto_view text/html             # automatically show html (mailcap uses w3m)
        alternative_order text/plain text/enriched text/html
        auto_view application/pgp-encrypted
        alternative_order text/plain text/enriched text/html

        # Colors
        # gruvbox dark (contrast dark):
        color attachment  color109 color235
        color bold        color229 color235
        color error       color167 color235
        color hdrdefault  color246 color235
        color indicator   color223 color237
        color markers     color243 color235
        color normal      color223 color235
        color quoted      color250 color235
        color quoted1     color108 color235
        color quoted2     color250 color235
        color quoted3     color108 color235
        color quoted4     color250 color235
        color quoted5     color108 color235
        color search      color235 color208
        color signature   color108 color235
        color status      color235 color250
        color tilde       color243 color235
        color tree        color142 color235
        color underline   color223 color239

        color sidebar_divider    color250 color235
        color sidebar_new        color142 color235

        # New Mail
        color index color66 color235 ~N

        # Deleted Mail
        color index color235 color167 ~D

        # Old Messages
        color index color223 color235 ~O

        # Read Messages
        color index color223 color235 ~R

        # Flagged Messages
        color index color214 color235 ~F

        # Messages which have been replied to
        color index color175 color235 ~Q

        # Duplicated Messages
        color index color167 color235 ~=

        # Tagged Messages
        color index color235 color223 ~T

        color header color214 color235 "^(To:|From:)"
        color header color142 color235 "^Subject:"
        color header color108 color235 "^X-Spam-Status:"
        color header color108 color235 "^Received:"

        # BSD's regex has RE_DUP_MAX set to 255.
        color body color142 color235 "[a-z]{3,255}://[-a-zA-Z0-9@:%._\\+~#=/?&,]+"
        color body color142 color235 "[a-zA-Z]([-a-zA-Z0-9_]+\\.){2,255}[-a-zA-Z0-9_]{2,255}"
        color body color208 color235 "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
        color body color208 color235 "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
        color body color235 color214 "[;:]-*[)>(<lt;|]"
        color body color229 color235 "\\*[- A-Za-z]+\\*"

        color body color214 color235 "^-.*PGP.*-*"
        color body color142 color235 "^gpg: Good signature from"
        color body color167 color235 "^gpg: Can't.*$"
        color body color214 color235 "^gpg: WARNING:.*$"
        color body color167 color235 "^gpg: BAD signature from"
        color body color167 color235 "^gpg: Note: This key has expired!"
        color body color214 color235 "^gpg: There is no indication that the signature belongs to the owner."
        color body color214 color235 "^gpg: can't handle these multiple signatures"
        color body color214 color235 "^gpg: signature verification suppressed"
        color body color214 color235 "^gpg: invalid node with packet of type"

        color body color142 color235 "^Good signature from:"
        color body color167 color235 "^.?BAD.? signature from:"
        color body color142 color235 "^Verification successful"
        color body color167 color235 "^Verification [^s][^[:space:]]*$"

        color compose header            color223 color235
        color compose security_encrypt  color175 color235
        color compose security_sign     color109 color235
        color compose security_both     color142 color235
        color compose security_none     color208 color235
      '';
    };

    # enable html emails
    home.file.".config/neomutt/mailcap".text = ''
       text/html; w3m -I %{charset} -T text/html; copiousoutput;
    '';

    programs.abook = {
      enable = true;
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;

    services.imapnotify.enable = true;

    accounts.email.accounts = let params = import ./mailbox-params.nix; in {
      "mailbox.org" = (params // {
        primary = true;
        folders.inbox = "INBOX";
        imap.host = "imap.mailbox.org";
        imap.port = 993;
        imap.tls.enable = true;
        smtp.host = "smtp.mailbox.org";
        smtp.port = 465;
        smtp.tls.enable = true;
        mbsync.enable = true;
        mbsync.create = "both";
        mbsync.expunge = "both";
        msmtp.enable = true;
        neomutt = {
          enable = true;
          extraConfig = ''
            unmailboxes *
            mailboxes =INBOX =Drafts =Sent =Trash
            macro index R "<shell-escape>mbsync mailbox.org<enter>"
          '';
        };
      });
    };

    programs.zathura = {
      enable = true;

      options = {
	notification-error-bg = "#282828"; # bg
	notification-error-fg = "#fb4934"; # bright:red
	notification-warning-bg = "#282828"; # bg
	notification-warning-fg = "#fabd2f"; # bright:yellow
	notification-bg = "#282828"; # bg
	notification-fg = "#b8bb26"; # bright:green

	completion-bg = "#504945"; # bg2
	completion-fg = "#ebdbb2"; # fg
	completion-group-bg = "#3c3836"; # bg1
	completion-group-fg = "#928374"; # gray
	completion-highlight-bg = "#83a598"; # bright:blue
	completion-highlight-fg = "#504945"; # bg2

	# Define the color in index mode
	index-bg = "#504945"; # bg2
	index-fg = "#ebdbb2"; # fg
	index-active-bg = "#83a598"; # bright:blue
	index-active-fg = "#504945"; # bg2

	inputbar-bg = "#282828"; # bg
	inputbar-fg = "#ebdbb2"; # fg

	statusbar-bg = "#504945"; # bg2
	statusbar-fg = "#ebdbb2"; # fg

	highlight-color = "#fabd2f"; # bright:yellow
	highlight-active-color = "#fe8019"; # bright:orange

	default-bg = "#282828"; # bg
	default-fg = "#ebdbb2"; # fg
	render-loading = true;
	render-loading-bg = "#282828"; # bg
	render-loading-fg  = "#ebdbb2"; # fg

	# Recolor book content's color
        recolor-lightcolor = "#282828"; # bg
        recolor-darkcolor = "#ebdbb2"; # fg
        recolor = "true";
        recolor-reverse-video = "true"; # Keep original picture colors
        recolor-keephue = "true";
      };
    };

    programs.newsboat = {
      enable = true;
      autoReload = true;
      urls = [
        { title = "hackernews"; tags = [ "IT" ] ; url = "https://news.ycombinator.com/rss"; }
        { title = "golem.de"; tags = [ "IT" ] ; url = "https://www.golem.de/rss"; }
        { title = "srf.ch"; tags = [ "News" ] ; url = "https://www.srf.ch/news/bnf/rss/1646"; }
      ];
      extraConfig = ''
        bind-key j down
        bind-key k up
        bind-key j next articlelist
        bind-key k prev articlelist
        bind-key J next-feed articlelist
        bind-key K prev-feed articlelist
        bind-key G end
        bind-key g home
        bind-key d pagedown
        bind-key u pageup
        bind-key l open
        bind-key h quit
        bind-key a toggle-article-read
        bind-key n next-unread
        bind-key N prev-unread
        bind-key D pb-download
        bind-key U show-urls
        bind-key x pb-delete

        color article                              color223 color235
        color background                           color223 color235
        color info                                 color142 color235
        color listfocus                            color109 color239
        color listfocus_unread                     color223 color239
        color listnormal                           color109 color235
        color listnormal_unread                    color223 color235
        highlight article "^Feed:.*"               color223 color237
        highlight article "^Title:.*"              color223 color237 bold
        highlight article "^Author:.*"             color223 color237
        highlight article "^Link:.*"               color109 color237
        highlight article "^Date:.*"               color142 color237
        highlight article "\\[[0-9]\\+\\]"         color208 color237 bold
        highlight article "\\[[^0-9].*[0-9]\\+\\]" color167 color237 bold
      '';
    };

    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu";
        gpu-context = "wayland";
      };
    };

    services.mpd = {
      enable = true;
      network.startWhenNeeded = true;
    };

    programs.ncmpcpp = {
      enable = true;
    };

    programs.jq.enable = true;
    programs.htop.enable = true;

    xdg = {
      enable = true;
      mime.enable = true;
      userDirs = {
        enable = true;
        documents = "\$HOME/documents"; # Does it set root's home dir?
      };
    };
  };

  home-manager.users.root = {...} : {
    programs.home-manager.enable = true;
    
    programs.git = {
      enable = true;
      userName = "mhanggi";
      userEmail = "29100324+mhanggi@users.noreply.github.com";
      extraConfig = {
        core = { editor = "vim"; };
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    procps
    cryptsetup
    yubikey-personalization
    pcsclite
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

