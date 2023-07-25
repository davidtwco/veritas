{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.helix;
in
{
  options.veritas.configs.helix.enable = mkEnableOption "helix configuration";

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      themes.veritas = {
        "attribute" = { fg = "light-black"; };
        "comment" = { fg = "gray"; modifiers = [ "italic" ]; };
        "comment.line" = { fg = "gray"; modifiers = [ "italic" ]; };
        "comment.block" = { fg = "gray"; modifiers = [ "italic" ]; };
        "comment.block.documentation" = { fg = "light-green"; modifiers = [ "italic" ]; };
        "constant" = { fg = "light-yellow"; };
        "constant.numeric" = { fg = "light-yellow"; };
        "constant.builtin" = { fg = "light-yellow"; };
        "constant.character.escape" = { fg = "light-yellow"; };
        "constructor" = { fg = "white"; };
        "function" = { fg = "light-yellow"; };
        "function.builtin" = { fg = "light-blue"; };
        "function.macro" = { fg = "light-purple"; };
        "keyword" = { fg = "light-blue"; };
        "keyword.storage.modifier" = { fg = "yellow"; };
        "label" = { fg = "light-green"; };
        "punctuation" = { fg = "white"; };
        "punctuation.special" = { fg = "gray"; };
        "namespace" = { fg = "light-cyan"; };
        "operator" = { fg = "white"; };
        "keyword.operator" = { fg = "white"; };
        "special" = { fg = "light-blue"; };
        "string" = { fg = "light-green"; };
        "type" = { fg = "yellow"; };
        "type.builtin" = { fg = "light-red"; };
        "variable" = { fg = "white"; };
        "variable.builtin" = { fg = "light-red"; };
        "variable.parameter" = { fg = "white"; };
        "variable.other.member" = { fg = "white"; };

        "markup.heading" = { fg = "red"; };
        "markup.raw.inline" = { fg = "green"; };
        "markup.raw.block" = { fg = "white"; };
        "markup.bold" = { fg = "yellow"; modifiers = [ "bold" ]; };
        "markup.italic" = { fg = "purple"; modifiers = [ "italic" ]; };
        "markup.list" = { fg = "red"; };
        "markup.quote" = { fg = "yellow"; };
        "markup.link.url" = { fg = "blue"; underline.style = "line"; };
        "markup.link.text" = { fg = "white"; };
        "markup.link.label" = { fg = "white"; };

        "diff.plus" = "green";
        "diff.delta" = "yellow";
        "diff.minus" = "red";

        "diagnostic" = { underline.style = "line"; };
        "info" = { fg = "blue"; modifiers = [ "bold" ]; };
        "hint" = { fg = "green"; modifiers = [ "bold" ]; };
        "warning" = { fg = "yellow"; modifiers = [ "bold" ]; };
        "error" = { fg = "red"; modifiers = [ "bold" ]; };

        "ui.background" = { bg = "background"; };
        "ui.virtual" = { fg = "gray"; };
        "ui.virtual.indent-guide" = { fg = "gray"; };
        "ui.virtual.whitespace" = { fg = "light-black"; };
        "ui.virtual.ruler" = { bg = "black"; };

        "ui.cursor" = { fg = "white"; modifiers = [ "reversed" ]; };
        "ui.cursor.primary" = { fg = "white"; modifiers = [ "reversed" ]; };
        "ui.cursor.match" = { fg = "blue"; underline.style = "line"; };

        "ui.selection" = { bg = "light-black"; };
        "ui.selection.primary" = { bg = "light-black"; };
        "ui.cursorline.primary" = { fg = "yellow"; underline = { color = "yellow"; style = "double_line"; }; };
        "ui.cursorline.secondary" = { underline = { color = "yellow"; style = "line"; }; };

        "ui.linenr" = { fg = "black"; };
        "ui.linenr.selected" = { fg = "yellow"; };

        "ui.statusline" = { fg = "white"; bg = "background"; };
        "ui.statusline.inactive" = { fg = "black"; bg = "background"; };
        "ui.statusline.normal" = { fg = "light-purple"; bg = "background"; };
        "ui.statusline.insert" = { fg = "light-green"; bg = "background"; };
        "ui.statusline.select" = { fg = "light-cyan"; bg = "background"; };
        "ui.text" = { fg = "white"; };
        "ui.text.focus" = { fg = "white"; bg = "light-black"; modifiers = [ "bold" ]; };

        "ui.help" = { fg = "white"; bg = "background"; };
        "ui.popup" = { bg = "background"; };
        "ui.window" = { fg = "background"; };
        "ui.menu" = { fg = "white"; bg = "background"; };
        "ui.menu.selected" = { fg = "light-red"; bg = "background"; };
        "ui.menu.scroll" = { fg = "light-red"; bg = "background"; };

        palette = {
          "background" = "#101010";
          "white" = "#C5C8C6";

          "blue" = "#5F819D";
          "red" = "#A54242";
          "purple" = "#85678F";
          "green" = "#8C9440";
          "yellow" = "#DE935F";
          "cyan" = "#5E8D87";
          "black" = "#282A2E";
          "gray" = "#707880";

          "light-yellow" = "#F0C674";
          "light-blue" = "#81A2BE";
          "light-red" = "#CC6666";
          "light-purple" = "#B294BB";
          "light-green" = "#B5BD68";
          "light-cyan" = "#8ABEB7";
          "light-black" = "#373B41";
          "light-gray" = "#C5C8C6";
        };
      };
      settings = {
        theme = "veritas";
        editor = {
          auto-save = true;
          cursorline = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          color-modes = true;
          line-number = "relative";
          rulers = [ 100 140 180 220 240 ];
          statusline = {
            left = [ "mode" "spinner" "file-name" ];
            center = [ ];
            right = [ "diagnostics" "selections" "position" "file-type" ];
          };
          whitespace = {
            characters.newline = "¬";
            render = "all";
          };
        };
      };
      languages.nix = {
        auto-format = true;
        formatter = { command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"; };
      };
    };
  };
}
