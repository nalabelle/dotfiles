{
  config,
  lib,
  pkgs,
  ...
}:

let
  zedSettings = {
    git_panel = {
      tree_view = true;
      dock = "right";
    };
    language_models = {
      openai_compatible = {
        "OpenCode Zen" = {
          api_url = "https://opencode.ai/zen/go/v1";
          available_models = [
            {
              name = "kimi-k2.5";
              max_tokens = 262144;
              max_output_tokens = 32768;
              max_completion_tokens = 32000;
              capabilities = {
                tools = true;
                images = true;
                parallel_tool_calls = true;
                prompt_cache_key = true;
                chat_completions = true;
              };
            }
            {
              name = "glm-5";
              max_tokens = 202752;
              max_output_tokens = 32768;
              max_completion_tokens = 32000;
              capabilities = {
                tools = true;
                images = true;
                parallel_tool_calls = true;
                prompt_cache_key = true;
                chat_completions = true;
              };
            }
          ];
        };
      };
    };
    edit_predictions = {
      open_ai_compatible_api = {
        api_url = "https://opencode.ai/zen/go/v1/chat/completions";
        model = "kimi-k2.5";
      };
    };
    agent_servers = {
      opencode = {
        type = "registry";
        favorite_models = [
          "opencode-go/kimi-k2.5"
          "opencode-go/glm-5"
          "opencode/claude-sonnet-4-6"
          "opencode/claude-opus-4-6"
        ];
      };
    };
    vim = {
      use_system_clipboard = "on_yank";
    };
    context_servers = { };
    agent = {
      dock = "right";
      default_profile = "write";
      enable_feedback = true;
      single_file_review = true;
      model_parameters = [ ];
      default_model = {
        enable_thinking = false;
        provider = "OpenCode Zen";
        model = "kimi-k2.5";
      };
    };
    vim_mode = true;
    telemetry = {
      diagnostics = false;
      metrics = false;
    };
    ui_font_size = 16;
    buffer_font_size = 16;
    theme = {
      mode = "system";
      light = "One Light";
      dark = "Ayu Dark";
    };
  };

  zedSettingsJson = pkgs.writeText "zed-settings.json" (builtins.toJSON zedSettings);

  deployScript = pkgs.writeShellApplication {
    name = "zed-deploy-config";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./deploy-config;
  };
in
{
  home.activation.zedDeploy = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    ${deployScript}/bin/zed-deploy-config \
      "${zedSettingsJson}" \
      "${config.xdg.configHome}/zed/settings.json" \
      "${config.xdg.configHome}/zed" \
      30
  '';
}
