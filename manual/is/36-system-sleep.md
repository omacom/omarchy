# Svefn kerfis

Omarchy virkjar biðstöðu sjálfgefið, og dvala þegar hann hefur verið settur upp, en ef þú átt í vandræðum með annað hvort á vélinni þinni geturðu slökkt á þeim.

Á NVIDIA GB10 vélum, eins og DGX Spark og ASUS Ascent GX10, er slökkt á biðstöðu og dvala, eins og í DGX OS frá NVIDIA, vegna þess að ekki hefur enn verið sýnt fram á að svefn virki á þeim vélbúnaði. Rofinn fyrir biðstöðu og uppsetning dvala eiga ekki við þar. Til að kveikja aftur á svefni skaltu fjarlægja `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` með `sudo rm`; biðstaða birtist þá aftur í valmyndinni og hægt er að setja upp dvala eins og á öðrum vélum. Að keyra `sudo omarchy apply hardware --install-user "$USER"` setur skrána aftur inn.

### Orkusnið

Á fartölvu man Omarchy orkusniðið þitt sérstaklega fyrir það þegar hún er tengd rafmagni og þegar hún keyrir á rafhlöðu, og skiptir á milli þeirra tveggja þegar þú tengir og aftengir. Sjálfgefið þýðir það afköst á AC og jafnvægi á rafhlöðu.

Þú getur séð hvað vélin þín býður upp á með `omarchy powerprofiles list` og stillt það sem þú vilt fyrir ástandið sem þú ert í núna með `omarchy powerprofiles set autodetect power-saver`. Til að stilla hitt ástandið án þess að taka neitt úr sambandi skaltu nefna það beint: `omarchy powerprofiles set battery power-saver`. Það sem þú velur er það sem þú færð aftur næst þegar þú ert í því ástandi.

### Kveikja/slökkva á biðstöðu

Þú kveikir og slekkur á biðstöðu með því að keyra `omarchy toggle suspend` úr útstöðinni. Það sýnir/felur bara valkostinn undir _System_ (eða `Super + Esc`), og þá geturðu séð hvort hann virkar stöðugt á kerfinu þínu. Ef ekki geturðu falið hann aftur með sömu skipun.

### Kveikja/slökkva á dvala

Þú setur upp dvala með því að keyra `omarchy hibernation setup` úr útstöðinni (hann er ekki í boði á Apple Silicon Mac-tölvum). Dvali býr til /swap undirrúmmál á ræsidrifi þínu á stærð við úthlutun á raunverulegu vinnsluminni þínu, svo vertu viss um að þú hafir nægt laust pláss. Á 32GB vél þarftu alltaf 32GB+ laust fyrir þetta rúmmál. Dvali krefst einnig sjálfgefna Limine ræsistjórans.

Þegar uppsetningu er lokið sérðu dvalavalkostinn undir _System_ (eða `Super + Esc`), og þá geturðu séð hvort hann virkar stöðugt á kerfinu þínu. Ef ekki geturðu fjarlægt hann aftur með því að keyra `omarchy hibernation remove`.
