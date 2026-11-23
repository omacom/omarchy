# Pagtulog ng sistema

Naka-enable ang suspend sa Omarchy bilang default, at ang hibernation kapag na-set up na ito, pero kung nagkakaproblema ka sa alinman sa mga ito sa makina mo, puwede mong i-off ang mga ito.

Sa mga makinang NVIDIA GB10, gaya ng DGX Spark at ASUS Ascent GX10, naka-off ang suspend at hibernation, gaya rin sa DGX OS ng NVIDIA, dahil hindi pa napapatunayang gumagana ang sleep sa hardware na iyon. Ganoon din sa ASUS Zenbook A16 (UX3607OA), kung saan hindi pa tuluyang napapatulog ng suspend ang chip at puwede itong mag-hang nang magdamag. Hindi naaangkop doon ang toggle ng suspend at ang pag-set up ng hibernation. Para i-on ulit ang sleep, alisin ang `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` gamit ang `sudo rm`; babalik na ang Suspend sa menu, at puwede nang i-set up ang hibernation gaya sa ibang makina. Ibabalik ng pagpapatakbo ng `sudo omarchy apply hardware --install-user "$USER"` ang file.

### Mga power profile

Sa laptop, naaalala ng Omarchy ang power profile mo nang hiwalay para sa nakasaksak at para sa tumatakbo sa baterya, at nagpapalipat-lipat ito sa dalawa habang nagsasaksak at nagbubunot ka. Pagkakakuha mo pa lang, ibig sabihin niyan ay performance sa AC at balanced sa baterya.

Makikita mo kung ano ang iniaalok ng makina mo gamit ang `omarchy powerprofiles list`, at maitatakda mo ang gusto mo para sa estadong kinalalagyan mo ngayon gamit ang `omarchy powerprofiles set autodetect power-saver`. Para itakda ang kabilang estado nang hindi nagbubunot ng anuman, pangalanan mo ito nang direkta: `omarchy powerprofiles set battery power-saver`. Kung ano ang piliin mo, iyon ang makukuha mo ulit sa susunod na mapunta ka sa estadong iyon.

### I-toggle ang suspend

Itina-toggle mo ang suspend sa pamamagitan ng pagpapatakbo ng `omarchy toggle suspend` mula sa terminal. Ipinapakita/itinatago lang niyan ang opsyon sa ilalim ng _System_ (o `Super + Esc`), at makikita mo na kung gumagana ito nang tuluy-tuloy sa sistema mo. Kung hindi, puwede mo itong itago ulit gamit ang parehong command.

### I-toggle ang hibernation

Isine-set up mo ang hibernation sa pamamagitan ng pagpapatakbo ng `omarchy hibernation setup` mula sa terminal (hindi ito available sa mga Apple Silicon Mac). Gumagawa ang hibernation ng /swap subvolume sa boot drive mo na kasinglaki ng alokasyon ng pisikal mong RAM, kaya siguraduhing marami kang natitirang espasyo. Sa makinang 32GB, palagi kang mangangailangan ng 32GB+ na libre para sa volume na ito. Nangangailangan din ang hibernation ng default na Limine bootloader.

Kapag na-set up na, makikita mo ang opsyong hibernate sa ilalim ng _System_ (o `Super + Esc`), at makikita mo na kung gumagana ito nang tuluy-tuloy sa sistema mo. Kung hindi, puwede mo itong alisin ulit sa pamamagitan ng pagpapatakbo ng `omarchy hibernation remove`.
