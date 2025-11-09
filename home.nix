{ config, pkgs, lib, ... }:

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

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    icons = "always";
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

    '';
    functions = {
      fish_greeting = "";
      nxs = ''
          test (count $argv) -eq 0; and echo "usage: nxs pkg [pkg ...]"; and return 1
          set pkgs
          for a in $argv
            set pkgs $pkgs nixpkgs#$a
          end
          set -l names (string join " " $argv)
          nix shell $pkgs --command env IN_NIX_SHELL=impure ANY_NIX_SHELL_PKGS="$names" $SHELL -l
      '';

    };
    shellAliases = { moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon"; };
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }

      {
        name = "bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "e3b4d4eafc23516e35f162686f08a42edf844e40";
          hash = "sha256-cXOYvdn74H4rkMWSC7G6bT4wa9d3/3vRnKed2ixRnuA=";
        };
      }
    ];
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
        st    = "status -sb";
        br    = "branch";
        co    = "checkout";
        ci    = "commit";
        hist  = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
        type  = "cat-file -t";
        dump  = "cat-file -p";
        lg1   = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
        lg2   = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
        lg    = "lg1";
      };
      init.defaultBranch = "master";
      push.default = "current";
      core.editor =
        "${lib.getExe' pkgs.emacs "emacsclient"} -t -a ${lib.getExe pkgs.emacs}";
      merge.conflictstyle = "zdiff3";
    };
  };

  programs.difftastic = {
    enable = true;
    git.diffToolMode = "difftool";
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
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
         window_background_opacity = 0.95,
         color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
      }
    '';
  };

  programs.codex = {
    enable = true;
  };

  programs.television = {
    enable = true;
  };

  programs.nix-search-tv = {
    enable = true;
  };
  
}
