# Branding

Pinapayagan ka ng Omarchy na itakda ang logo ng kumpanya mo o personal na larawan para sa boot unlock, sa screensaver, at sa about screen.

### Pag-unlock sa boot

Magagamit mo ang `omarchy plymouth preview` para makita kung ano ang magiging hitsura ng custom na logo at mga kulay mo. Tumatanggap ito ng kulay ng background, kulay ng teksto, isang logo png, at isang path para sa preview image:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pagkatapos ay ilapat ang setup gamit ang `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, na magbibigay din sa SDDM login screen ng parehong mga kulay at logo. Kung gusto mong ibalik sa dati, magagamit mo ang `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Mababago mo ang logo na ginagamit para sa screensaver sa ilalim ng _Hitsura > Branding > Screensaver_. ASCII logo ito, kaya maaari mong i-edit nang direkta ang teksto, pero maaari ka ring magbigay dito ng png o svg image, at iko-convert namin iyon sa ASCII. Mukha itong talagang astig.

 ![branding-screensaver](images/branding-screensaver.webp)

May tatlong entry sa menu na iyon:

- **I-edit ang Teksto** ay nagbubukas ng `~/.config/omarchy/branding/screensaver.txt` sa editor mo. I-type o i-paste ang kahit anong gusto mo — ASCII art, pangalan mo, isang bastos na salita. I-save at lumabas, at agad na magsisimula ang screensaver para makita mo ito.
- **Itakda Mula sa Larawan** ay nagbubukas ng file picker para sa png o svg, iko-convert ito sa ASCII, at ipapakita sa iyo ang resulta. Mas gumagana nang maayos ang mga logo na may malinaw na silhouette kaysa sa mga litrato.
- **Ibalik ang Default** ay nagbabalik sa Omarchy logo.

### About screen

Ang parehong tatlong opsyon ay nasa ilalim ng _Hitsura > Branding > About_ para sa _About_ screen na makukuha mo mula sa Omarchy menu, at gumagana ang mga ito nang magkapareho — ang file ay `~/.config/omarchy/branding/about.txt`, at lilitaw ang About window pagkatapos ng bawat pagbabago. Iko-convert ang About art sa mas maliit na sukat kaysa sa screensaver, dahil kailangan itong magkasya sa isang window sa halip na punuin ang display mo.

Habang nakabukas ang window, isang banda ng maliwanag na puting liwanag ang tumatawid nang nakahilig sa art bawat ilang segundo at pagkatapos ay iiwan itong muli nang nakatigil. Makukuha rin ito ng sarili mong art, basta isang column lang ang lapad ng bawat character dito — lahat ng ginagawa ng _Itakda Mula sa Larawan_ ay ganoon. Mananatiling nakatigil sa halip ang art na gawa sa emoji o double-width na mga character, at ganoon din ang screen kung magpapanatili ka ng sarili mong fastfetch config: ang nakatigil na logo sa mga kasong iyon ay ang animation na umiiwas sa halip na nabibigo, dahil ang pag-slide ng kislap sa mga ito ay maglalagay sa natitirang bahagi ng linya sa maling lugar.

 ![branding-about](images/branding-about.webp)

### Pag-convert ng mga larawan nang mag-isa

Ang parehong opsyon na _Itakda Mula sa Larawan_ ay tumatawag lang sa `omarchy transcode ascii`, na maaari mong patakbuhin nang direkta kung gusto mo ng kontrol sa conversion:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tumatanggap ito ng `--width` at `--height` sa mga column at row ng terminal, ng `--mode` na alinman sa `braille` (ang default, at mas pino nang husto) o `block`, ng `--threshold` na porsyento para sa pagpapasya kung aling mga pixel ang itinuturing na bahagi ng logo, at ng `--invert` para kapag maliwanag ang logo mo sa madilim na background. Kung lumabas na parang blob ang isang conversion, ang threshold ang karaniwang knob na dapat galawin.

### Mga salita sa halip na logo

Ang `omarchy ascii` ay gumuguhit ng teksto sa Delta Corps Priest 1, ang FIGlet font na ginamit mismo sa pagguhit ng Omarchy wordmark, kaya maaaring may sabihin ang isang screensaver sa halip na magpakita ng larawan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tumatanggap ito ng teksto bilang mga argument, o binabasa ito mula sa isang pipe kapag walang ibinigay. Mga letra at espasyo lang ang dala ng font — iginuhit ito nang walang mga digit o bantas — kaya ang anumang iba pa ay inaalis at pinapangalanan sa stderr sa halip na tahimik na lunukin.
