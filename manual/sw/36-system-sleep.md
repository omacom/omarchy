# Usingizi wa mfumo

Omarchy inawasha kusimamisha na kulala kwa kina kwa chaguo-msingi, lakini ukipata matatizo na mojawapo kwenye mashine yako, unaweza kuizima.

Kwenye mashine za NVIDIA GB10, kama vile DGX Spark na ASUS Ascent GX10, kusimamisha na kulala kwa kina vimezimwa, kama ilivyo kwenye DGX OS ya NVIDIA, kwa sababu usingizi bado haujaonyeshwa kufanya kazi kwenye maunzi hayo. Hali hiyo hiyo inahusu ASUS Zenbook A16 (UX3607OA), ambapo kusimamisha bado hakuilazi chip kikamilifu na kunaweza kukwama usiku kucha. Kibadilishaji cha kusimamisha na usanidi wa kulala kwa kina havitumiki huko. Ili kuwasha usingizi tena, ondoa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` kwa `sudo rm`; kisha Kusimamisha kunarudi kwenye menyu, na kulala kwa kina kunaweza kusanidiwa kama kwenye mashine nyingine. Kuendesha `sudo omarchy apply hardware --install-user "$USER"` kunarudisha faili.

### Wasifu wa nishati

Kwenye kompyuta ya mkononi, Omarchy inakumbuka wasifu wako wa nishati kando kwa ikiwa imechomekwa na ikiwa inatumia betri, na hubadilisha kati ya hizo mbili unapochomeka na kuchomoa. Moja kwa moja hiyo inamaanisha utendaji ukiwa kwenye AC na ulinganifu ukiwa kwenye betri.

Unaweza kuona kile mashine yako inatoa kwa `omarchy powerprofiles list`, na kuweka unaoutaka kwa hali uliyonayo sasa kwa `omarchy powerprofiles set autodetect power-saver`. Kuweka hali nyingine bila kuchomoa chochote, itaje moja kwa moja: `omarchy powerprofiles set battery power-saver`. Chochote utakachochagua ndicho utakachopata tena wakati mwingine ukiwa katika hali hiyo.

### Washa/zima kusimamisha

Unawasha/zima kusimamisha kwa kuendesha `omarchy toggle suspend` kutoka kwenye terminal. Hiyo huonyesha/huficha tu chaguo chini ya _System_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. Kama halifanyi, unaweza kulificha tena kwa amri hiyo hiyo.

### Washa/zima kulala kwa kina

Unasanidi kulala kwa kina kwa kuendesha `omarchy hibernation setup` kutoka kwenye terminal. Kulala kwa kina huunda subvolume ya /swap kwenye hifadhi yako ya kuwasha yenye ukubwa wa mgao wako halisi wa RAM, kwa hivyo hakikisha una nafasi nyingi iliyobaki. Kwenye mashine ya 32GB, utahitaji kila wakati 32GB+ ya nafasi wazi kwa ajili ya volume hii. Kulala kwa kina pia kunahitaji bootloader chaguo-msingi ya Limine.

Ikikisha kusanidiwa, utaona chaguo la kulala kwa kina chini ya _System_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. Kama halifanyi, unaweza kuliondoa tena kwa kuendesha `omarchy hibernation remove`.
