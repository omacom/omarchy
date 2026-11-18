# Svefn kerfis

Omarchy virkjar svæfu og dvala sjálfgefið, en ef þú lendir í vandræðum með annað hvort á vélinni þinni geturðu slökkt á þeim.

Á NVIDIA GB10 vélum, eins og DGX Spark og ASUS Ascent GX10, er slökkt á svæfu og dvala, eins og í DGX OS frá NVIDIA, vegna þess að svefn hefur ekki enn reynst virka á þeim vélbúnaði. Sama gildir um ASUS Zenbook A16 (UX3607OA), þar sem svæfa lætur kubbinn ekki enn sofna að fullu og getur frosið yfir nótt. Rofinn fyrir svæfu og uppsetning dvala eiga ekki við þar. Til að kveikja aftur á svefni skaltu fjarlægja `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` með `sudo rm`; Svæfa birtist þá aftur í valmyndinni og hægt er að setja upp dvala eins og á öðrum vélum. Að keyra `sudo omarchy apply hardware --install-user "$USER"` setur skrána aftur inn.

### Orkusnið

Á fartölvu man Omarchy orkusniðið þitt aðgreint fyrir hvort hún er í sambandi eða keyrir á rafhlöðu og skiptir á milli þeirra tveggja þegar þú stingur í samband og tekur úr sambandi. Sjálfgefið þýðir það afkastasnið á rafmagni og jafnvægissnið á rafhlöðu.

Þú getur séð hvað vélin þín býður upp á með `omarchy powerprofiles list` og stillt það sem þú vilt fyrir ástandið sem þú ert í núna með `omarchy powerprofiles set autodetect power-saver`. Til að stilla hitt ástandið án þess að taka neitt úr sambandi skaltu nefna það beint: `omarchy powerprofiles set battery power-saver`. Hvað sem þú velur er það sem þú færð aftur næst þegar þú ert í því ástandi.

### Kveikja/slökkva á svæfu

Þú kveikir/slökkur á svæfu með því að keyra `omarchy toggle suspend` úr skipanalínunni. Það sýnir/felur bara valkostinn undir _System_ (eða `Super + Esc`) og þá geturðu séð hvort hann virkar áreiðanlega á kerfinu þínu. Ef ekki geturðu falið hann aftur með sömu skipun.

### Kveikja/slökkva á dvala

Þú setur upp dvala með því að keyra `omarchy hibernation setup` úr skipanalínunni. Dvali býr til /swap undirbindi á ræsidrifi þínu á stærð við úthlutað vinnsluminni, svo vertu viss um að þú hafir nóg laust pláss. Á 32GB vél þarftu alltaf 32GB+ laus fyrir þetta bindi. Dvali krefst einnig sjálfgefna Limine ræsistjórans.

Þegar það er sett upp sérðu dvalavalkostinn undir _System_ (eða `Super + Esc`) og þá geturðu séð hvort hann virkar áreiðanlega á kerfinu þínu. Ef ekki geturðu fjarlægt hann aftur með því að keyra `omarchy hibernation remove`.
