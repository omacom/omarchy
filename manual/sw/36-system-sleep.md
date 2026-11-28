# Kulala kwa mfumo

Omarchy huwasha kusitisha kwa muda kwa chaguo-msingi, na hibernation mara tu inapokuwa imesanidiwa, lakini ukipata matatizo na mojawapo kati ya hizo kwenye mashine yako, unaweza kuizima.

Kwenye mashine za NVIDIA GB10, kama vile DGX Spark na ASUS Ascent GX10, kusitisha kwa muda na hibernation vimezimwa, kama vilivyo katika DGX OS ya NVIDIA, kwa sababu kulala bado hakijaonyeshwa kufanya kazi kwenye maunzi hayo. Kigeuzi cha kusitisha kwa muda na usanidi wa hibernation havihusiki huko. Ili kuwasha kulala tena, ondoa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` kwa `sudo rm`; Kusitisha kwa muda kitarudi kwenye menyu, na hibernation inaweza kusanidiwa kama kwenye mashine nyingine. Kuendesha `sudo omarchy apply hardware --install-user "$USER"` kitarudisha faili hilo.

### Profaili za nishati

Kwenye laptop, Omarchy hukumbuka profaili yako ya nishati tofauti ukiwa umechomekwa na ukiwa unatumia betri, na hubadilisha kati ya hizo mbili unapochomeka na kuchomoa. Kwa chaguo-msingi, hilo linamaanisha performance ukiwa kwenye AC na balanced ukiwa kwenye betri.

Unaweza kuona kile mashine yako inachotoa kwa `omarchy powerprofiles list`, na kuweka unayoitaka kwa hali uliyonayo sasa hivi kwa `omarchy powerprofiles set autodetect power-saver`. Kuweka hali nyingine bila kuchomoa chochote, itaje moja kwa moja: `omarchy powerprofiles set battery power-saver`. Chochote utakachochagua ndicho utakachopata tena utakapokuwa katika hali hiyo.

### Washa/zima kusitisha kwa muda

Unawasha/kuzima kusitisha kwa muda kwa kuendesha `omarchy toggle suspend` kutoka kwenye terminal. Hiyo huonyesha/kuficha tu chaguo chini ya _Mfumo_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. La sivyo, unaweza kulificha tena kwa amri hiyo hiyo.

### Washa/zima hibernation

Unasanidi hibernation kwa kuendesha `omarchy hibernation setup` kutoka kwenye terminal (haipatikani kwenye Apple Silicon Macs). Hibernation huunda subvolume ya /swap kwenye hifadhi yako ya kuwasha yenye ukubwa wa mgao wako wa RAM halisi, kwa hivyo hakikisha una nafasi kubwa ya ziada. Kwenye mashine ya 32GB, utahitaji daima nafasi ya bure ya 32GB+ kwa volume hii. Hibernation pia inahitaji bootloader chaguo-msingi ya Limine.

Ikishasanidiwa, utaona chaguo la hibernate chini ya _Mfumo_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. La sivyo, unaweza kuiondoa tena kwa kuendesha `omarchy hibernation remove`.
