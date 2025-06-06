{ config, lib, pkgs, ... }: {
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim-full; # Use vim with all features

    extraConfig = builtins.concatStringsSep "\n" ([
      (builtins.readFile ../config/vim/base.vim)
      (builtins.readFile ../config/vim/functions.vim)
      (builtins.readFile ../config/vim/keymaps.vim)
      (builtins.readFile ../config/vim/appearance.vim)
      (builtins.readFile ../config/vim/autocmds.vim)
      (builtins.readFile ../config/vim/plugin-config.vim)
    ]);

    plugins = with pkgs.vimPlugins;
      let
        xoria256 = pkgs.vimUtils.buildVimPlugin {
          name = "xoria256-vim";
          src = pkgs.fetchFromGitHub {
            owner = "vim-scripts";
            repo = "xoria256.vim";
            rev = "ae38fd50b365052ed4ddbc79a006a45628d5786a";
            sha256 = "1i3j176l821sq55v2rpwnyipmydr3v4y7a9xnrvn0807cxi1bb68";
          };
        };
        vim-maximizer = pkgs.vimUtils.buildVimPlugin {
          name = "vim-maximizer";
          src = pkgs.fetchFromGitHub {
            owner = "szw";
            repo = "vim-maximizer";
            rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
            sha256 = "031brldzxhcs98xpc3sr0m2yb99xq0z5yrwdlp8i5fqdgqrdqlzr";
          };
        };
        vim-win = pkgs.vimUtils.buildVimPlugin {
          name = "vim-win";
          src = pkgs.fetchFromGitHub {
            owner = "dstein64";
            repo = "vim-win";
            rev = "78be4acff9434372c6c0aeb0200dddc30fa8920c";
            sha256 = "1s4phd9yzykg8kh40i3cj1a2wj4fwgx1417z6rqqc3bxjmyhxm25";
          };
        };
        bufkill = pkgs.vimUtils.buildVimPlugin {
          name = "bufkill-vim";
          src = pkgs.fetchFromGitHub {
            owner = "bit101";
            repo = "bufkill";
            rev = "112b6ba433762198282f8dd9f58a6680259234d4";
            sha256 = "1jcpr67d9xrv0and5fsphvwqyn2ghc3drm4hpq72aiv3d5n3nizw";
          };
        };
        html5-vim = pkgs.vimUtils.buildVimPlugin {
          name = "html5-vim";
          src = pkgs.fetchFromGitHub {
            owner = "othree";
            repo = "html5.vim";
            rev = "485f2cd62162c81e56d8604b4c630f0b5ef69d1f";
            sha256 = "0j012i6nklc4p92cbh3l1zqs850plxh847b52lskb533rhygx9kf";
          };
        };
        vim-svelte = pkgs.vimUtils.buildVimPlugin {
          name = "vim-svelte";
          src = pkgs.fetchFromGitHub {
            owner = "evanleck";
            repo = "vim-svelte";
            rev = "0e93ec53c3667753237282926fec626785622c1c";
            sha256 = "1vv10bx2q463bjg7gvjy5lfxn0177s2r8i8xlwy2kg4620n0g5xi";
          };
        };
        terminalkeys = pkgs.vimUtils.buildVimPlugin {
          name = "terminalkeys-vim";
          src = pkgs.fetchFromGitHub {
            owner = "nacitar";
            repo = "terminalkeys.vim";
            rev = "f7c9125cab22059adf860180d2e2590fb2d52606";
            sha256 = "130sn8d2gzrw628rychk53946vvpwhsj2layhpsa0srp0h9l6snx";
          };
        };
      in [
        # Theme
        xoria256
        vim-airline
        vim-airline-themes

        # UI Enhancements
        vim-maximizer
        vim-win
        bufkill
        vim-indent-guides
        fastfold
        vista-vim
        nerdtree
        fzf-vim

        # Git
        vim-fugitive

        # Editing
        vim-surround

        # Languages
        vim-polyglot
        tabular
        vim-markdown
        ale
        markdown-preview-nvim
        html5-vim
        vim-javascript
        vim-svelte

        # Nix Support
        tlib_vim
        vim-addon-mw-utils
        vim-addon-actions
        vim-addon-completion
        vim-addon-goto-thing-at-cursor
        vim-addon-errorformats
        vim-addon-nix

        # Project Config
        lh-vim-lib

        # Navigation/Terminal
        terminalkeys
      ];
  };

  # Directory structure for vim
  home.file = builtins.listToAttrs (
    # ftdetect files
    map (file: {
      name = ".vim/ftdetect/${file}";
      value = { source = ../config/vim/ftdetect + "/${file}"; };
    }) (builtins.attrNames (builtins.readDir ../config/vim/ftdetect))
    # ftplugin files
    ++ map (file: {
      name = ".vim/ftplugin/${file}";
      value = { source = ../config/vim/ftplugin + "/${file}"; };
    }) (builtins.attrNames (builtins.readDir ../config/vim/ftplugin)));
}
