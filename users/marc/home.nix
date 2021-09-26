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
    mako # notification daemon
    libnotify
    imv
    bc
    simple-scan
    neofetch
    sc-im
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
    catdocx
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

      assigns = {
        "2" = [{ app_id = "firefox"; }];
        "3" = [{ class = "obsidian"; }];
        "4" = [{ class = "code"; }];
        "5" = [{ app_id = "org.pwmt.zathura"; }];
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
      menu = "rofi -show drun";

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
              "1" = ""; # Terminal
              "2" = ""; # Browser
              "3" = ""; # Obsidian
              "4" = ""; # Code
              "5" = ""; # PDF
              "6" = ""; # Random
              "7" = ""; # Random
              "8" = ""; # Random
              "9" = ""; # Music
            };
          };
          "mpd" = {
            format = "<span background=\"${gruvbox.aqua14}\" foreground=\"${gruvbox.bg0}\">  </span> {title}i - {artist}";
          };
          "clock" = {
            format = "<span background=\"${gruvbox.yellow3}\" foreground=\"${gruvbox.bg0}\">  </span> {:%a, %d %b %Y - %H:%M}";
            format-alt = "<span background=\"${gruvbox.yellow3}\" foreground=\"${gruvbox.bg0}\">  </span> {:Week %OV - %Y}";
            tooltip = false;
          };
          "battery" = {
            bat = "BAT0";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {capacity}%";
            format-charging = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {capacity}%";
            format-plugged = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["" "" "" "" ""];
          };
          "battery#bat1" = {
            bat = "BAT1";
            states = {
              warning = 30;
              critical = 15;
            };
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {capacity }%";
            format-charging = " {capacity}%";
            format-plugged = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["" "" "" "" ""];
          };
          "backlight" = {
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {percent}%";
            format-icons = [""];
          };
          "disk" = {
            interval = 30;
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {percentage_used}%";
            path = "/";
          };
          "memory" = {
            format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {used:0.1f} GiB";
            tooltip = false;
          };
          "network" = {
            format-wifi = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {essid} ({signalStrength}%)";
            format-ethernet = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {ipaddr}/{cidr}";
            format-linked = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {ifname} (No IP)";
            format-disconnected = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> ⚠ </span> Disconnected";
            tooltip = false;
          };
          "pulseaudio" = {
             format = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {volume}%";
             format-bluetooth = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\"> {icon} </span> {volume}%";
             format-muted = "<span background=\"${gruvbox.fg2}\" foreground=\"${gruvbox.bg0}\">  </span> {volume}%";
             format-icons = {
               headphone = "";
               hands-free = "";
               headset = "";
               phone = "";
               portable = "";
               car = "";
               default = [""];
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

      #mpd {
        margin-left: 15px;
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
    signing = {
      key = "8F78DF81034CE6D8";
      signByDefault = true;
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

  programs.alacritty = let gruvbox = import ./gruvbox.nix; in {
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
        userChrome = builtins.readFile conf.d/userChrome.css;
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
    width = 520;
    padding = 10;
    lines = 18;
    font = "monospace 10";
    separator = "none";
    borderWidth = 1;
    scrollbar = false;
    colors = let gruvbox = import ./gruvbox.nix; in {
      window = {
        background = "${gruvbox.bg0}";
        border = "${gruvbox.fg1}";
        separator = "${gruvbox.fg1}";
      };

      rows = {
        normal = {
          background = "${gruvbox.bg0}";
          foreground = "${gruvbox.fg1}";
          backgroundAlt = "${gruvbox.bg0}";
          highlight = {
            background = "${gruvbox.yellow3}";
            foreground = "${gruvbox.bg0}";
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

  accounts.email.accounts = let params = import ../../secrets/mailbox-params.nix; in {
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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      golang.go
      matklad.rust-analyzer
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "gruvbox";
      publisher = "jdinhlife";
      version = "1.5.0";
      sha256 = "14dm19bwlpmvarcxqn0a7yi1xgpvp93q6yayvqkssravic0mwh3g";
    }];

    userSettings = {
      "workbench.colorTheme" = "Gruvbox Dark Medium";
    };

  };

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      documents = "\$HOME/documents"; # Does it set root's home dir?
    };
  };

}
