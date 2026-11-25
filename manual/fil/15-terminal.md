# Terminal

Ang [Foot](https://codeberg.org/dnkl/foot) ang default na terminal para sa Omarchy. Mabilis ito, magaan, at tugma kahit sa mga lumang computer. Hindi nito, gayunpaman, sinusuportahan ang mga native na tab o split.

Kung gumagamit ka ng Tmux, maaaring hindi mo ito alintanain, ngunit kung hindi, ganap naming sinusuportahan ang _Alacritty_, _Ghostty_, at _Kitty_ bilang mga opsyon din. Piliin ang iyong kagustuhan sa ilalim ng _I-install > Terminal_ sa menu ng Omarchy.

Nagsisimula ka ng bagong terminal gamit ang `Super + Return`. (Awtomatikong tuturo ang binding na ito sa anumang Terminal na na-install mo sa pamamagitan ng _I-install > Terminal_, at maaari kang lumipat sa pagitan ng mga naka-install na terminal sa ilalim ng _Pag-setup > Mga Default > Terminal_.)

## Tmux

Nagbibigay ang Tmux ng isang pare-pareho, programmable na interface para sa mga pane, bintana (aka mga tab), at mga resumable na session anuman ang iyong terminal. Gumagana ito kahit sa mga remote host, kaya kapag nag-SSH ka sa isang server, maaari mong gamitin ang parehong diskarte.

Nagsisimula ka ng bagong session ng Tmux sa isang bagong terminal gamit ang `Super + Alt + Return`, at dahil ang Tmux ay isang persistent na proseso, maaari mong ipagpatuloy ang iyong session kahit isara mo ang terminal na iyon. Pindutin lang ang `Ctrl + Space` (tinatawag na prefix key) pagkatapos ang `s` para makita ang lahat ng iyong aktibong session.

Ang Omarchy ay ipinapadala na may ergonomically-optimized na configuration ng Tmux, na maraming keybinding na matututunan, kaya panatilihing madaling maabot ang [cheatsheet](07-hotkeys.md#tmux).

## Mga function ng layout ng Tmux

Dahil programmable ang Tmux, maaari tayong gumamit ng mga function para gumawa ng mga layout. Ang Omarchy ay ipinapadala na may apat na magkakaibang function para sa mga karaniwang layout ng developer.

Ang `tdl [agent]` ay nagsisimula ng isang three-way split na istilong IDE na interface na may `$EDITOR` sa kaliwa, ang iyong napiling AI agent sa kanan (tulad ng `c` para sa opencode o `cx` para sa Claude o `codex` para sa OpenAI), at pagkatapos ay isang terminal sa ibaba.

Kaya ang `tdl c` ay magsisimula nito (o `ic` lang):

 ![tmux-tdl](images/tmux-tdl.webp)

Maaari ka ring magsimula ng pangalawang agent gamit ang `tdl c cx` (opencode + claude) (o `icx` lang):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Mayroon ding `tds`, na nagsisimula ng isang four-way square na may editor sa itaas kaliwa, isang live diff watcher sa itaas kanan, isang terminal sa ibaba kaliwa, at opencode sa ibaba kanan.

Maaari mo ring simulan ang configuration ng layout na ito para sa bawat subdirectory sa kasalukuyang directory gamit ang `tdlm [agent]`, pagkatapos ay mag-navigate gamit ang `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Sa wakas, maaari kang magsimula ng isang swarm ng mga agent gamit ang `tsl [panes] [command]`. Kaya ang `tsl 4 c` ay magbibigay sa iyo ng isang four-way grid ng mga opencode agent:

 ![tmux-tsl](images/tmux-tsl.webp)
