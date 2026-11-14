# Sistēmas miegs

Omarchy pēc noklusējuma iespējo apturēšanu un hibernāciju, bet, ja jūsu datorā rodas problēmas ar kādu no tām, varat tās izslēgt.

NVIDIA GB10 datoros, piemēram, DGX Spark un ASUS Ascent GX10, apturēšana un hibernācija ir izslēgtas, tāpat kā NVIDIA DGX OS, jo vēl nav pierādīts, ka miegs uz šīs aparatūras darbojas. Tas pats attiecas uz ASUS Zenbook A16 (UX3607OA), kur apturēšana vēl pilnībā neiemidzina mikroshēmu un dators pa nakti var uzkārties. Apturēšanas pārslēgšana un hibernācijas iestatīšana tur neattiecas. Lai miegu atkal ieslēgtu, izdzēsiet `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ar `sudo rm`; pēc tam Suspend atgriezīsies izvēlnē, un hibernāciju varēs iestatīt tāpat kā citos datoros. Palaižot `sudo omarchy apply hardware --install-user "$USER"`, fails tiks atjaunots.

### Jaudas profili

Klēpjdatorā Omarchy atceras jūsu jaudas profilu atsevišķi stāvoklim, kad dators ir pieslēgts pie strāvas, un stāvoklim, kad tas darbojas ar akumulatoru, un pārslēdzas starp abiem, kad pieslēdzat vai atvienojat strāvu. Pēc noklusējuma tas nozīmē veiktspēju pie maiņstrāvas un līdzsvarotu režīmu ar akumulatoru.

Ar `omarchy powerprofiles list` varat redzēt, ko piedāvā jūsu dators, un ar `omarchy powerprofiles set autodetect power-saver` iestatīt vajadzīgo profilu stāvoklim, kurā pašlaik atrodaties. Lai iestatītu otru stāvokli, neko neatvienojot, nosauciet to tieši: `omarchy powerprofiles set battery power-saver`. Lai ko jūs izvēlētos, to pašu saņemsiet nākamreiz, kad būsiet šajā stāvoklī.

### Apturēšanas pārslēgšana

Apturēšanu pārslēdzat, terminālī palaižot `omarchy toggle suspend`. Tas tikai parāda/paslēpj opciju sadaļā _Sistēma_ (vai ar `Super + Esc`), un pēc tam varat pārbaudīt, vai tā jūsu sistēmā darbojas konsekventi. Ja nedarbojas, ar to pašu komandu varat to atkal paslēpt.

### Hibernācijas pārslēgšana

Hibernāciju iestatāt, terminālī palaižot `omarchy hibernation setup`. Hibernācija izveido /swap apakšsējumu jūsu sāknēšanas diskā fiziskās RAM atmiņas apjomā, tāpēc pārliecinieties, ka jums ir pietiekami daudz brīvas vietas. Datorā ar 32GB atmiņu šim sējumam vienmēr būs nepieciešami 32GB+ brīvas vietas. Hibernācijai nepieciešams arī noklusējuma Limine sāknēšanas ielādētājs.

Kad tā ir iestatīta, hibernācijas opciju redzēsiet sadaļā _Sistēma_ (vai ar `Super + Esc`), un pēc tam varat pārbaudīt, vai tā jūsu sistēmā darbojas konsekventi. Ja nedarbojas, varat to atkal noņemt, palaižot `omarchy hibernation remove`.
