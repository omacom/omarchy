# A region's package mirrors that only config files can set (RubyGems and
# Bundler, Composer, Cargo), seeded into the home without replacing a file the
# user already has (docs/regions.md).
home="$OMARCHY_PATH/default/regions/$(omarchy-region)/home"
if [[ -d $home ]]; then
  cp -r --update=none "$home/." ~/
fi
