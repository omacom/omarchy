# Pagtulog ng sistema

Pinapagana ng Omarchy ang suspend bilang default, at ang hibernation kapag na-setup na ito, pero kung nagkakaroon ka ng mga isyu sa alinman sa makina mo, puwede mong i-toggle off ang mga ito.

Sa mga makinang NVIDIA GB10, gaya ng DGX Spark at ng ASUS Ascent GX10, naka-off ang suspend at hibernation, gaya sa DGX OS ng NVIDIA, dahil hindi pa naipapakitang gumagana ang sleep sa hardware na iyon. Hindi nalalapat doon ang toggle ng suspend at ang setup ng hibernation. Para i-on ulit ang sleep, alisin ang `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` gamit ang `sudo rm`; babalik ang Suspend sa menu, at puwedeng i-setup ang hibernation gaya sa ibang mga makina. Ibabalik ng pagpapatakbo ng `sudo omarchy apply hardware --install-user "$USER"` ang file.

### Mga profile ng power

Sa isang laptop, naaalala ng Omarchy ang power profile mo nang hiwalay para sa nakasaksak at sa tumatakbo sa baterya, at nagpapalipat-lipat sa dalawa habang nagsasaksak at nagbubunot ka. Out of the box, ibig sabihin niyan ay performance sa AC at balanced sa baterya.

Makikita mo kung ano ang iniaalok ng makina mo gamit ang `omarchy powerprofiles list`, at puwede mong itakda ang gusto mo para sa estadong kinalalagyan mo ngayon gamit ang `omarchy powerprofiles set autodetect power-saver`. Para itakda ang kabilang estado nang hindi nagbubunot ng kahit ano, pangalanan ito nang direkta: `omarchy powerprofiles set battery power-saver`. Kung ano ang piliin mo ay siya ring makukuha mo sa susunod na mapunta ka sa estadong iyon.

### I-toggle ang suspend

Ito-toggle mo ang suspend sa pamamagitan ng pagpapatakbo ng `omarchy toggle suspend` mula sa terminal. Ipinapakita/itinatago lang niyan ang opsyon sa ilalim ng _System_ (o `Super + Esc`), at makikita mo kung palagiang gumagana ito sa system mo. Kung hindi, puwede mo itong itago ulit gamit ang parehong command.

### I-toggle ang hibernation

Isine-setup mo ang hibernation sa pamamagitan ng pagpapatakbo ng `omarchy hibernation setup` mula sa terminal (hindi ito available sa mga Apple Silicon Mac). Gumagawa ang hibernation ng isang /swap subvolume sa boot drive mo na kasinglaki ng alokasyon ng pisikal mong RAM, kaya siguraduhing marami kang natitirang espasyo. Sa isang makinang 32GB, palagi kang mangangailangan ng 32GB+ na libre para sa volume na ito. Nangangailangan din ang hibernation ng default na Limine bootloader.

Kapag na-setup na, makikita mo ang opsyong hibernate sa ilalim ng _System_ (o `Super + Esc`), at makikita mo kung palagiang gumagana ito sa system mo. Kung hindi, puwede mo itong alisin ulit sa pamamagitan ng pagpapatakbo ng `omarchy hibernation remove`.
