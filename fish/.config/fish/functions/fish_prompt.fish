set fish_git_dirty_color red
set fish_git_not_dirty_color green
set fish_status_color magenta

function parse_git_branch
  set -l branch (git branch 2> /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')
  if math (string length $branch)" > 15" >/dev/null
    set branch (string sub -s 1 -l 9 $branch)..(string sub -s (math (string length $branch) - 3) -l 4 $branch)
  end
  set -l git_diff (git diff)

  if test -n "$git_diff"
    echo " ["(set_color $fish_git_dirty_color)$branch(set_color normal)
  else
    echo " ["(set_color $fish_git_not_dirty_color)$branch(set_color normal)
  end
end

function fish_prompt --description 'Write out the prompt'
  set -l last_status $status
  set -l normal (set_color normal)

  # Hack; fish_config only copies the fish_prompt function (see #736)
  if not set -q -g __fish_classic_git_functions_defined
    set -g __fish_classic_git_functions_defined

    function __fish_repaint_status --on-variable fish_color_status --description "Event handler; repaint when fish_color_status changes"
      if status --is-interactive
        commandline -f repaint ^/dev/null
      end
    end

    function __fish_repaint_bind_mode --on-variable fish_key_bindings --description "Event handler; repaint when fish_key_bindings changes"
      if status --is-interactive
        commandline -f repaint ^/dev/null
      end
    end
  end

  set -l color_cwd
  set -l prefix

  set color_cwd $fish_color_cwd

  set -l prompt_status
  if test $last_status -ne 0
    set prompt_status ":"(set_color $fish_status_color) "$last_status" "$normal" "]"
  else
    set prompt_status "]"
  end

  set -l mode_str
  set -l git_dir (git rev-parse --git-dir 2> /dev/null)
  if test -n "$git_dir"
    echo -n -s (date +%H:%M) " " (set_color $color_cwd) (prompt_pwd) $normal (parse_git_branch) $normal $prompt_status "$mode_str" " "
  else
    echo -n -s (date +%H:%M) " " (set_color $color_cwd) (prompt_pwd) $normal $prompt_status "$mode_str" " "
  end
end
