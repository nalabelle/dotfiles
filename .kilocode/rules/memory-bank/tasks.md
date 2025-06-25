# Memory Bank Tasks

## ZSH Directory Cleanup and Migration

**Last analyzed:** 2025-06-25
**Status:** Step 2 completed - shell options migrated to declarative Nix configuration
**Current State:** 3 of 4 zsh/ files still sourced by home/zsh.nix (options migration completed)

### Analysis Results

#### Files and Current Usage

**`zsh/completions`** - Tool completions for:

- `gt` (graphite-cli) - installed in bst host, completion must be preserved
- `devbox` - development environment tool, completion must be preserved
- **Action:** MIGRATE to Nix declarative configuration

**`zsh/imports`** - Homebrew and Homeshick setup:

- Homebrew environment setup with fpath additions
- Homeshick configuration and refresh
- **Action:** COMPLETELY REDUNDANT - nix-darwin handles Homebrew, Homeshick unused

**`zsh/options`** - Shell options, key bindings, globbing, history:

- **Unique options requiring migration:**
  - Globbing: `nocaseglob`, `extendedglob`, `globdots`, `no_nomatch`
  - Corrections: `correct`
  - Vi mode history search: `bindkey -M vicmd 'k' history-substring-search-up`
  - Vi mode history search: `bindkey -M vicmd 'j' history-substring-search-down`
  - Backspace binding: `bindkey -v '^?' backward-delete-char`
  - Key mappings for terminal navigation
- **Action:** PARTIALLY REDUNDANT - unique options need migration to home/zsh.nix

**`zsh/prompt`** - Custom VCS-aware prompt with git status:

- Comprehensive VCS info configuration with colors and status indicators
- Custom prompt functions for date, environment, and git status
- **Critical Finding:** Functions defined but NOT ACTIVATED (commented out)
- **Active Prompt:** Starship is the current prompt system
- **Action:** CLEANUP - remove unused custom prompt functions, keep only needed modules

### Current Integration

All 4 files currently sourced in [`home/zsh.nix`](home/zsh.nix:10):

```nix
home.file.".config/zsh/options".source = ../zsh/options;
home.file.".config/zsh/prompt".source = ../zsh/prompt;
home.file.".config/zsh/imports".source = ../zsh/imports;
home.file.".config/zsh/completions".source = ../zsh/completions;
```

And loaded via [`initContent`](home/zsh.nix:49):

```nix
source ${config.xdg.configHome}/zsh/options;
source ${config.xdg.configHome}/zsh/prompt;
source ${config.xdg.configHome}/zsh/imports;
```

### Step-by-Step Implementation Plan

#### 1. Migrate Completions

- Move `gt` (graphite-cli) completion to `programs.zsh.completions` in home/zsh.nix
- Move `devbox` completion to `programs.zsh.completions` in home/zsh.nix
- **Pattern:** Legacy shell completions → `programs.zsh.completions`

#### 2. Migrate Shell Options ✅ COMPLETED

- ✅ Move unique globbing options to `programs.zsh.initExtra`:
  - `setopt nocaseglob`
  - `setopt extendedglob`
  - `setopt globdots`
  - `setopt no_nomatch`
- ✅ Move correction setting: `setopt correct`
- ✅ Move histverify: `setopt histverify`
- ✅ Move vi mode history search bindings:
  - `bindkey -M vicmd 'k' history-substring-search-up`
  - `bindkey -M vicmd 'j' history-substring-search-down`
- ✅ Move backspace binding: `bindkey -v '^?' backward-delete-char`
- **Pattern:** Shell options → `programs.zsh.initExtra` with setopt commands

#### 3. Remove Redundant Imports

- Delete `zsh/imports` file completely
- Remove from home/zsh.nix sourcing
- **Rationale:** nix-darwin handles Homebrew, Homeshick unused

#### 4. Clean Up Prompt

- Remove unused custom prompt functions from `zsh/prompt`
- Keep only `zmodload zsh/datetime` and `autoload -U promptinit` if needed
- Remove custom prompt hook functions (commented out)
- **Rationale:** Starship is active prompt system

#### 5. Test & Validate

- Verify configuration builds with `nix flake check`
- Test completions functionality for gt and devbox
- Verify shell options are preserved
- Confirm no functionality lost

### Migration Patterns

**Completions Migration:**

```nix
# Before: sourced from zsh/completions
# After: in programs.zsh.completions
programs.zsh.completions = [
  {
    name = "gt";
    src = pkgs.runCommand "gt-completion" {} ''
      mkdir -p $out
      ${pkgs.graphite-cli}/bin/gt completion > $out/_gt
    '';
  }
  {
    name = "devbox";
    src = pkgs.runCommand "devbox-completion" {} ''
      mkdir -p $out
      ${pkgs.devbox}/bin/devbox completion zsh > $out/_devbox
    '';
  }
];
```

**Shell Options Migration:**

```nix
# Before: sourced from zsh/options
# After: in programs.zsh.initExtra
programs.zsh.initExtra = ''
  # Globbing
  setopt nocaseglob
  setopt extendedglob
  setopt globdots
  setopt no_nomatch
  
  # Corrections
  setopt correct
  
  # Vi mode history search
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  bindkey -v '^?' backward-delete-char
'';
```

### Key Findings

- **gt = graphite-cli**: Installed in bst host, completion must be preserved
- **devbox completion**: Also needs preservation
- **Unique shell options**: Globbing, corrections, vi mode bindings require migration
- **Custom prompt**: Functions loaded but commented out (not activated)
- **Starship active**: Current prompt system working correctly
- **Homebrew integration**: Already handled by nix-darwin
- **Homeshick**: Unused in current configuration

### Success Criteria

1. ❌ All tool completions preserved and working
2. ✅ Unique shell options migrated to declarative configuration
3. ❌ Redundant imports removed without breaking functionality
4. ❌ Custom prompt cleanup without affecting Starship
5. ❌ Configuration builds and functions identically
6. ❌ Reduced maintenance burden through declarative approach

This migration follows the established pattern of moving legacy shell scripts to declarative Nix configuration while preserving all functional capabilities.
