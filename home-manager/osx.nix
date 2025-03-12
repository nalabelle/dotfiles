{ pkgs, system, ... }:
let 
  extraNodePackages = import ./node {
    inherit pkgs system;
    nodejs = pkgs.nodejs_22;
  };
in
{
  home.packages = with pkgs; [
    bash

    extraNodePackages."@anthropic-ai/claude-code"
  ];

  targets.darwin = {
    # Testing to see if this changes anything
    currentHostDefaults = {
      "com.apple.dock" = {
        tilesize = 96;
        orientation = "left";
      };
    };

    # If this doesn't work, move the file in place with: 
    # https://wiki.nixos.org/wiki/Home_Manager#Managing_your_dotfiles
    # Notably, this seems to drop the file in using plist syntax, but the file I had before was
    # in a structure closer to JSON (see ./DefaultKeyBinding.dict)
    keybindings = {
/*

Key Modifiers
^ : Ctrl
$ : Shift
~ : Option (Alt)
@ : Command (Apple)
# : Numeric Keypad

Non-Printable Key Codes

Up Arrow:     \UF700        Backspace:    \U0008        F1:           \UF704
Down Arrow:   \UF701        Tab:          \U0009        F2:           \UF705
Left Arrow:   \UF702        Escape:       \U001B        F3:           \UF706
Right Arrow:  \UF703        Enter:        \U000A        ...
Insert:       \UF727        Page Up:      \UF72C
Delete:       \UF728        Page Down:    \UF72D
Home:         \UF729        Print Screen: \UF72E
End:          \UF72B        Scroll Lock:  \UF72F
Break:        \UF732        Pause:        \UF730
SysReq:       \UF731        Menu:         \UF735
Help:         \UF746

https://gist.github.com/Jimbly/9471958
http://xahlee.info/kbd/osx_keybinding.html
http://xahlee.info/kbd/osx_keybinding_action_code.html

*/

      "\UF729"    = "moveToBeginningOfParagraph:"; # home
      "\UF72B"    = "moveToEndOfParagraph:"; # end
      "$\UF729"   = "moveToBeginningOfParagraphAndModifySelection:"; # shift-home
      "$\UF72B"   = "moveToEndOfParagraphAndModifySelection:"; # shift-end
      "^\UF729"   = "moveToBeginningOfDocument:"; # ctrl-home
      "^\UF72B"   = "moveToEndOfDocument:"; # ctrl-end
      "^$\UF729"  = "moveToBeginningOfDocumentAndModifySelection:"; # ctrl-shift-home
      "^$\UF72B"  = "moveToEndOfDocumentAndModifySelection:"; # ctrl-shift-end
      "\UF72C"    = "pageUp:";
      "\UF72D"    = "pageDown:";

      # select all
      "^a"        = "(moveToBeginningOfDocument:, moveToEndOfDocumentAndModifySelection:)";
      "^x"        = "cut:"; # ctrl+c  - cut
      "^v"        = "paste:"; # ctrl+v - paste
      "^$v"       = "pasteAsPlainText:"; # shift+ctrl+v paste as plain text
      "^c"        = "copy:"; # ctrl+c - copy
      "^z"        = "undo:"; # ctrl+z - undo
      "^$z"       = "redo:"; # ctrl+z - undo

      "^\UF702"  = "moveWordBackward:"; # ctrl+<-
      "^\UF703"  = "moveWordForward:"; # ctrl+->
      "$^\UF702" = "moveWordBackwardAndModifySelection:"; # shift+ctrl+<-
      "$^\UF703" = "moveWordForwardAndModifySelection:"; # shift+ctrl+->
    };
  };
}

