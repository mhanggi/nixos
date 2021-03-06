{ config, pkgs, ... }:

{
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
    libnotify
    imv
    bc
    simple-scan
    w3m
    urlscan
    youtube-dl
    (texlive.combine { inherit (texlive) scheme-small collection-langgerman enumitem multirow fontawesome etoolbox pgf metafont; })
    xdg-utils
    cdrkit
    picard
    git-crypt
    pdfarranger
    obsidian
    unzip
    tasky
    brightnessctl
    tree
    libreoffice
    exiftool
    polybar
    killall
    feh
  ];

  gtk = {
    enable = true;
    theme.package = pkgs.gruvbox-dark-gtk;
    theme.name = "gruvbox-dark";
    iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
    iconTheme.name = "oomox-gruvbox-dark";
  };

  xsession.enable = true;


  home.file.".xinitrc".text = ''
    exec i3
  '';

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      modifier = "Mod4";

      bars = []; # Empty list removes bar

      startup = [
        { command = "feh --bg-scale ~/wallpapers/5m5kLI9.png"; notification = false; }
        { command = "~/.config/i3/polybar.sh &"; always = true; notification = false; }
      ];

      assigns = {
        "1" = [{ title = "tmux"; }];
#       "2" = [{ app_id = "firefox"; } { instance = "brave-browser"; }];
        "3" = [{ class = "obsidian"; }];
        "4" = [{ class = "Code"; }]; # Visual Studio Code
        "5" = [{ title = "neomutt"; } { title = "newsboat"; }];
#       "6" = [{ app_id = "org.pwmt.zathura"; }];
        "9" = [{ title = "ncmpcpp"; }];
      };

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
      menu = "\"rofi -show combi -combi-modi 'drun,task' -modi 'combi,task:tasky' -drun-display-format {name}\"";

      window.border = 1;
      gaps.smartBorders = "off";
      gaps.smartGaps = false;
      gaps.inner = 5;

      # it seems the child border defines the color
      colors = let gruvbox = import ./gruvbox.nix; in {
        focused = {
          border = "${gruvbox.fg2}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.fg2}";
          childBorder = "${gruvbox.fg2}";
        };

        unfocused = {
          border = "${gruvbox.bg4}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.bg4}";
          childBorder = "${gruvbox.bg4}";
        };

        focusedInactive = {
          border = "${gruvbox.bg4}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.bg4}";
          childBorder = "${gruvbox.bg4}";
        };

        urgent = {
          border = "${gruvbox.red1}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.red1}";
          childBorder = "${gruvbox.red1}";
        };
      };

    };
  };

  services.polybar = {
    enable = true;
    script = "polybar bar &";
    settings = let gruvbox = import ./gruvbox.nix; in {
      "settings" = {
        screenchange-reload = true;
      };

      "bar/base" = {
        background = "${gruvbox.bg0}";
        border-color = "${gruvbox.bg0}";

        modules-left = "xworkspaces";
        modules-center = "date";
        modules-right = "pulseaudio memory filesystem backlight battery wlan";

        cursor-click = "pointer";
        cursor-scroll = "ns-resize";

        enable-ipc = true;

        width = "100%";
        height = 17;
        padding-right = 1;
        module-margin-left = 2;

        border-bottom-size = 5;
        border-top-size = 5;
        border-left-size = 0;
        border-right-size = 0;

        #font-N = <fontconfig pattern>;<vertical offset>
        font-0 = "monospace:pixelsize=9;3";
        font-1 = "Font Awesome 5 Free Regular:size=10;2";
        font-2 = "Font Awesome 5 Free Solid:size=10;2";
        font-3 = "Font Awesome 5 Brands Regular:size=10;2";
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";

        label-active = "%name%: %icon%";
        label-active-background = "${gruvbox.bg2}";
        label-active-foreground = "${gruvbox.yellow11}";
        label-active-padding = 1;

        label-occupied = "%name%: %icon%";
        label-occupied-padding = 1;
        label-occupied-foreground = "${gruvbox.fg2}";

        label-urgent = "%name%: %icon%";
        label-urgent-background = "${gruvbox.bg2}";
        label-urgent-foreground = "${gruvbox.fg2}";
        label-urgent-padding = 1;

        label-empty = "%name%: %icon%";
        label-empty-foreground = "${gruvbox.fg2}";
        label-empty-padding = 1;

        icon-0 = "1;???";
        icon-1 = "2;???";
        icon-2 = "3;???";
        icon-3 = "4;???";
        icon-4 = "5;???";
        icon-5 = "6;???";
        icon-6 = "7;???";
        icon-7 = "8;???";
        icon-8 = "9;???";
        icon-default = "???";
      };

      "module/filesystem" = {
	type = "internal/fs";
        interval = 25;

        mount-0 = "/";

        format-mounted-prefix = "???";
        format-mounted-prefix-background = "${gruvbox.fg2}";
        format-mounted-prefix-foreground = "${gruvbox.bg0}";
        format-mounted-prefix-padding = 1;

        label-mounted-background = "${gruvbox.bg2}";
        label-mounted-foreground = "${gruvbox.fg2}";
        label-mounted-padding = 1;
        label-mounted = "%percentage_used%%";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        format-volume-prefix = "???";
        format-volume-prefix-background = "${gruvbox.fg2}";
        format-volume-prefix-foreground = "${gruvbox.bg0}";
        format-volume-prefix-padding = 1;
        label-volume = "%percentage%%";
        label-volume-background = "${gruvbox.bg2}";
        label-volume-foreground = "${gruvbox.fg2}";
        label-volume-padding = 1;

        format-muted-prefix = "???";
        format-muted-prefix-background = "${gruvbox.fg2}";
        format-muted-prefix-foreground = "${gruvbox.bg0}";
        format-muted-prefix-padding = 1;
        label-muted = "%percentage%%";
        label-muted-background = "${gruvbox.bg2}";
        label-muted-foreground = "${gruvbox.fg2}";
        label-muted-padding = 1;
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "???";
        format-prefix-padding = 1;
        format-prefix-background = "${gruvbox.fg2}";
        format-prefix-foreground = "${gruvbox.bg0}";
        label = "%gb_used%";
        label-background = "${gruvbox.bg2}";
        label-foreground = "${gruvbox.fg2}";
        label-padding = 1;
      };

      "network-base" = {
        type = "internal/network";
        interval = 5;
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
      };

      "module/wlan" = {
        "inherit" = "network-base";
        interface= "wlp4s0";
        interface-type = "wireless";

        label-connected = "%essid% %signal%%";
        label-connected-background = "${gruvbox.bg2}";
        label-connected-foreground = "${gruvbox.fg2}";
        label-connected-padding = 1;

        format-connected-prefix = "???";
        format-connected-prefix-padding = 1;
        format-connected-prefix-background = "${gruvbox.fg2}";
        format-connected-prefix-foreground = "${gruvbox.bg0}";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;

        date = "%a, %d %b %Y - %H:%M";
        date-alt = "%Y-%m-%d %H:%M:%S";

        format = "<label>";
        format-prefix = "???";
        format-prefix-padding = 1;
        format-prefix-background = "${gruvbox.yellow3}";
        format-prefix-foreground = "${gruvbox.bg0}";

        label = "%date%";
        label-background = "${gruvbox.bg2}";
        label-foreground = "${gruvbox.fg2}";
        label-padding = 1;
      };

      "module/backlight" = {
        type = "internal/backlight";
        card = "intel_backlight";

        format = "<label>";
        format-prefix = "???";
        format-prefix-padding = 1;
        format-prefix-background = "${gruvbox.fg2}";
        format-prefix-foreground = "${gruvbox.bg0}";

        label = "%percentage%%";
        label-background = "${gruvbox.bg2}";
        label-foreground = "${gruvbox.fg2}";
        label-padding = 1;
      };

      "module/battery" = {
        type = "internal/battery";

        full-at = 97;
        battery = "BAT0";
        adapter = "AC";

        format-full-prefix = "???";
        format-full-prefix-padding = 1;
        format-full-prefix-background = "${gruvbox.fg2}";
        format-full-prefix-foreground = "${gruvbox.bg0}";
        label-full-background = "${gruvbox.bg2}";
        label-full-foreground = "${gruvbox.fg2}";
        label-full-padding = 1;

        format-charging-prefix = "???";
        format-charging-prefix-padding = 1;
        format-charging-prefix-background = "${gruvbox.fg2}";
        format-charging-prefix-foreground = "${gruvbox.bg0}";
        label-charging-background = "${gruvbox.bg2}";
        label-charging-foreground = "${gruvbox.fg2}";
        label-charging-padding = 1;

        format-discharging-prefix = "???";
        format-discharging-prefix-padding = 1;
        format-discharging-prefix-background = "${gruvbox.fg2}";
        format-discharging-prefix-foreground = "${gruvbox.bg0}";
        label-discharging-background = "${gruvbox.bg2}";
        label-discharging-foreground = "${gruvbox.fg2}";
        label-discharging-padding = 1;
        # discharging in anderer farbe
      };
    };
  };

  home.file.".config/i3/polybar.sh" = {
    text = ''
      #!/usr/bin/env sh

      # Terminate already running bar instances
      killall -q polybar

      # Wait until the processes have been shut down
      while pgrep -x polybar >/dev/null; do sleep 1; done

      # Launch polybar
      polybar base &
    '';
    executable = true;
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

      assigns = {
        "1" = [{ title = "tmux"; }];
        "2" = [{ app_id = "firefox"; } { instance = "brave-browser"; }];
        "3" = [{ class = "obsidian"; }];
        "4" = [{ class = "Code"; }]; # Visual Studio Code
        "5" = [{ title = "neomutt"; } { title = "newsboat"; }];
        "6" = [{ app_id = "org.pwmt.zathura"; }];
        "9" = [{ title = "ncmpcpp"; }];
      };

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
      menu = "rofi -show combi -combi-modi 'drun,task' -modi 'combi,task:tasky' -drun-display-format {name}";

      window.border = 1;
      gaps.smartBorders = "off";
      gaps.smartGaps = false;
      gaps.inner = 5;

      # it seems the child border defines the color
      colors = let gruvbox = import ./gruvbox.nix; in {
        focused = {
          border = "${gruvbox.fg2}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.fg2}";
          childBorder = "${gruvbox.fg2}";
        };

        unfocused = {
          border = "${gruvbox.bg4}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.bg4}";
          childBorder = "${gruvbox.bg4}";
        };

        focusedInactive = {
          border = "${gruvbox.bg4}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.bg4}";
          childBorder = "${gruvbox.bg4}";
        };

        urgent = {
          border = "${gruvbox.red1}";
          background = "${gruvbox.bg0}";
          text = "${gruvbox.fg1}";
          indicator = "${gruvbox.red1}";
          childBorder = "${gruvbox.red1}";
        };
      };

      output."*".bg = "~/wallpapers/5m5kLI9.png fill";
    };
  };

  programs.waybar =  let gruvbox = import ./gruvbox.nix; in
  {
    enable = true;
    settings = [
      {
        modules-left = [ "sway/workspaces" "mpd" ];
        modules-center = ["clock"];
        modules-right = [ "pulseaudio" "memory" "disk" "backlight" "battery" "battery#bat1" "network" ];

        modules = {
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{name}: {icon}";
            format-icons = {
              "1" = "???"; # Terminal
              "2" = "???"; # Browser
              "3" = "???"; # Obsidian
              "4" = "???"; # Code
              "5" = "???"; # Mail & RSS
              "6" = "???"; # PDF
              "7" = "???"; # Random
              "8" = "???"; # Random
              "9" = "???"; # Music
            };
          };
          "mpd" = {
            format = "<span background=\"${gruvbox.aqua14}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {title}i - {artist}";
          };
          "clock" = {
            format = "<span background=\"${gruvbox.yellow3}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {:%a, %d %b %Y - %H:%M}";
            format-alt = "<span background=\"${gruvbox.yellow3}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {:Week %OV - %Y}";
            tooltip = false;
          };
          "battery" = {
            bat = "BAT0";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {capacity}%";
            format-charging = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {capacity}%";
            format-plugged = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["???" "???" "???" "???" "???"];
          };
          "battery#bat1" = {
            bat = "BAT1";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {capacity }%";
            format-charging = "??? {capacity}%";
            format-plugged = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["???" "???" "???" "???" "???"];
          };
          "backlight" = {
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {percent}%";
            format-icons = ["???"];
          };
          "disk" = {
            interval = 30;
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {percentage_used}%";
            path = "/";
          };
          "memory" = {
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {used:0.1f} GiB";
            tooltip = false;
          };
          "network" = {
            format-wifi = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {essid} ({signalStrength}%)";
            format-ethernet = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {ipaddr}/{cidr}";
            format-linked = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {ifname} (No IP)";
            format-disconnected = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> Disconnected";
            tooltip = false;
          };
          "pulseaudio" = {
             format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {volume}%";
             format-bluetooth = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon}??? </span> {volume}%";
             format-muted = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ??? </span> {volume}%";
             format-icons = {
               headphone = "???";
               hands-free = "???";
               headset = "???";
               phone = "???";
               portable = "???";
               car = "???";
               default = ["???"];
             };
             scroll-step = 1;
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
        background: ${gruvbox.bg0};
        background-color: ${gruvbox.bg0};
        color: ${gruvbox.fg2};
        transition-property: background-color;
        transition-duration: .5s;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: ${gruvbox.fg2};
        border-top: 3px solid transparent;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
        box-shadow: inherit;
        border-top: 3px solid ${gruvbox.yellow3};
      }

      #workspaces button.focused {
        background: rgba(255, 255, 255, 0.1);
        border-top: 3px solid ${gruvbox.yellow3};
      }

      #backlight,
      #battery,
      #custom-media,
      #clock,
      #disk,
      #network,
      #mode,
      #mpd,
      #memory,
      #pulseaudio {
        background-color: ${gruvbox.bg2};
        color: ${gruvbox.fg2};
        padding-left: 0px;
        padding-right: 10px;
        margin-top: 5px;
        margin-bottom: 5px;
        margin-left: 5px;
        margin-right: 5px;
      }

      #battery.discharging {
        background: ${gruvbox.green10};
        color: ${gruvbox.bg0};
      }

      #battery.critical {
        background: ${gruvbox.red9};
        color: ${gruvbox.bg0};
      }

      #mpd {
        margin-left: 15px;
      }
    '';
  };

  programs.mako =  let gruvbox = import ./gruvbox.nix; in {
    enable = true;
    anchor = "top-right";
    backgroundColor = "${gruvbox.bg2}";
    borderColor = "${gruvbox.fg2}";
    borderSize = 1;
    textColor = "${gruvbox.fg2}";
    margin = "2,1,5";
    padding = "10,10,5,5";
    defaultTimeout = 2000;
    icons = true; 
    format = "<span background=\"${gruvbox.blue12}\" foreground=\"${gruvbox.bg0}\"> ??? </span> %s";
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
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      key = "8F78DF81034CE6D8";
      signByDefault = true;
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    prefix = "C-a";
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
  services.gpg-agent.pinentryFlavor = "gtk2";
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.sshKeys = [ "0x8D0AF893B6C583F6" ];

  programs.alacritty = let gruvbox = import ./gruvbox.nix; in {
    enable = true;
    settings = {

      window = {
        padding.x = 10;
        padding.y = 10;
      };

      selection = {
        semantic_escape_chars = ",???`|:\"' ()[]{}<>\t";
        save_to_clipboard = true;
      };

      colors = {
        primary = {
          background = "${gruvbox.bg0}";
          foreground = "${gruvbox.fg1}";
        };

        normal = {
          black =   "${gruvbox.bg0}";
          red =     "${gruvbox.red1}";
          green =   "${gruvbox.green2}";
          yellow =  "${gruvbox.yellow3}";
          blue =    "${gruvbox.blue4}";
          magenta = "${gruvbox.purple5}";
          cyan =    "${gruvbox.aqua6}";
          white =   "${gruvbox.fg4}";
        };

        bright = {
          black =   "${gruvbox.gray8}";
          red =     "${gruvbox.red9}";
          green =   "${gruvbox.green10}";
          yellow =  "${gruvbox.yellow11}";
          blue =    "${gruvbox.blue12}";
          magenta = "${gruvbox.purple13}";
          cyan =    "${gruvbox.aqua14}";
          white =   "${gruvbox.fg1}";
        };
      };
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    extensions =
       with pkgs.nur.repos.rycee.firefox-addons; [ vimium ];
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
        #userChrome = builtins.readFile conf.d/userChrome.css;
        userContent = let gruvbox = import ./gruvbox.nix; in 
        ''
          html,body{
            scrollbar-color: ${gruvbox.gray8} ${gruvbox.bg1} !important;
            scrollbar-width: thin;
          }
        '';
      };
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.nur.repos.kira-bruneau.rofi-wayland; # rofi with wayland support
    terminal = "${pkgs.alacritty}/bin/alacritty";
    pass.enable = true;
    pass.stores =[ "/home/marc/.password-store" ];
    font = "monospace 10";
    extraConfig = {
      combi-hide-mode-prefix = true; # Removes the drun,task prefix
    };
    theme = let 
      inherit (config.lib.formats.rasi) mkLiteral;
      gruvbox = import ./gruvbox.nix;
    in {
      "*" = {
        lines = 18;
        background-color = mkLiteral "${gruvbox.bg0}";
        text-color = mkLiteral "${gruvbox.fg1}";
      };

      "#window" = {
        width = 520;
        padding = 10;
        border-color = mkLiteral "${gruvbox.fg1}";
        border = 1;
      };

      "element selected" = {
        background-color = mkLiteral "${gruvbox.yellow3}";
        text-color = mkLiteral "${gruvbox.bg0}";
      };

      "element-text, element-icon" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      inputbar = {
        children = map mkLiteral [ "prompt" "textbox-prompt-sep" "entry" "case-indicator" ];
        padding = mkLiteral "5px 0px 5px 0px";
      };

      textbox-prompt-sep = {
        expand = false;
        str = ": ";
      };

    };

  };

  programs.lf = {
    enable = true;
    settings.color256 = true;
    settings.preview = true;
  };

  programs.zathura = {
    enable = true;
    options = let gruvbox = import ./gruvbox.nix; in {
      notification-error-bg = "${gruvbox.bg0}";
      notification-error-fg = "${gruvbox.red9}";
      notification-warning-bg = "${gruvbox.bg0}";
      notification-warning-fg = "${gruvbox.yellow11}";
      notification-bg = "${gruvbox.bg0}";
      notification-fg = "${gruvbox.green10}";

      completion-bg = "${gruvbox.bg2}";
      completion-fg = "${gruvbox.fg1}";
      completion-group-bg = "${gruvbox.bg1}";
      completion-group-fg = "${gruvbox.gray8}";
      completion-highlight-bg = "${gruvbox.blue12}";
      completion-highlight-fg = "${gruvbox.bg2}";

      # Define the color in index mode
      index-bg = "${gruvbox.bg2}";
      index-fg = "${gruvbox.fg1}";
      index-active-bg = "${gruvbox.blue12}";
      index-active-fg = "${gruvbox.bg2}";

      inputbar-bg = "${gruvbox.bg0}";
      inputbar-fg = "${gruvbox.fg1}";

      statusbar-bg = "${gruvbox.bg2}";
      statusbar-fg = "${gruvbox.fg1}";

      highlight-color = "${gruvbox.yellow11}";
      highlight-active-color = "${gruvbox.orange208}";

      default-bg = "${gruvbox.bg0}";
      default-fg = "${gruvbox.fg1}";
      render-loading = true;
      render-loading-bg = "${gruvbox.bg0}";
      render-loading-fg  = "${gruvbox.fg1}";

      # Recolor book content's color
      recolor-lightcolor = "${gruvbox.bg0}";
      recolor-darkcolor = "${gruvbox.fg1}";
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
      { title = "blog.cleancoder.com"; tags = [ "IT" ] ; url = "https://blog.cleancoder.com/atom.xml"; }
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

  # imv
  home.file.".config/imv/config".text = ''
    [binds]
    <Shift+D> = exec rm "$imv_current_file"; close
  '';

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      documents = "\$HOME/documents"; # Does it set root's home dir?
    };

    desktopEntries = {
      tmux = {
        name = "Tmux";
        genericName = "Terminal Multiplexer";
        exec = "alacritty -t tmux -e tmux";
        terminal = false;
        categories = [ "Development" "Utility" ];
        icon = "utilities-terminal";
      };
      ncmpcpp = {
        name = "ncmpcpp";
        genericName = "Music Player";
        exec = "alacritty -t ncmpcpp -e ncmpcpp";
        terminal = false;
        categories = [ "Audio" ];
        icon = "utilities-terminal";
      };
      newsboat = {
        name = "Newsboat";
        genericName = "RSS Feed Reader";
        exec = "alacritty -t newsboat -e newsboat";
        terminal = false;
        categories = [ "Utility" ];
        icon = "utilities-terminal";
      };
      neomutt = {
        name = "Neomutt";
        genericName = "Mail User Agent";
        exec = "alacritty -t neomutt -e neomutt";
        terminal = false;
        categories = [ "Utility" ];
        icon = "utilities-terminal";
      };
    };
  };

  home.file.".config/tasky/tasks.json".source = ./conf.d/tasky.json;
  home.file."tasks" = {
    source = ./tasks;
    target = "tasks";
    recursive = true;
  };

}
