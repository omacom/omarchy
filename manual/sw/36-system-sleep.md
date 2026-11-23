# Kulala kwa mfumo

Omarchy huwasha kusitisha kwa chaguo-msingi, na kulala kwa kina pindi kinapowekwa, lakini ukipata matatizo na mojawapo kwenye mashine yako, unaweza kuyazima.

Kwenye mashine za NVIDIA GB10, kama vile DGX Spark na ASUS Ascent GX10, kusitisha na kulala kwa kina vimezimwa, kama ilivyo katika DGX OS ya NVIDIA, kwa sababu kulala bado hakujathibitishwa kufanya kazi kwenye maunzi hayo. Vivyo hivyo kwa ASUS Zenbook A16 (UX3607OA), ambapo kusitisha bado hakuiweki chipu kabisa katika usingizi na inaweza kukwama usiku kucha. Kipengele cha kuwasha/kuzima kusitisha na usanidi wa kulala kwa kina havitumiki hapo. Ili kuwasha kulala tena, ondoa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` kwa `sudo rm`; Kusitisha kisha hurejea kwenye menyu, na kulala kwa kina kunaweza kuwekwa kama kwenye mashine nyingine. Kuendesha `sudo omarchy apply hardware --install-user "$USER"` huweka faili tena.

### Profaili za nishati

Kwenye laptopu, Omarchy hukumbuka profaili yako ya nishati kando kwa ikiwa imechomekwa na ikiwa inatumia betri, na hubadilisha kati ya hizo mbili unapochomeka na kuchomoa. Kama ilivyo kutoka kiwandani, hiyo ina maana ya performance kwenye AC na balanced kwenye betri.

Unaweza kuona kile mashine yako inatoa kwa `omarchy powerprofiles list`, na kuweka unayoitaka kwa hali uliyonayo sasa kwa `omarchy powerprofiles set autodetect power-saver`. Ili kuweka hali nyingine bila kuchomoa chochote, itaje moja kwa moja: `omarchy powerprofiles set battery power-saver`. Chochote utakachochagua ndicho utakachopata tena wakati ujao ukiwa katika hali hiyo.

### Washa/zima kusitisha

Unawasha/kuzima kusitisha kwa kuendesha `omarchy toggle suspend` kutoka kwenye terminali. Hiyo hufunua/huficha tu chaguo chini ya _Mfumo_ (au `Super + Esc`), na kisha unaweza kuona kama inafanya kazi kwa uthabiti kwenye mfumo wako. Ikiwa sivyo, unaweza kuificha tena kwa amri hiyo hiyo.

### Washa/zima kulala kwa kina

Unaweka kulala kwa kina kwa kuendesha `omarchy hibernation setup` kutoka kwenye terminali (haipatikani kwenye Mac za Apple Silicon). Kulala kwa kina huunda subvolume ya /swap kwenye kiendeshi chako cha kuwasha yenye ukubwa wa mgao wako wa RAM halisi, kwa hivyo hakikisha una nafasi nyingi iliyobaki. Kwenye mashine ya 32GB, utahitaji daima 32GB+ ya nafasi wazi kwa volume hii. Kulala kwa kina pia kunahitaji bootloader chaguo-msingi ya Limine.

Ukishaweka, utaona chaguo la kulala kwa kina chini ya _Mfumo_ (au `Super + Esc`), na kisha unaweza kuona kama inafanya kazi kwa uthabiti kwenye mfumo wako. Ikiwa sivyo, unaweza kuiondoa tena kwa kuendesha `omarchy hibernation remove`.
