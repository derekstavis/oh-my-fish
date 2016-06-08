function omf.cli.themes.list
  set -l theme (cat $OMF_CONFIG/theme)
  set -l regex_current "(^|[[:space:]])($theme)([[:space:]]|\$)"
  set -l highlight_current s/"$regex_current"/"\1"(omf::em)"\2"(omf::off)"\3"/g
  set -l installed (omf.packages.list --installed --theme) \
                   (omf.themes.list.builtin)

  echo (omf::under)"Installed:"(omf::off)
  echo $installed | tr ' ' '\n' | sort | column | sed -E "$highlight_current"
  echo
  echo (omf::under)"Available:"(omf::off)
  omf.packages.list --available --theme | column
end