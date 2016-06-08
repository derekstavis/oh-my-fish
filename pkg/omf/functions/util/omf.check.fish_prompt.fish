function omf.check.fish_prompt
  set -l theme (cat $OMF_CONFIG/theme)
  #echo theme: \n\t$theme

  set -l conf_path (omf.xdg.config_home)
  set -l user_prompt_path $conf_path/fish/functions/fish_promp?.fish
  set -l user_prompt_path (readlink $user_prompt_path)

  #echo user_prompt_path: \n\t$user_prompt_path

  # No issue if prompt file does not exist
  test (count $user_prompt_path) = 0
    and return 0

  set -l prompts_paths {$OMF_CONFIG,$OMF_PATH}/theme?/$theme/{,functions/}fish_prompt.fish \
                       $__fish_datadir/tools/web_config/sample_prompt?/$theme.fish

  #echo prompts_paths: \n\t$prompts_paths

  # Check if the prompt file points to a valid path
  contains -- "$user_prompt_path" $prompts_paths
end
