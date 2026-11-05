# Pagtulog ng system

Pinagana ng Omarchy ang suspend at hibernation bilang default, pero kung nagkakaroon ka ng mga isyu sa alinman sa mga ito sa iyong machine, maaari mo silang i-toggle off.

Sa mga NVIDIA GB10 machine, gaya ng DGX Spark at ASUS Ascent GX10, naka-off ang suspend at hibernation, gaya sa DGX OS ng NVIDIA, dahil hindi pa naipapakitang gumagana ang sleep sa hardware na iyon. Hindi nalalapat doon ang toggle ng suspend at setup ng hibernation. Para i-on ulit ang sleep, alisin ang `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` gamit ang `sudo rm`; babalik ang Suspend sa menu, at maaaring i-setup ang hibernation gaya sa ibang mga machine. Ibabalik ng pagpapatakbo ng `sudo omarchy apply hardware --install-user "$USER"` ang file.

### Mga power profile

Sa laptop, naaalala ng Omarchy ang iyong power profile nang hiwalay para sa nakasaksak at para sa tumatakbo sa baterya, at nagpapalipat-lipat sa dalawa habang nagsasaksak at nagbubunot ka. Mula sa simula, nangangahulugan iyon ng performance sa AC at balanced sa baterya.

Makikita mo kung ano ang inaalok ng iyong machine gamit ang `omarchy powerprofiles list`, at maaari mong itakda ang gusto mo para sa estadong kinaroroonan mo ngayon gamit ang `omarchy powerprofiles set autodetect power-saver`. Para itakda ang kabilang estado nang walang binubunot, pangalanan ito nang direkta: `omarchy powerprofiles set battery power-saver`. Kung ano ang piliin mo ay siya ring makukuha mo sa susunod na nasa estadong iyon ka.

### I-toggle ang suspend

Ito-toggle mo ang suspend sa pamamagitan ng pagpapatakbo ng `omarchy toggle suspend` mula sa terminal. Ipinapakita/itinatago lang niyan ang opsyon sa ilalim ng _System_ (o `Super + Esc`), at makikita mo pagkatapos kung tuloy-tuloy itong gumagana sa iyong system. Kung hindi, maaari mo itong itago ulit gamit ang parehong command.

### I-toggle ang hibernation

Isine-setup mo ang hibernation sa pamamagitan ng pagpapatakbo ng `omarchy hibernation setup` mula sa terminal. Gumagawa ang hibernation ng /swap subvolume sa iyong boot drive na kasinglaki ng iyong pisikal na alokasyon ng RAM, kaya tiyaking marami kang natitirang espasyo. Sa isang 32GB machine, palagi kang mangangailangan ng 32GB+ na libre para sa volume na ito. Nangangailangan din ang hibernation ng default na Limine bootloader.

Kapag na-setup na, makikita mo ang opsyong hibernate sa ilalim ng _System_ (o `Super + Esc`), at makikita mo pagkatapos kung tuloy-tuloy itong gumagana sa iyong system. Kung hindi, maaari mo itong alisin ulit sa pamamagitan ng pagpapatakbo ng `omarchy hibernation remove`.
