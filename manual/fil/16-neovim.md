# Neovim

Ang [Neovim](https://neovim.io/) ay isang modernong implementasyon ng [vi editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) na nilikha ni Bill Joy noon pang 1976. Isa itong modal editor kung saan magkahiwalay ang insert mode at command mode, at isa itong medyo superpower kapag natutunan mo kahit subset lang ng napakalalim na set ng mga key command. Pero medyo matarik din ang learning curve nito!

Kung talagang bago ka sa vim-style na pag-edit, inirerekomenda kong tingnan mo ang [Vim As Your Editor series ni ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) sa YouTube. Ituturo niyan sa iyo ang mga pangunahing kaalaman. Alamin mo lang na hindi tulad ng mas magkakatulad na mainstream editor, mas magtatagal ka bago magkaroon ng pangunahing kahusayan sa vim. Pero kapag natutunan mo na, mas malaki rin ang balik.

Ngayon, halos walang hanggan ang maaaring i-configure sa Neovim. Kung talagang gusto mong magpakalabis, maaari kang gumawa ng sarili mong configuration ng Neovim mula sa simula. May mahusay na kurso mula sa [Typecraft tungkol sa pag-set up ng Neovim mula sa simula](https://www.youtube.com/watch?v=zHTeCSVAFNY). At [mayroon din ang ThePrimeagen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Pero kasama ng Omarchy ang isang kumpletong setup ng Neovim — ang `omarchy-nvim` package — na maingat na inayos upang ipakita ang pinakamahusay na posible agad-agad. Nang hindi mo kailangang magsulat ng kahit isang linya ng configuration! Nakabatay ito sa [LazyVim](https://www.lazyvim.org/), isang distribution ng mga plugin at configuration ng Neovim. Napakahusay nito.

## Mga Pangunahin sa LazyVim

Gaya ng nabanggit, hindi ko ituturo sa iyo ang vim sa maikling panimulang ito, pero maaari kong ipakita sa iyo ang ilang pangunahing kaalaman sa LazyVim, at kung paano maglibot dito.

Una, may konsepto ang Neovim ng leader key. Iyon talaga ang daanan patungo sa lahat ng command. Itinakda iyan ng LazyVim sa `Space`. Kaya pindutin mo lang iyan, maghintay ng isang segundo, at makikita mo ang maraming opsyon na ipinaliwanag inline tulad nito:

Narito ang ilang pangunahing command na ginagamit ko palagi:

- `Space Space` - Mag-fuzzy-find ng anumang file sa kasalukuyang directory.
- `Space S G` - Maghanap sa lahat ng file gamit ang grep na may preview.
- `Space E` - I-on/off ang file tree.
- `Ctrl + W W` - Tumalon mula sa file tree papunta sa editor at pabalik.
- `Shift + H` - Lumipat pakaliwa sa pagitan ng mga bukas na tab (tinatawag silang buffers ng vim).
- `Shift + L` - Lumipat pakanan sa pagitan ng mga bukas na tab.
- `Space B D` - Isara ang isang tab.
- `Space B O` - Isara ang lahat ng iba pang tab maliban sa kasalukuyan.
- `Space G G` - Buksan ang LazyGit sa isang floating pane mula sa kasalukuyang directory.
- `Space U W` - I-toggle ang soft wrap.

Habang nasa file tree ka (`Space E` para ipakita, `Ctrl + W W` para tumalon doon), maaari kang magdagdag ng bagong file gamit ang `a` o ng bagong directory gamit ang `A`. Pindutin ang `?` habang nasa tree para makita ang lahat ng command.

Kung gusto mong matutunan ang pangunahing wika ng vim, sumulat ako tungkol sa [tatlong-bahaging syntax](https://world.hey.com/dhh/wonderful-vi-a1d034d3) at kung paano isagawa ang mga astig na combo move na iyon!

Makikita mo ang lahat ng posibleng command sa [pahina ng LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pagbubukas ng Neovim

Binubuksan ng `Super + Shift + N` ang iyong default editor, na Plain sa mga bagong install; piliin ang Neovim sa ilalim ng _Setup > Defaults > Editor_ para Neovim ang buksan nito sa halip. Pero karaniwang mas madaling patakbuhin ito mula sa terminal sa pamamagitan ng pagpunta sa directory na gusto mong pagtrabahuhan at pag-type ng `n`. Ang `n` ang alias para sa `nvim`, na gagamit sa kasalukuyang directory para magbukas bilang default. Maaari kang magbukas ng isang file gamit ang `n myfile.txt`.

## Paggamit ng Neovim para sa mga pag-edit na sudo

Kung kailangan mong mag-edit ng mga file na mababago mo lang bilang super user, patakbuhin ang `sudoedit /etc/sudoers.d/00-sudo-only-file`. Binubuksan nito ang iyong default editor, kaya itakda ang Neovim sa ilalim ng _Setup > Defaults > Editor_ kung gusto mo ito roon kasama ang lahat ng iyong plugin.
