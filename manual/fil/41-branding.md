# Branding

Hinahayaan ka ng Omarchy na magtakda ng logo ng kumpanya mo o personal na larawan para sa screensaver at sa about screen.

### Screensaver

Mababago mo ang logong ginagamit para sa screensaver sa ilalim ng _Appearance > Branding > Screensaver_. ASCII logo ito, kaya puwede mong direktang i-edit ang teksto, pero puwede ka ring magbigay ng png o svg na larawan, at iko-convert namin iyon sa ASCII. Mukhang astig talaga.

 ![branding-screensaver](images/branding-screensaver.webp)

May tatlong entry sa menu na iyon:

- **Edit Text** ang nagbubukas ng `~/.config/omarchy/branding/screensaver.txt` sa editor mo. I-type o i-paste ang kahit anong gusto mo — ASCII art, pangalan mo, isang bastos na salita. I-save at lumabas, at agad na magsisimula ang screensaver para makita mo ito.
- **Set From Image** ang nagbubukas ng file picker para sa isang png o svg, nagko-convert nito sa ASCII, at nagpapakita sa iyo ng resulta. Mas maganda ang kalalabasan ng mga logong may malinaw na silhouette kaysa sa mga litrato.
- **Restore Default** ang nagbabalik sa logo ng Omarchy.

### About screen

Ang parehong tatlong opsyon ay nasa ilalim ng _Appearance > Branding > About_ para sa _About_ screen na makukuha mo mula sa menu ng Omarchy, at gumagana ang mga ito nang magkapareho — ang file ay `~/.config/omarchy/branding/about.txt`, at lumalabas ang About window pagkatapos ng bawat pagbabago. Iko-convert ang About art sa mas maliit na sukat kaysa sa screensaver, dahil kailangan itong magkasya sa isang window sa halip na punuin ang display mo.

Habang bukas ang window, may isang banda ng maliwanag na puting liwanag na tatabingi sa art bawat ilang segundo at pagkatapos ay iiwan itong nakatigil ulit. Makukuha rin ito ng sarili mong art, basta isang column lang ang lapad ng bawat character dito — ganito ang lahat ng ginagawa ng _Set From Image_. Nananatiling nakatigil ang art na gawa sa emoji o mga double-width na character, at ganoon din ang screen kung may sarili kang fastfetch config: ang nakatigil na logo sa mga kasong iyon ay ang animation na umiiwas sa halip na nabibigo, dahil ang pag-slide ng isang kislap sa mga ito ay maglalagay sa natitirang bahagi ng linya sa maling lugar.

 ![branding-about](images/branding-about.webp)

### Pag-convert ng mga larawan nang ikaw mismo

Ang dalawang opsyon ng _Set From Image_ ay tumatawag lang sa `omarchy transcode ascii`, na puwede mong direktang patakbuhin kung gusto mo ng kontrol sa conversion:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Tumatanggap ito ng `--width` at `--height` sa mga column at row ng terminal, ng `--mode` na alinman sa `braille` (ang default, at mas pino) o `block`, ng `--threshold` na porsyento para sa pagpapasya kung aling mga pixel ang binibilang na bahagi ng logo, at ng `--invert` para kapag maliwanag ang logo mo sa isang madilim na background. Kung lumabas na parang blob ang isang conversion, ang threshold ang karaniwang knob na dapat pihitin.

### Mga salita sa halip na isang logo

Gumuguhit ang `omarchy ascii` ng teksto sa Delta Corps Priest 1, ang FIGlet font na ginamit din sa pagguhit ng mismong wordmark ng Omarchy, kaya may masasabi ang isang screensaver sa halip na magpakita ng larawan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Tumatanggap ito ng teksto bilang mga argument, o binabasa ito mula sa isang pipe kapag walang ibinigay. Mga titik at space lang ang dala ng font — ginuhit ito nang walang mga digit o bantas — kaya anumang iba pa ay tatanggalin at babanggitin sa stderr sa halip na tahimik na lunukin.
