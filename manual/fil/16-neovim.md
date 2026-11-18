# Neovim

Ang [Neovim](https://neovim.io/) ay isang modernong implementasyon ng [vi editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) na nilikha ni Bill Joy noon pa mang 1976. Isa itong modal editor kung saan hiwalay ang insert mode at command mode, at isa itong uri ng superpower kapag natutunan mo kahit isang subset lang ng hindi kapani-paniwalang malalim na set ng mga key command. Ngunit medyo matarik din ang learning curve nito!

Kung lubos kang bago sa pag-edit na istilong vim, inirerekomenda kong tingnan mo ang [serye ni ThePrimeagen na Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) sa YouTube. Tuturuan ka niyon ng mga batayan. Alamin mo lang na hindi tulad ng mga katulad na mainstream editor, mas matatagalan kang makakuha ng pangunahing kahusayan sa vim. Ngunit kapag nagawa mo na, mas malaki rin ang gantimpala.

Ngayon, ang Neovim ay halos walang katapusan ang configurability. Kung talagang gusto mong magpakasaya, maaari kang gumawa ng sarili mong configuration ng Neovim mula sa simula. Mayroong isang mahusay na kurso mula sa [Typecraft tungkol sa pag-setup ng Neovim mula sa simula](https://www.youtube.com/watch?v=zHTeCSVAFNY). At [mayroon din si ThePrimeagen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ngunit ang Omarchy ay ipinapadala na may kumpletong setup ng Neovim — ang `omarchy-nvim` package — na maingat na na-tune para ipakita ang pinakamahusay sa kung ano ang posible mula sa simula. Nang hindi mo kailangang magsulat ng isang linya ng configuration! Ito ay binuo sa [LazyVim](https://www.lazyvim.org/), isang distribusyon ng mga plugin at configuration ng Neovim. Kahanga-hanga ito.

## Mga Batayan ng LazyVim

Tulad ng nabanggit, hindi kita tuturuan ng vim sa maikling pagpapakilalang ito, ngunit maaari kong ipakita sa iyo ang ilang batayan ng LazyVim, at kung paano maglibot.

Una, may ideya ang Neovim ng leader key. Iyan talaga ang gateway sa lahat ng command. Itinakda iyon ng LazyVim sa `Space`. Kaya pindutin mo lang iyon, maghintay ng isang segundo, at makikita mo ang isang bungkos ng mga opsyon na ipinaliwanag nang inline nang ganito:

Narito ang ilang pangunahing command na ginagamit ko sa lahat ng oras:

- `Space Space` - Fuzzy-find ang anumang file sa kasalukuyang directory.
- `Space S G` - Maghanap sa lahat ng file gamit ang grep na may preview.
- `Space E` - I-toggle ang file tree on/off.
- `Ctrl + W W` - Tumalon mula sa file tree papunta sa editor at pabalik.
- `Shift + H` - Lumipat pa-kaliwa sa pagitan ng mga bukas na tab (tinatawag silang buffer ng vim).
- `Shift + L` - Lumipat pa-kanan sa pagitan ng mga bukas na tab.
- `Space B D` - Isara ang isang tab.
- `Space B O` - Isara ang lahat ng iba pang tab maliban sa kasalukuyan.
- `Space G G` - Ilunsad ang LazyGit sa isang lumulutang na pane mula sa kasalukuyang directory.
- `Space U W` - I-toggle ang soft wrap.

Habang nasa file tree ka (`Space E` para ipakita, `Ctrl + W W` para tumalon papunta roon), maaari kang magdagdag ng bagong file gamit ang `a` o ng bagong directory gamit ang `A`. Pindutin ang `?` habang nasa tree para makita ang lahat ng command.

Kung gusto mong matutunan ang pangunahing wika ng vim, nagsulat ako tungkol sa [tatlong-bahaging syntax](https://world.hey.com/dhh/wonderful-vi-a1d034d3) at kung paano gawin ang mga kahanga-hangang combo move na iyon!

Makikita mo ang lahat ng posibleng command sa [pahina ng LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pagsisimula ng Neovim

Maaari mong simulan ang Neovim gamit ang `Super + Shift + N` (inilulunsad ng binding ang iyong default editor, na Neovim mula sa simula), ngunit karaniwan ay mas madaling maneho ito mula sa terminal sa pamamagitan ng pag-navigate sa directory na gusto mong trabahuin at pag-type ng `n`. Ang `n` ang alias para sa `nvim`, na gagamitin ang kasalukuyang directory para buksan bilang default. Maaari kang magbukas ng isang file gamit ang `n myfile.txt`.

## Paggamit ng Neovim para sa mga sudo edit

Kung kailangan mong mag-edit ng mga file na mababago mo lang bilang isang super user, maaari mong gamitin ang neovim na naka-setup ang lahat ng iyong plugin sa pamamagitan ng pagpapatakbo ng `sudoedit /etc/sudoers.d/00-sudo-only-file`.
