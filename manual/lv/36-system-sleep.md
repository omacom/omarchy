# Sistēmas miegs

Omarchy pēc noklusējuma iespējo apturēšanu un hibernāciju, tiklīdz tā ir iestatīta, bet, ja jūsu datorā ar kādu no tām rodas problēmas, varat tās izslēgt.

NVIDIA GB10 datoros, piemēram, DGX Spark un ASUS Ascent GX10, apturēšana un hibernācija ir izslēgtas, tāpat kā NVIDIA DGX OS, jo vēl nav pierādīts, ka miega režīms uz šīs aparatūras darbojas. Apturēšanas pārslēgšana un hibernācijas iestatīšana tur neattiecas. Lai miega režīmu ieslēgtu atpakaļ, izdzēsiet `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ar `sudo rm`; tad izvēlnē atgriezīsies apturēšana, un hibernāciju varēs iestatīt tāpat kā citos datoros. Palaižot `sudo omarchy apply hardware --install-user "$USER"`, fails tiks atjaunots.

### Jaudas profili

Klēpjdatorā Omarchy atceras jūsu jaudas profilu atsevišķi pievienotam strāvas avotam un darbībai ar akumulatoru un pārslēdzas starp abiem, kad pievienojat vai atvienojat strāvu. Pēc noklusējuma tas nozīmē veiktspēju ar AC un līdzsvarotu režīmu ar akumulatoru.

Ar `omarchy powerprofiles list` varat redzēt, ko piedāvā jūsu dators, un ar `omarchy powerprofiles set autodetect power-saver` iestatīt vēlamo profilu stāvoklim, kurā pašlaik atrodaties. Lai iestatītu otru stāvokli, neko neatvienojot, norādiet to tieši: `omarchy powerprofiles set battery power-saver`. Lai ko jūs izvēlētos, to pašu saņemsiet nākamreiz, kad būsiet šajā stāvoklī.

### Apturēšanas pārslēgšana

Apturēšanu pārslēdzat, terminālī palaižot `omarchy toggle suspend`. Tas tikai parāda/paslēpj opciju sadaļā _Sistēma_ (vai ar `Super + Esc`), un tad varat pārbaudīt, vai tā jūsu sistēmā darbojas konsekventi. Ja nedarbojas, ar to pašu komandu varat to atkal paslēpt.

### Hibernācijas pārslēgšana

Hibernāciju iestatāt, terminālī palaižot `omarchy hibernation setup` (tas nav pieejams Apple Silicon Mac datoros). Hibernācija izveido /swap apakšsējumu jūsu sāknēšanas diskā jūsu fiziskās RAM apjoma lielumā, tāpēc pārliecinieties, ka jums ir pietiekami daudz brīvas vietas. Datorā ar 32GB vienmēr vajadzēs 32GB+ brīvas vietas šim sējumam. Hibernācijai nepieciešams arī noklusējuma Limine sāknēšanas ielādētājs.

Kad tā būs iestatīta, sadaļā _Sistēma_ (vai ar `Super + Esc`) redzēsiet hibernācijas opciju, un tad varat pārbaudīt, vai tā jūsu sistēmā darbojas konsekventi. Ja nedarbojas, varat to atkal noņemt, palaižot `omarchy hibernation remove`.
