# Usingizi wa mfumo

Omarchy huwasha kusimamisha na hibernation kwa chaguo-msingi, lakini ukipata matatizo na mojawapo kwenye mashine yako, unaweza kuizima.

Kwenye mashine za NVIDIA GB10, kama vile DGX Spark na ASUS Ascent GX10, kusimamisha na hibernation vimezimwa, kama ilivyo katika DGX OS ya NVIDIA, kwa sababu usingizi bado haujaonyeshwa kufanya kazi kwenye maunzi hayo. Kigeuzi cha kusimamisha na usanidi wa hibernation havitumiki hapo. Ili kuwasha usingizi tena, ondoa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` kwa `sudo rm`; kisha Suspend itarudi kwenye menyu, na hibernation inaweza kusaniwa kama kwenye mashine nyingine. Kuendesha `sudo omarchy apply hardware --install-user "$USER"` kutarudisha faili hilo.

### Wasifu wa nishati

Kwenye laptop, Omarchy hukumbuka wasifu wako wa nishati tofauti kwa hali ya kuchomekwa na hali ya kufanya kazi kwa betri, na hubadilishana kati ya hizo mbili unapochomeka na kuchomoa. Hapo awali hiyo inamaanisha utendaji ukiwa kwenye AC na uwiano ukiwa kwenye betri.

Unaweza kuona kile ambacho mashine yako inatoa kwa `omarchy powerprofiles list`, na kuweka unaoutaka kwa hali uliyonayo sasa kwa `omarchy powerprofiles set autodetect power-saver`. Ili kuweka hali nyingine bila kuchomoa chochote, itaje moja kwa moja: `omarchy powerprofiles set battery power-saver`. Chochote utakachochagua ndicho utakachopata tena wakati ujao ukiwa katika hali hiyo.

### Washa au zima kusimamisha

Unageuza kusimamisha kwa kuendesha `omarchy toggle suspend` kutoka kwenye terminal. Hiyo huonyesha/huficha tu chaguo chini ya _System_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. Ikiwa sivyo, unaweza kulificha tena kwa amri hiyo hiyo.

### Washa au zima hibernation

Unasani hibernation kwa kuendesha `omarchy hibernation setup` kutoka kwenye terminal. Hibernation hutengeneza subvolume ya /swap kwenye kiendeshi chako cha kuwasha yenye ukubwa wa mgao wako wa RAM halisi, kwa hiyo hakikisha una nafasi nyingi iliyobaki. Kwenye mashine ya 32GB, utahitaji daima 32GB+ wazi kwa volume hii. Hibernation pia inahitaji bootloader chaguo-msingi ya Limine.

Ikishasaniwa, utaona chaguo la hibernate chini ya _System_ (au `Super + Esc`), na kisha unaweza kuona kama linafanya kazi kwa uthabiti kwenye mfumo wako. Ikiwa sivyo, unaweza kuliondoa tena kwa kuendesha `omarchy hibernation remove`.
