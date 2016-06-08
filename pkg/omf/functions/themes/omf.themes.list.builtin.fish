function omf.themes.list.builtin
  set -l builtin_themes $__fish_datadir/tools/web_config/sample_prompts/*.fish
  basename -a -s .fish $builtin_themes
end