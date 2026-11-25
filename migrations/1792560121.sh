echo "Keep selections of bundled backgrounds replaced by responsive SVGs"

current_dir="$HOME/.local/state/omarchy/current"
staged_backgrounds="$current_dir/theme/backgrounds"
active_theme=$(cat "$current_dir/theme.name" 2>/dev/null || true)

# Only these exact bundled files were replaced. Existing user-theme files and
# external backgrounds are preserved; an old staged file must match its former
# bundled content before we replace its selection.
replacement_svg() {
  local theme=$1 background=$2 name=${2##*/} original_digest source_dir user_dir
  case "$theme/$name" in
  catppuccin-latte/omarchy.webp) original_digest=8482e189755138084295e90f353b8efe8d3e575d7bc3fc3ed756d1e890242d32 ;;
  catppuccin/omarchy.webp) original_digest=24cb9211e2191edefadd093976526d3606167343a636eb9ff123b40d4e594329 ;;
  ethereal/omarchy.webp) original_digest=651b237dfd573aad2da6946d4a87bb4d9c1bec1b4511ce2489effb319e6a1779 ;;
  everforest/omarchy.webp) original_digest=5a7f4ba2911401d90595d73a93e7ed5f5c2eacfad3343eb75b2bf127547c6419 ;;
  flexoki-light/2-omarchy.webp) original_digest=a3a3d457c6547bb8a94dd7da06b14deab572bdf78ae597bb6eb8a6a81b04f0bb ;;
  gruvbox/omarchy.webp) original_digest=08859bab0fd1f3e103bb73b94c3e1ad8a91efc4761a85906063e7cca277c07e9 ;;
  hackerman/omarchy.webp) original_digest=3dd5cd56cd743e4578aa2cfd2eeb536460f14d7b034730205d02b34b8c739c7a ;;
  kanagawa/omarchy.webp) original_digest=e27fe79776337f0e80c2051d6d981c2ee4cca170584f455e27395de4bc3ff6c5 ;;
  lumon/01-united-in-severance.webp) original_digest=cdfb3d4cb22077ed5f2a73ac8822b6c4e3614a210c5947194c046078ab5073a5 ;;
  lumon/omarchy.webp) original_digest=2581cb9d50fcdbf3d426a1f611b610eae157769ddcb6d4e22a8796ade9b8a036 ;;
  lupine/06-omarchy.webp) original_digest=069bca2eb0e28b6c6edbc54940e7a63f647a203d95243b26bdd3f3721e32b21a ;;
  matte-black/omarchy.webp) original_digest=b867ba75dc29b073f43e22170a48a8f80365939b16481a54541184ab13d98cec ;;
  miasma/omarchy.webp) original_digest=5081d894e997352ec6d0e3085a6bedf41e45b2a0f13d43df58ffb634dac69d5a ;;
  nord/omarchy.webp) original_digest=877160694eb975f33d7fc25e542e248c48994540f46eba928a48c22c2e0ffe60 ;;
  osaka-jade/omarchy.webp) original_digest=c3d1300d8fe70de7ad98e6a12e5e3d179d862e2a944b534a3bc83dbc7f079a4e ;;
  retro-82/omarchy.webp) original_digest=08fbd2db38c5fac9ea15de7f449db0bf0e70cf5c77fe02ed016834d545c4e872 ;;
  ristretto/omarchy.webp) original_digest=d2db907ffc0655c73bbfb29e7d17796341d8d3bdfad72d7a3c3b408b1e996582 ;;
  rose-pine/omarchy.webp) original_digest=16822b99638ea53c1e115a3b1ccde7e9a1d1125f9f00621afba31d8f947cff5a ;;
  tokyo-night/omarchy.webp) original_digest=ef9c6d4c7763a1d56e97e4e5300ffd45d10995e35273e8b16d3a1e4b36a45566 ;;
  vantablack/omarchy.webp) original_digest=7575cee823ff9bb253be3f1f92b87bfac4c99daca770d9166a000d1ce4d2b03d ;;
  white/omarchy.webp) original_digest=4f59ff985e0bf7d1518a3e0de6d2757cb6a2cbd5fb0fd2c4918853cee5f8fad7 ;;
  *) return 1 ;;
  esac
  source_dir="$OMARCHY_PATH/themes/$theme/backgrounds"
  user_dir="$HOME/.config/omarchy/themes/$theme/backgrounds"
  [[ ${background%/*} == "$staged_backgrounds" || ${background%/*} == "$source_dir" ]] || return 1
  [[ ! -L $user_dir && ! -e $user_dir/$name && ! -L $user_dir/$name && ! -e $user_dir/${name%.webp}.svg && ! -L $user_dir/${name%.webp}.svg ]] || return 1
  [[ ! -e $source_dir/$name && -f $source_dir/${name%.webp}.svg ]] || return 1
  if [[ ${background%/*} != "$staged_backgrounds" || $theme == "$active_theme" ]]; then
    if [[ -e $background ]]; then
      [[ $(sha256sum <"$background") == "$original_digest  -" ]] || return 1
    fi
  fi
  SVG_SOURCE="$source_dir/${name%.webp}.svg"
  SVG_REPLACEMENT="${background%.webp}.svg"
}

stage_replacement() {
  local metadata_source metadata="$staged_backgrounds/backgrounds.toml"
  if [[ ${SVG_REPLACEMENT%/*} == "$staged_backgrounds" && $1 == "$active_theme" ]]; then
    mkdir -p "$staged_backgrounds"
    if [[ ! -e $SVG_REPLACEMENT ]]; then
      cp "$SVG_SOURCE" "$SVG_REPLACEMENT"
    fi
    # Old staged themes predate responsive metadata. Preserve any staged/user
    # settings and otherwise install the same metadata as a fresh theme stage.
    if [[ ! -e $metadata && ! -L $metadata ]]; then
      metadata_source="$HOME/.config/omarchy/themes/$1/backgrounds/backgrounds.toml"
      if [[ ! -f $metadata_source ]]; then
        metadata_source="$OMARCHY_PATH/themes/$1/backgrounds/backgrounds.toml"
      fi
      if [[ -f $metadata_source ]]; then
        cp "$metadata_source" "$metadata"
      fi
    fi
  fi
}

current_background="$current_dir/background"
if [[ -L $current_background ]]; then
  background=$(readlink "$current_background")
  if replacement_svg "$active_theme" "$background"; then
    stage_replacement "$active_theme"
    ln -sfn "$SVG_REPLACEMENT" "$current_background"
    omarchy-shell -q background set "$SVG_REPLACEMENT" || true
  fi
fi

for state_file in "$HOME/.local/state/omarchy/theme-backgrounds/"*; do
  [[ -f $state_file ]] || continue
  theme=${state_file##*/}
  background=$(<"$state_file")
  if replacement_svg "$theme" "$background"; then
    stage_replacement "$theme"
    printf '%s\n' "$SVG_REPLACEMENT" >"$state_file"
  fi
done
