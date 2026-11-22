# Kerfissvefn

Omarchy virkjar svæfingu sjálfgefið, og dvala þegar henni hefur verið komið fyrir, en ef þú lendir í vandræðum með hvort tveggja á vélinni þinni geturðu slökkt á því.

Á NVIDIA GB10 vélum, eins og DGX Spark og ASUS Ascent GX10, er slökkt á svæfingu og dvala, eins og í DGX OS frá NVIDIA, því ekki hefur enn verið sýnt fram á að svefn virki á þeim vélbúnaði. Sama gildir um ASUS Zenbook A16 (UX3607OA), þar sem svæfing setur kubbinn ekki enn alveg í svefn og getur hangið yfir nótt. Rofinn fyrir svæfingu og uppsetning dvala eiga ekki við þar. Til að kveikja aftur á svefni skaltu fjarlægja `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` með `sudo rm`; svæfing birtist þá aftur í valmyndinni og hægt er að setja upp dvala eins og á öðrum vélum. Að keyra `sudo omarchy apply hardware --install-user "$USER"` setur skrána aftur á sinn stað.

### Orkuprófílar

Á fartölvu man Omarchy orkuprófílinn þinn sérstaklega fyrir það þegar hún er tengd við rafmagn og þegar hún keyrir á rafhlöðu, og skiptir á milli þeirra tveggja þegar þú tengir og aftengir. Beint úr kassanum þýðir það afköst á AC og jafnvægi á rafhlöðu.

Þú getur séð hvað vélin þín býður upp á með `omarchy powerprofiles list`, og stillt þann sem þú vilt fyrir það ástand sem þú ert í núna með `omarchy powerprofiles set autodetect power-saver`. Til að stilla hitt ástandið án þess að taka neitt úr sambandi skaltu nefna það beint: `omarchy powerprofiles set battery power-saver`. Hvað sem þú velur er það sem þú færð aftur næst þegar þú ert í því ástandi.

### Kveikja/slökkva á svæfingu

Þú kveikir og slekkur á svæfingu með því að keyra `omarchy toggle suspend` úr útstöðinni. Það sýnir/felur bara valkostinn undir _System_ (eða `Super + Esc`), og þá geturðu séð hvort hann virki áreiðanlega á kerfinu þínu. Ef ekki geturðu falið hann aftur með sömu skipun.

### Kveikja/slökkva á dvala

Þú setur upp dvala með því að keyra `omarchy hibernation setup` úr útstöðinni (það er ekki í boði á Apple Silicon Macs). Dvala býr til /swap undirrúmmál á ræsidrifinu þínu á stærð við úthlutun á líkamlegu vinnsluminni, svo vertu viss um að þú hafir nóg laust pláss. Á 32GB vél þarftu alltaf 32GB+ laust fyrir þetta rúmmál. Dvala krefst einnig sjálfgefna Limine ræsistjórans.

Þegar því hefur verið komið fyrir sérðu dvalavalkostinn undir _System_ (eða `Super + Esc`), og þá geturðu séð hvort hann virki áreiðanlega á kerfinu þínu. Ef ekki geturðu fjarlægt hann aftur með því að keyra `omarchy hibernation remove`.
