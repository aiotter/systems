{ pkgs, config, ... }: {
  programs.tmux = {
    enable = true;

    extraConfig = ''
      ${builtins.readFile ./tmux.conf}

      # prefix-x で何かを kill
      bind-key x display-menu -T 'Kill what?' \
        Process p "display-menu -T 'By which signal?' \
          '1  SIGHUP'  h 'run-shell \"kill -1  $(\"${./get-current-process-pid}\")\"' \
          '2  SIGINT'  i 'run-shell \"kill -2  $(\"${./get-current-process-pid}\")\"' \
          '3  SIGQUIT' Q 'run-shell \"kill -3  $(\"${./get-current-process-pid}\")\"' \
          '9  SIGKILL' k 'run-shell \"kill -9  $(\"${./get-current-process-pid}\")\"' \
          '15 SIGTERM' t 'run-shell \"kill -15 $(\"${./get-current-process-pid}\")\"' \
        " \
        Pane P kill-pane \
        Window w kill-window \
        Session s "run-shell 'tmux switch-client -n \\\; kill-session -t \"\$(tmux display-message -p \"#S\")\"'" \
        Server S kill-server

      # 設定ファイルをリロードする
      bind r source-file "${config.xdg.configHome}/tmux/tmux.conf" \; display "Reloaded!"

      # セッションのナンバリングを詰める
      set-hook -g session-created "run ${./reorder-sessions.sh}"
      set-hook -g session-closed  "run ${./reorder-sessions.sh}"

      # ペインボーダーに情報を表示
      set -g pane-border-status bottom
      set -g pane-border-format "#(bash ${./responsive-pane-status.sh} '#{pane_width}' '#{pane_current_command}' '#{pane_pid}' '#{pane_current_path}')"

      # 左パネルを設定する
      set -g status-left-length 40
      set -g status-left "#{prefix_highlight}#(bash ${./responsive-window-status-l.sh} '#{client_width}')"
      # 右パネルを設定する
      set -g status-right-length 60
      set -g status-right "#(bash ${./responsive-window-status-r.sh} '#{client_width}')"
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = prefix-highlight;
        extraConfig = ''
          set -g @prefix_highlight_show_copy_mode 'on'
          set -g @prefix_highlight_prefix_prompt ' ^Q '
          set -g @prefix_highlight_copy_prompt 'Copy'
          set -g @prefix_highlight_copy_mode_attr 'fg=black,bg=yellow'
          set -g @prefix_highlight_empty_prompt ' TMUX '
        '';
      }
    ];
  };
}
