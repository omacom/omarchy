# Kerfissvefn

Omarchy virkjar svæfingu og dvala sjálfgefið, en ef þú lendir í vandræðum með hvort tveggja á vélinni þinni geturðu slökkt á þeim.

Á NVIDIA GB10 vélum, eins og DGX Spark og ASUS Ascent GX10, er slökkt á svæfingu og dvala, eins og í DGX OS frá NVIDIA, því ekki hefur verið sýnt fram á að svefn virki á þeim vélbúnaði ennþá. Víxlarinn fyrir svæfingu og uppsetning dvala eiga ekki við þar. Til að kveikja á svefn aftur skaltu fjarlægja `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` með `sudo rm`; þá birtist Svæfa aftur í valmyndinni og hægt er að setja upp dvala eins og á öðrum vélum. Með því að keyra `sudo omarchy apply hardware --install-user "$USER"` seturðu skrána aftur á sinn stað.

### Orkusnið

Á fartölvu man Omarchy orkusniðið þitt sérstaklega fyrir hvort hún er tengd við rafmagn eða keyrir á rafhlöðu og skiptir á milli þeirra tveggja þegar þú tengir hana í samband eða tekur hana úr sambandi. Sjálfgefið þýðir það afköst á AC og jafnvægi á rafhlöðu.

Þú getur séð hvað vélin þín býður upp á með `omarchy powerprofiles list` og stillt það sem þú vilt fyrir það ástand sem þú ert í núna með `omarchy powerprofiles set autodetect power-saver`. Til að stilla hitt ástandið án þess að taka neitt úr sambandi skaltu nefna það beint: `omarchy powerprofiles set battery power-saver`. Hvað sem þú velur er það sem þú færð aftur næst þegar þú ert í því ástandi.

### Kveikja og slökkva á svæfingu

Þú víxlar svæfingu með því að keyra `omarchy toggle suspend` í útstöðinni. Það birtir/felur bara valkostinn undir _Kerfi_ (eða `Super + Esc`), og þá geturðu séð hvort hann virkar áreiðanlega á kerfinu þínu. Ef ekki geturðu falið hann aftur með sömu skipun.

### Kveikja og slökkva á dvala

Þú setur upp dvala með því að keyra `omarchy hibernation setup` í útstöðinni. Dvali býr til /swap undirbindi á ræsidrifi þínu á stærð við úthlutun líkamlegs vinnsluminnis þíns, svo vertu viss um að þú hafir nóg laust pláss. Á 32GB vél þarftu alltaf 32GB+ laus fyrir þetta bindi. Dvali krefst einnig sjálfgefna Limine ræsistjórans.

Þegar hann hefur verið settur upp sérðu dvalavalkostinn undir _Kerfi_ (eða `Super + Esc`), og þá geturðu séð hvort hann virkar áreiðanlega á kerfinu þínu. Ef ekki geturðu fjarlægt hann aftur með því að keyra `omarchy hibernation remove`.
