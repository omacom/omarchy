# Branding

Pinapayagan ka ng Omarchy na itakda ang logo ng kumpanya mo o personal na larawan para sa boot unlock, sa screensaver, at sa screen na Tungkol.

### Boot unlock

Maaari mong gamitin ang `omarchy plymouth preview` para makita kung ano ang magiging hitsura ng custom na logo at mga kulay mo. Tumatanggap ito ng kulay ng background, kulay ng teksto, isang logo png, at isang path para sa preview image:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pagkatapos ay ilapat ang setup gamit ang `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, na magbibigay din sa login screen ng SDDM ng parehong mga kulay at logo. Kung gusto mong ibalik, maaari mong gamitin ang `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Maaari mong palitan ang logong ginagamit para sa screensaver sa ilalim ng _Estilo > Screensaver_. Isa itong logong ASCII, kaya maaari mong i-edit ang teksto nang direkta, pero maaari mo rin itong bigyan ng larawang png o svg, at iko-convert namin iyon sa ASCII. Medyo astig ang hitsura nito.

 ![branding-screensaver](images/branding-screensaver.webp)

May tatlong entry sa menu na iyon:

- Binubuksan ng **I-edit ang Teksto** ang `~/.config/omarchy/branding/screensaver.txt` sa editor mo. I-type o i-paste ang anumang gusto mo — ASCII art, ang pangalan mo, isang bastos na salita. I-save at umalis, at agad na sisindi ang screensaver para makita mo ito.
- Binubuksan ng **Itakda mula sa Larawan** ang isang tagapili ng file para sa png o svg, iko-convert ito sa ASCII, at ipapakita sa iyo ang resulta. Ang mga logong may malinaw na silhouette ay mas gumagana nang mabuti kaysa sa mga larawan.
- Ibinabalik ng **Ibalik ang Default** ang logo ng Omarchy.

### Screen na Tungkol

Ang parehong tatlong opsyon ay nasa ilalim ng _Estilo > Tungkol_ para sa screen na _Tungkol_ na nakukuha mo mula sa menu ng Omarchy, at gumagana ang mga ito nang magkapareho — ang file ay `~/.config/omarchy/branding/about.txt`, at lumalabas ang window na Tungkol pagkatapos ng bawat pagbabago. Ang art para sa Tungkol ay iko-convert sa mas maliit na sukat kaysa sa screensaver, dahil kailangan itong magkasya sa isang window imbes na punuin ang display mo.

Habang nakabukas ang window, isang kislap ng berde ang sumasandal sa art tuwing ilang segundo at pagkatapos ay iniiwan ulit itong nakatigil. Nakukuha rin ito ng sarili mong art, basta't ang bawat character dito ay isang column ang lapad — ang anumang ginagawa ng _Itakda mula sa Larawan_ ay ganoon. Ang art na binuo mula sa emoji o mga character na doble ang lapad ay nananatiling nakatigil sa halip, at ganoon din ang screen kung magpapanatili ka ng sarili mong fastfetch config: ang nakatigil na logo sa mga kasong iyon ay ang animasyong umiiwas sa daan imbes na nabigo, dahil ang pag-slide ng kislap sa mga ito ay maglalagay sa natitirang bahagi ng linya sa maling lugar.

 ![branding-about](images/branding-about.webp)

### Pag-convert ng mga larawan nang sarili mo

Parehong tumatawag lang ng `omarchy transcode ascii` ang dalawang opsyon na _Itakda mula sa Larawan_, na maaari mong patakbuhin nang direkta kung gusto mo ng kontrol sa conversion:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tumatanggap ito ng `--width` at `--height` sa mga column at row ng terminal, isang `--mode` na alinman sa `braille` (ang default, at mas pino nang husto) o `block`, isang porsyentong `--threshold` para sa pagpapasya kung aling mga pixel ang itinuturing na bahagi ng logo, at `--invert` para sa kapag magaan ang logo mo sa madilim na background. Kung ang isang conversion ay lumalabas na isang blob, ang threshold ang karaniwang knob na pipihitin.

### Mga salita imbes na logo

Ang `omarchy ascii` ay gumuguhit ng teksto sa Delta Corps Priest 1, ang FIGlet font na kinaguhitan mismo ng wordmark ng Omarchy, kaya ang isang screensaver ay maaaring magsabi ng isang bagay imbes na magpakita ng larawan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tinatanggap nito ang teksto bilang mga argumento, o binabasa ito mula sa isang pipe kapag wala itong natanggap. Ang font ay may dala lamang na mga titik at espasyo — iginuhit ito nang walang mga digit o bantas — kaya anumang iba pa ay inaalis at pinapangalanan sa stderr imbes na tahimik na nilulunok.
