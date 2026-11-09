# Pagtulog ng sistema

Sa Omarchy, naka-enable ang suspend at hibernation bilang default, pero kung nagkakaproblema ka sa alinman sa mga ito sa machine mo, puwede mo silang i-toggle off.

Sa mga NVIDIA GB10 machine, gaya ng DGX Spark at ng ASUS Ascent GX10, naka-off ang suspend at hibernation, tulad sa DGX OS ng NVIDIA, dahil hindi pa napapatunayang gumagana ang sleep sa hardware na iyon. Ganoon din sa ASUS Zenbook A16 (UX3607OA), kung saan hindi pa ganap na napapatulog ng suspend ang chip at puwede itong mag-hang sa buong gabi. Hindi naaangkop doon ang toggle ng suspend at ang pag-setup ng hibernation. Para i-on ulit ang sleep, alisin ang `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` gamit ang `sudo rm`; babalik ang Suspend sa menu, at puwedeng i-setup ang hibernation tulad sa ibang machine. Ibabalik ng pagpapatakbo ng `sudo omarchy apply hardware --install-user "$USER"` ang file.

### Mga power profile

Sa laptop, hiwalay na tinatandaan ng Omarchy ang power profile mo para kapag nakasaksak at kapag nasa baterya, at lumilipat ito sa pagitan ng dalawa habang nagsasaksak at nagtatanggal ka ng plug. Paglabas ng kahon, performance iyon sa AC at balanced sa baterya.

Makikita mo kung ano ang inaalok ng machine mo gamit ang `omarchy powerprofiles list`, at itakda ang gusto mo para sa state na kinaroroonan mo ngayon gamit ang `omarchy powerprofiles set autodetect power-saver`. Para itakda ang kabilang state nang walang tinatanggal na plug, tuwirang pangalanan ito: `omarchy powerprofiles set battery power-saver`. Ano man ang piliin mo, iyon din ang makukuha mo sa susunod na nasa state na iyon ka.

### I-toggle ang suspend

Ito-toggle mo ang suspend sa pagpapatakbo ng `omarchy toggle suspend` mula sa terminal. Ipinapakita/nagtatago lang niyan ang option sa ilalim ng _System_ (o `Super + Esc`), at makikita mo pagkatapos kung tuloy-tuloy itong gumagana sa sistema mo. Kung hindi, puwede mo itong itago ulit gamit ang parehong command.

### I-toggle ang hibernation

Ise-setup mo ang hibernation sa pagpapatakbo ng `omarchy hibernation setup` mula sa terminal. Gumagawa ang hibernation ng /swap subvolume sa boot drive mo na kasinlaki ng physical RAM allocation mo, kaya siguraduhing marami kang natitirang espasyo. Sa isang 32GB machine, palagi kang mangangailangan ng 32GB+ na libre para sa volume na ito. Kinakailangan din ng hibernation ang default na Limine bootloader.

Kapag na-setup na, makikita mo ang hibernate option sa ilalim ng _System_ (o `Super + Esc`), at makikita mo pagkatapos kung tuloy-tuloy itong gumagana sa sistema mo. Kung hindi, puwede mo itong alisin ulit sa pagpapatakbo ng `omarchy hibernation remove`.
