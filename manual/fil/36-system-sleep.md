# Pagtulog ng sistema

Pinagagana ng Omarchy ang suspend at hibernation bilang default, pero kung may problema ka sa alinman sa dalawa sa makina mo, maaari mo silang i-toggle off.

### Mga profile ng kuryente

Sa isang laptop, naaalala ng Omarchy ang profile ng kuryente mo nang hiwalay para sa nakasaksak at tumatakbo sa baterya, at nagpapalit sa pagitan ng dalawa habang nagsasaksak at nagbubunot ka. Agad-agad, ibig sabihin niyon ay performance sa AC at balanced sa baterya.

Makikita mo kung ano ang inaalok ng makina mo gamit ang `omarchy powerprofiles list`, at maaari mong itakda ang gusto mo para sa estado kung nasaan ka ngayon gamit ang `omarchy powerprofiles set autodetect power-saver`. Para itakda ang kabilang estado nang walang binubunot, pangalanan ito nang direkta: `omarchy powerprofiles set battery power-saver`. Anuman ang piliin mo ay iyon ang ibabalik sa iyo sa susunod na mapunta ka sa estadong iyon.

### I-toggle ang suspend

Ini-toggle mo ang suspend sa pamamagitan ng pagpapatakbo ng `omarchy toggle suspend` mula sa terminal. Ipinapakita/itinatago lang niyon ang opsyon sa ilalim ng _Sistema_ (o `Super + Esc`), at pagkatapos ay makikita mo kung tuluy-tuloy itong gumagana sa sistema mo. Kung hindi, maaari mo itong itago ulit gamit ang parehong command.

### I-toggle ang hibernation

Sine-setup mo ang hibernation sa pamamagitan ng pagpapatakbo ng `omarchy hibernation setup` mula sa terminal. Gumagawa ang hibernation ng subvolume na /swap sa boot drive mo na kasinglaki ng pisikal mong alokasyon ng RAM, kaya siguraduhing marami kang bakanteng espasyo. Sa isang makinang may 32GB, palagi kang mangangailangan ng 32GB+ na libre para sa volume na ito. Nangangailangan din ang hibernation ng default na bootloader na Limine.

Kapag na-setup na, makikita mo ang opsyon ng hibernate sa ilalim ng _Sistema_ (o `Super + Esc`), at pagkatapos ay makikita mo kung tuluy-tuloy itong gumagana sa sistema mo. Kung hindi, maaari mo itong alisin ulit sa pamamagitan ng pagpapatakbo ng `omarchy hibernation remove`.
