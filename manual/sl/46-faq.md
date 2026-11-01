# Pogosta vprašanja

### Kako preklapljam med razporeditvami tipkovnice?

Uredite svojo datoteko `~/.config/hypr/input.lua` in dodajte to za preklapljanje med razporeditvami na `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Vrstica bo samodejno prikazala vašo trenutno razporeditev tipkovnice, ko imate konfiguriranih več razporeditev (in nanjo lahko tudi kliknete za preklop).

### Kako spremenim obliko ure na 12-urno?

Z desno tipko miške kliknite uro v vrstici, da preklapljate med pogostimi oblikami, vključno z 12-urnimi. Obliko lahko nastavite tudi neposredno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To bo prikazalo Sunday 10:55 AM.

### Kako spremenim časovni pas?

Zaženite _Posodobi > Timezone_ v meniju Omarchy in izberite s seznama. Če je časovni pas pravi, ura sama pa je zdrsnila, _Posodobi > Time_ za vas znova zažene sinhronizacijo časa.

### Kako spremenim svoj DNS, delim svoj Wi-Fi ali preverim hitrost povezave?

Vse to živi v [omrežje](35-networking.md).

### Kako preverim, kako hiter je moj disk?

_Sproži > Preizkus hitrosti > Hitrost diska_ izmeri hitrost branja in pisanja v živo na vašem pogonu ali `omarchy disk speedtest` iz terminala.

### Zakaj se ne morem prijaviti v svoj Google račun v Chromiumu?

Navadna odprtokodna zgradba Chromiuma ne prinaša poverilnic OAuth, ki jih Google zahteva za prijavo v račun. V meniju Omarchy zaženite _Namesti > Service > Chromium Account_, da jih dodate, znova zaženite brskalnik in prijava bo uspela.

### Kako dodam tiskalnik?

Tiskanje je nastavljeno in deluje takoj po namestitvi, vsak tiskalnik pa dodate sami iz _Print Settings_ v zaganjalniku aplikacij (`Super + Space`).

Izberite _Add_ in pustite mu trenutek, da poišče: tiskalnik, priklopljen prek USB, in večina omrežnih tiskalnikov sta najdena za vas. Če vašega ni na seznamu, izberite _Network Printer > Internet Printing Protocol (ipp)_ in vnesite njegov naslov — zaslon samega tiskalnika ali njegova spletna stran vam bo povedala, kaj to je, običajno nekaj takega, kot je `192.168.1.50` s čakalno vrsto `ipp/print`. _Forward_ nato ponudi gonilnik, pri čemer sodoben tiskalnik najbolje deluje na profilu _IPP Everywhere_ brez gonilnika, starejši pa želi gonilnik svojega modela.

Z desno tipko miške kliknite tiskalnik in izberite _Set as Default_, da izberete, katerega vaše aplikacije dosežejo najprej, in _Properties_, da nastavite velikost papirja, obojestransko tiskanje in kakovost.

Samodejno odkrivanje, kjer se tiskalniki v omrežju pojavijo, ne da bi jih dodali, je začasno izklopljeno, medtem ko se predeluje, zato je prvi zgornji korak vaš in ne samodejen. Tiskanje v datoteko PDF deluje brez kakršnega koli tiskalnika.

### Kako spremenim, kam se shranjujejo posnetki zaslona ali snemanja zaslona?

Shranjeni posnetki zaslona privzeto gredo v `~/Pictures/Screenshots`. Za uporabo drugega imenika to dodajte v datoteko pod `~/.config/uwsm/env.d/` (kot je `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Enako lahko storite za snemanja zaslona z uporabo `OMARCHY_SCREENRECORD_DIR`.

Omasnap samodejno ustvari svoj imenik posnetkov zaslona. Imenik snemanja zaslona ustvarite sami, nato znova zaženite Omarchy, da katera koli sprememba okolja začne veljati.

### Kako poskrbim, da zvočniki + spletna kamera delujejo na mojem Apple Studio Display?

Mislili bi, da bi moralo vse delovati samo s priklopom USB C, a žal ni tako. Rešitev, ki sem jo našel, da zanesljivo deluje, je uporaba [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potem zvočniki in spletna kamera delujejo kot urica.

Ne pozabite, da imate v Omarchyju vgrajen nadzor svetlosti za zaslone Apple (tako Studio kot XDR) z uporabo običajnih gumbov za svetlost na tipkovnici.

### Kako se znebim vse dodatne programske opreme?

Če ne želite programov, kot so Obsidian ali LibreOffice ali kateri koli drugi vnaprej nameščeni zadevi, jih lahko zelo enostavno odstranite.

Zaženite _Odstrani > Package_, da vidite vsak nameščeni paket. Nato lahko s tab izberete vsak paket, ki ga želite odstraniti, in z return začnete odstranjevati vse, kar ste izbrali.

Uporabite lahko tudi _Odstrani > Web App_ v meniju Omarchy, da odstranite katero koli vnaprej nameščeno spletno aplikacijo, ki je ne želite.

Ali zaženite _Odstrani > Preinstalls_, da v enem zamahu pometete vse vnaprej nameščene dodatke — spletne aplikacije, TUI-je in izbirne aplikacije — naenkrat. Bližnjice, ki so jih zaganjale, izginejo z njimi, tako da vam ostane čista karta vezav, ki jo zapolnite s svojimi v `~/.config/hypr/bindings.lua`.

---

Za napake in pokvarjene dele glejte [odsek Odpravljanje težav](45-troubleshooting.md).
