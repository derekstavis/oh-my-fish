function omf.theme.set -a target_theme
  set -l builtin_themes_prompts $__fish_datadir/tools/web_config/sample_prompts/*.fish
  set -l builtin_themes (basename -a -s .fish $builtin_themes_prompts)
  set -l installed_themes (omf.packages.list --installed --theme)

  #echo builtin_themes:
  #printf \t%s\n $builtin_themes

  #echo installed_themes:
  #printf \t%s\n $installed_themes

  if not contains "$target_theme" $builtin_themes $installed_themes
    echo (omf::err)"Theme not installed!"(omf::off)
    echo Install it using (omf::em)omf install $target_theme(omf::off)
    return $OMF_INVALID_ARG
  end

  set -l current_theme (cat $OMF_CONFIG/theme)
  test "$target_theme" = "$current_theme"; and return 0

  #echo theme:
  #printf \t%s\n $theme

  set -l prompt_filename "fish_prompt.fish"
  set -l user_functions_path (omf.xdg.config_home)/fish/functions
  mkdir -p "$user_functions_path"

  #echo user_functions_path:
  #printf \t%s\n $user_functions_path

  # If the theme is a fish builtin theme copy the whole prompt file to user path
  if set -l index (contains -i -- "$target_theme" $builtin_themes)
    set -l selected_theme_path $builtin_themes_prompts[$index]

    # Remove user prompt file and autoload path
    rm -f $user_functions_path/$prompt_filename
    autoload -e {$OMF_CONFIG,$OMF_PATH}/themes/$current_theme

    # Source and save the new prompt
    cp $selected_theme_path $user_functions_path/$prompt_filename
  else
    # Validate user prompt state
    if not omf.check.fish_prompt
      echo (omf::err)"Conflicting prompt setting."(omf::off)
      echo "Run "(omf::em)"omf doctor"(omf::off)" and fix issues before continuing."
      return $OMF_INVALID_ARG
    end

    # Replace autoload paths of current theme with the target one
    autoload -e {$OMF_CONFIG,$OMF_PATH}/themes/$current_theme
    autoload {$OMF_CONFIG,$OMF_PATH}/themes/$target_theme

    # Find target theme's fish_prompt and link to user function path
    set -l prompt {$OMF_CONFIG,$OMF_PATH}/theme?/$target_theme/$prompt_filename
    test -n $prompt
      and ln -sf $prompt $user_functions_path/$prompt_filename

    # If key bindings file found, reload fish key bindings
    test (count {$OMF_CONFIG,$OMF_PATH}/key_binding?.fish) -gt 0
      and functions -q __fish_reload_key_bindings
      and __fish_reload_key_bindings
  end

  # Reload fish key bindings if reload is available and needed
  functions -q __fish_reload_key_bindings
    and test (count {$OMF_CONFIG,$OMF_PATH}/key_binding?.fish) -gt 0
    and __fish_reload_key_bindings

  # Source new theme
  source $user_functions_path/$prompt_filename

  # Persist the changes and return success
  echo "$target_theme" > "$OMF_CONFIG/theme"
  return 0
end
