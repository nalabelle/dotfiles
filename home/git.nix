{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;

    ignores = [
      "*~"
      ".DS_Store"
      ".cache"
      ".*cache"
      ".kilocode"
      ".kilocodeignore"
      ".mcp"
      ".mcp.json"
      ".metals"
      ".tags"
      ".vscode"
      "vimrc.local"
    ];

    settings = {
      user = {
        name = "nalabelle";
        email = "2044448+nalabelle@users.noreply.github.com";
      };

      core = {
        editor = "vim --clean";
        untrackedCache = true;
      };

      color.ui = true;

      pull.rebase = true;

      push = {
        default = "upstream";
        autoSetupRemote = true;
      };

      diff.tool = "vimdiff";

      fetch.prune = true;

      init = {
        defaultBranch = "main";
      };

      protocol.version = 2;

      rebase = {
        autoStash = true;
        updateRefs = true;
      };

      "diff \"sopsdiffer\"".textconv = "sops -d";

      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };

      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdghZWKTk7678RA/Vt4LMktDd47yLjYSgLalXEP85sh";
      commit.gpgsign = false;
      gpg.format = "ssh";

      include.path = ".gitconfig_local";

      alias = {
        "get-main-remote" = "!git branch -rl '*/HEAD' | cut -f2 -d'>' | cut -c 2-";
        "get-main-branch" = "!git branch | cut -c 3- | grep -E '^master$|^main$'";
        "try-rebase-all" =
          ''!f() { CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD); TARGET=$(git get-main-remote); for branch in $(git for-each-ref --format='%(refname:lstrip=2)' refs/heads/); do git rebase "$TARGET" "$branch" >/dev/null 2>&1 || git rebase --abort; done; git switch "$CURRENT_BRANCH"; }; f'';
        "rm-merged" =
          "!git branch --format='%(refname:lstrip=2)' --merged | grep -vE '^master$|^main$' | xargs git branch -d";
        "rbc" = "rebase --continue";
        "rba" = "rebase --abort";
        "br" = "branch -vv";
        "amend" =
          ''!f() { if [ $# -eq 0 ]; then git commit --amend --no-edit; else git commit --amend "$@"; fi; }; f'';
        "gone" =
          "!git remote prune origin >/dev/null && git branch -vv | grep ': gone]' | awk '{print $1}'";
        "gone-rm" = "!git gone | xargs git branch -D";
        "tld" = "rev-parse --show-toplevel";
        "fpush" = "push --force-with-lease";
        "log-compare" = "log --oneline --boundary --left-right --cherry-mark --decorate";
        "logf" =
          "log-compare --abbrev-commit --format='tformat:%C(auto,blue)%m%C(auto) %h %s%d %C(auto,dim)%cr'";
        "logr" = "logf --reverse";
        "logn" = ''log -p -- . ":(exclude)package-lock.json"'';
        "ri" =
          ''!f() { if [ $# -eq 0 ]; then set -- origin/main; fi; git rebase --interactive --keep-base "$@"; }; f'';
        "rb" =
          ''!f() { if [ $# -eq 0 ]; then set -- origin/main; git fetch origin main; fi && git rebase "$@"; }; f'';
        "stack" =
          "!git log --decorate=short --pretty='format:%D' origin/main.. | sed 's/, /\\n/g; s/HEAD -> //' | grep -Ev '^origin|^$'";
        "fpstack" = "!git stack | xargs git push --force-with-lease origin";
        "wip" = ''commit --no-verify -m "WIP"'';
        "fix" = "commit --no-verify -m 'WIP: FIXUP'";
      };
    };
  };

}
