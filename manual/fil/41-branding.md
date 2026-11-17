# Pagba-brand

Hinahayaan ka ng Omarchy na itakda ang logo ng kumpanya mo o personal na larawan mo para sa pag-unlock sa boot, sa screensaver, at sa screen na About.

### Pag-unlock sa boot

Maaari mong gamitin ang `omarchy plymouth preview` para makita kung ano ang magiging hitsura ng custom na logo at mga kulay mo. Kinukuha nito ang kulay ng background, kulay ng teksto, isang logo na png, at path para sa preview na larawan:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pagkatapos, ilapat ang setup gamit ang `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, na magbibigay din sa SDDM login screen ng parehong mga kulay at logo. Kung gusto mong ibalik ito, maaari mong gamitin ang `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Maaari mong baguhin ang logong ginagamit para sa screensaver sa ilalim ng _Appearance > Branding > Screensaver_. ASCII logo ito, kaya maaari mong direktang i-edit ang teksto, pero maaari mo rin itong bigyan ng png o svg na larawan, at iko-convert namin iyon sa ASCII. Mukha itong talagang astig.

 ![branding-screensaver](images/branding-screensaver.webp)

May tatlong entry sa menu na iyon:

- **I-edit ang Teksto** binubuksan ang `~/.config/omarchy/branding/screensaver.txt` sa editor mo. I-type o i-paste ang kahit anong gusto mo — ASCII art, pangalan mo, isang bastos na salita. I-save at lumabas, at agad na magsisimula ang screensaver para makita mo ito.
- **Itakda Mula sa Larawan** binubuksan ang file picker para sa isang png o svg, iko-convert ito sa ASCII, at ipapakita sa iyo ang resulta. Mas gumagana nang mas mahusay ang mga logong may malinaw na silhouette kaysa sa mga litrato.
- **Ibalik ang Default** ibinabalik ang logo ng Omarchy.

### Screen na About

Ang parehong tatlong opsyon ay nasa ilalim ng _Appearance > Branding > About_ para sa screen na _About_ na makukuha mo mula sa menu ng Omarchy, at gumagana ang mga ito nang magkapareho — ang file ay `~/.config/omarchy/branding/about.txt`, at lumalabas ang window ng About pagkatapos ng bawat pagbabago. Iko-convert ang art ng About sa mas maliit na sukat kaysa sa screensaver, dahil kailangan itong magkasya sa isang window sa halip na punuin ang display mo.

Habang nakabukas ang window, isang kislap ng berde ang dumadaplis sa art tuwing ilang segundo at pagkatapos ay iniiwan ulit itong nakatigil. Makukuha rin ito ng sarili mong art, basta isang column lang ang lapad ng bawat character dito — lahat ng ginagawa ng _Set From Image_ ay ganoon. Nananatiling nakatigil naman ang art na gawa sa emoji o double-width na mga character, at ganoon din ang screen kung pinapanatili mo ang sarili mong fastfetch config: ang nakatigil na logo sa mga kasong iyon ay ang animation na umiiwas lang sa halip na nabibigo, dahil ang pagpapadulas ng kislap sa mga ito ay maglalagay sa natitirang bahagi ng linya sa maling lugar.

 ![branding-about](images/branding-about.webp)

### Pag-convert ng mga larawan nang sarili mo

Ang dalawang opsyon na _Set From Image_ ay tumatawag lang sa `omarchy transcode ascii`, na maaari mong patakbuhin nang direkta kung gusto mo ng kontrol sa conversion:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Kinukuha nito ang `--width` at `--height` sa mga column at row ng terminal, isang `--mode` na alinman sa `braille` (ang default, at mas pino) o `block`, isang `--threshold` na porsyento para sa pagdedesisyon kung aling mga pixel ang binibilang na bahagi ng logo, at `--invert` para kapag maputi ang logo mo sa madilim na background. Kung ang isang conversion ay lumabas na parang isang namuong masa, ang threshold ang karaniwang knob na dapat pihitin.

### Mga salita sa halip na logo

Ang `omarchy ascii` ay gumuguhit ng teksto sa Delta Corps Priest 1, ang FIGlet font na ginamit din sa pagguhit ng wordmark ng Omarchy mismo, kaya maaaring may sabihin ang isang screensaver sa halip na magpakita ng larawan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Kinukuha nito ang teksto bilang mga argument, o binabasa ito mula sa isang pipe kapag wala itong ibinigay. Ang font ay may mga titik at espasyo lamang — iginuhit ito nang walang mga digit o bantas — kaya ang anumang iba pa ay tinatanggal at binabanggit sa stderr sa halip na tahimik na lunukin.
