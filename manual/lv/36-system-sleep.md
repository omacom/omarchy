# Sistēmas miegs

Omarchy pēc noklusējuma iespējo apturēšanu un hibernāciju, bet, ja ar kādu no tiem tavā datorā rodas problēmas, vari tos izslēgt.

NVIDIA GB10 datoros, piemēram, DGX Spark un ASUS Ascent GX10, apturēšana un hibernācija ir izslēgtas, tāpat kā NVIDIA DGX OS, jo vēl nav pierādīts, ka miega režīms uz šīs aparatūras darbojas. Apturēšanas pārslēgšana un hibernācijas iestatīšana tur neattiecas. Lai miega režīmu ieslēgtu atpakaļ, izdzēs `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ar `sudo rm`; pēc tam izvēlnē atkal parādīsies apturēšana, un hibernāciju varēs iestatīt tāpat kā citos datoros. Palaižot `sudo omarchy apply hardware --install-user "$USER"`, fails tiks atjaunots.

### Enerģijas profili

Klēpjdatorā Omarchy atceras tavu enerģijas profilu atsevišķi pieslēgtam tīklam un darbam uz akumulatora, un pārslēdzas starp abiem, kad pieslēdz vai atvieno barošanu. Pēc noklusējuma tas nozīmē veiktspēju uz maiņstrāvas un līdzsvaroto režīmu uz akumulatora.

Ar `omarchy powerprofiles list` vari apskatīt, ko piedāvā tavs dators, un ar `omarchy powerprofiles set autodetect power-saver` iestatīt vajadzīgo profilu stāvoklim, kurā pašlaik atrodies. Lai iestatītu otru stāvokli, neko neatvienojot, nosauc to tieši: `omarchy powerprofiles set battery power-saver`. Ko izvēlēsies, to arī saņemsi atpakaļ nākamreiz, kad būsi šajā stāvoklī.

### Apturēšanas pārslēgšana

Apturēšanu pārslēdz, terminālī palaižot `omarchy toggle suspend`. Tas vienkārši parāda/paslēpj opciju sadaļā _System_ (vai ar `Super + Esc`), un tad vari pārbaudīt, vai tā tavā sistēmā darbojas konsekventi. Ja nedarbojas, ar to pašu komandu vari to atkal paslēpt.

### Hibernācijas pārslēgšana

Hibernāciju iestata, terminālī palaižot `omarchy hibernation setup`. Hibernācija izveido /swap apakšsējumu tavā sāknēšanas diskā tavas fiziskās RAM atmiņas lielumā, tāpēc pārliecinies, ka tev ir pietiekami daudz brīvas vietas. Datorā ar 32GB tev šim sējumam vienmēr vajadzēs 32GB+ brīvas vietas. Hibernācijai nepieciešams arī noklusējuma Limine sāknēšanas ielādētājs.

Kad tā būs iestatīta, sadaļā _System_ (vai ar `Super + Esc`) redzēsi hibernācijas opciju, un tad vari pārbaudīt, vai tā tavā sistēmā darbojas konsekventi. Ja nedarbojas, vari to atkal noņemt, palaižot `omarchy hibernation remove`.
