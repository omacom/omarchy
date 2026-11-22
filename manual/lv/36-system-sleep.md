# Sistēmas miegs

Omarchy pēc noklusējuma iespējo apturēšanu, bet hibernāciju — tiklīdz tā ir iestatīta, taču, ja jūsu datorā ar kādu no tām rodas problēmas, varat tās izslēgt.

NVIDIA GB10 datoros, piemēram, DGX Spark un ASUS Ascent GX10, apturēšana un hibernācija ir izslēgtas, tāpat kā NVIDIA DGX OS, jo vēl nav pierādīts, ka miega režīms uz šīs aparatūras darbojas. Tas pats attiecas uz ASUS Zenbook A16 (UX3607OA), kur apturēšana vēl neiemidzina mikroshēmu pilnībā un dators var uzkārties pa nakti. Apturēšanas pārslēgs un hibernācijas iestatīšana tur neattiecas. Lai miega režīmu ieslēgtu atpakaļ, noņemiet `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ar `sudo rm`; pēc tam izvēlnē atgriezīsies apturēšanas opcija, un hibernāciju varēs iestatīt tāpat kā citos datoros. Palaižot `sudo omarchy apply hardware --install-user "$USER"`, fails tiks ievietots atpakaļ.

### Jaudas profili

Klēpjdatorā Omarchy atceras jūsu jaudas profilu atsevišķi pieslēgtam pie strāvas un darbam uz akumulatora, un pārslēdzas starp abiem, kad pieslēdzat vai atvienojat datoru. Pēc noklusējuma tas nozīmē veiktspēju no elektrotīkla un sabalansētu režīmu uz akumulatora.

Varat apskatīt, ko piedāvā jūsu dators, ar `omarchy powerprofiles list`, un iestatīt vēlamo profilu stāvoklim, kurā pašlaik atrodaties, ar `omarchy powerprofiles set autodetect power-saver`. Lai iestatītu otru stāvokli, neko neatvienojot, norādiet to tieši: `omarchy powerprofiles set battery power-saver`. Lai kuru izvēlētos, to pašu saņemsiet atpakaļ, kad nākamreiz būsiet attiecīgajā stāvoklī.

### Apturēšanas pārslēgšana

Apturēšanu pārslēdzat, terminālī palaižot `omarchy toggle suspend`. Tas tikai parāda/paslēpj opciju sadaļā _Sistēma_ (vai ar `Super + Esc`), un pēc tam varat pārbaudīt, vai tā jūsu sistēmā darbojas stabili. Ja ne, ar to pašu komandu varat to atkal paslēpt.

### Hibernācijas pārslēgšana

Hibernāciju iestatāt, terminālī palaižot `omarchy hibernation setup` (tas nav pieejams Apple Silicon Mac datoros). Hibernācija jūsu sāknēšanas diskā izveido /swap apakšsējumu jūsu fiziskās RAM apjoma lielumā, tāpēc pārliecinieties, ka jums ir pietiekami daudz brīvas vietas. 32GB datorā šim sējumam vienmēr būs vajadzīgi 32GB+ brīvas vietas. Hibernācijai nepieciešams arī noklusējuma Limine sāknēšanas ielādētājs.

Kad tā būs iestatīta, sadaļā _Sistēma_ (vai ar `Super + Esc`) redzēsiet hibernācijas opciju, un pēc tam varat pārbaudīt, vai tā jūsu sistēmā darbojas stabili. Ja ne, varat to atkal noņemt, palaižot `omarchy hibernation remove`.
