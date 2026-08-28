{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jason";
  home.homeDirectory = "/Users/jason";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    pkgs.fishPlugins.grc
    pkgs.fixepub
    pkgs.syncFlakeLockFromDarwin
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jason/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "auto:system";
      theme-dark = "1337";
      theme-light = "Monokai Extended Light";
    };
  };

  programs.eza = {
    enable = true;
    icons = "always";
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.nix-your-shell = {
    enable = true;
    # Source it below so the package-label wrapper can layer on top of the
    # generated Fish functions.
    enableFishIntegration = false;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
      functions --copy nix __nix_your_shell_nix
      functions --copy nix-shell __nix_your_shell_nix_shell

      function __nix_shell_package_names
        set -l skip 0
        set -l package_names

        for arg in $argv
          if test $skip -gt 0
            set skip (math $skip - 1)
          else
            switch $arg
              case -c --command --run
                break
              case --arg --argstr --override-input --option
                set skip 2
              case -f --file -I --include -k --keep -u --unset --store \
                   --eval-store --system --cores -j --max-jobs \
                   --builders --substituters --trusted-public-keys
                set skip 1
              case '-*'
              case '*'
                set -l flake_parts (string split -r -m 1 '#' -- $arg)
                set -a package_names $flake_parts[-1]
            end
          end
        end

        string join ' ' $package_names
      end

      function nix
        set -l subcommand $argv[1]
        if test "$subcommand" = shell; or test "$subcommand" = develop
          set -l package_names (__nix_shell_package_names $argv[2..])
          test -n "$package_names"; or set package_names "nix $subcommand"
          set -fx NIX_SHELL_PACKAGES (string join ' ' $NIX_SHELL_PACKAGES $package_names)
        end

        __nix_your_shell_nix $argv
      end

      function nix-shell
        set -l package_names (__nix_shell_package_names $argv)
        test -n "$package_names"; or set package_names nix-shell
        set -lx NIX_SHELL_PACKAGES (string join ' ' $NIX_SHELL_PACKAGES $package_names)
        __nix_your_shell_nix_shell $argv
      end

    '';
    functions = {
      fish_greeting = "";
      nxs = ''
        test (count $argv) -eq 0; and echo "usage: nxs pkg [pkg ...]"; and return 1
        set pkgs
        for a in $argv
          set pkgs $pkgs nixpkgs#$a
        end
        nix shell $pkgs
      '';

    };
    shellAliases = {
      moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jason McCandless";
        email = "me@jasonmc.net";
      };
      alias = {
        st = "status -sb";
        br = "branch";
        co = "checkout";
        ci = "commit";
        hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
        type = "cat-file -t";
        dump = "cat-file -p";
        lg1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
        lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
        lg = "lg1";
      };
      init.defaultBranch = "master";
      push.default = "current";
      core.editor = "${lib.getExe' pkgs.emacs "emacsclient"} -t -a ${lib.getExe pkgs.emacs}";
      merge.conflictstyle = "zdiff3";
      diff.tool = "difftastic";
      difftool.difftastic.cmd = "${lib.getExe pkgs.difftastic} $LOCAL $REMOTE";
    };
  };

  programs.difftastic = {
    enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*.jasonmc.net *.fibo" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h:%p";
        ControlPersist = "10m";
      };

      "*" = {
        IdentityAgent = [
          "/Users/jason/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
        ];
      };
    };
  };

  programs.wezterm = {
    enable = true;

    extraConfig = ''
      local wezterm = require "wezterm"

      function scheme_for_appearance(appearance)
         if appearance:find "Dark" then
            return "OneDark (base16)"
         else
            return "OneLight (Gogh)"
         end
      end

      return {
         font_size = 13,
         window_background_opacity = 0.95,
         macos_window_background_blur = 20,
         color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
      }
    '';
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableFishIntegration = true;
    settings = {
      cursor-style = "block";
      cursor-style-blink = "false";
      shell-integration-features = "no-cursor";
      theme = "light:Monokai Pro Light Sun,dark:Ghostty Default Style Dark";
      quit-after-last-window-closed = true;
      background-opacity = 0.95;
      background-blur = true;
      macos-non-native-fullscreen = true;
    };
  };

  programs.codex = {
    enable = true;
  };

  programs.television = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.nix-search-tv = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

}
