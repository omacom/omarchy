# Pogosta vprašanja

### Kako preklapljam med postavitvami tipkovnice?

Uredite svojo datoteko `~/.config/hypr/input.lua` in dodajte to, da boste med postavitvami preklapljali z `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Vrstica bo samodejno prikazala vašo trenutno postavitev tipkovnice, ko boste imeli nastavljenih več postavitev (in nanjo lahko tudi kliknete za preklop).

### Kako spremenim obliko ure v 12-urno?

Z desno miškino tipko kliknite uro v vrstici, da preklapljate med običajnimi oblikami, vključno z 12-urnimi. Obliko lahko nastavite tudi neposredno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To bo prikazalo Nedelja 10:55 AM.

### Kako spremenim svoj časovni pas?

Zaženite _Nastavitev > Regija > Časovni pas_ v meniju Omarchy in izberite s seznama. Če je časovni pas pravilen, a je ura sama zamaknjena, _Posodobitev > Čas_ za vas znova zažene sinhronizacijo časa.

### Kako spremenim svoj DNS, delim svoj Wi-Fi ali preverim hitrost povezave?

Vse to najdete v [omrežju](35-networking.md).

### Kako preverim, kako hiter je moj disk?

_Sprožilec > Preizkus hitrosti > Preizkus hitrosti diska_ meri trenutno hitrost branja in pisanja na vašem pogonu, ali pa `omarchy disk speedtest` iz terminala.

### Kako dodam tiskalnik?

Tiskanje je nastavljeno in deluje takoj po namestitvi, vsak tiskalnik pa dodate sami iz _Nastavitve tiskanja_ v zaganjalniku aplikacij (`Super + Space`).

Izberite _Dodaj_ in mu dajte trenutek za iskanje: tiskalnik, priključen prek USB, in večino omrežnih tiskalnikov bo našel namesto vas. Če vašega ni na seznamu, izberite _Omrežni tiskalnik > Internet Printing Protocol (ipp)_ in vnesite njegov naslov — zaslon tiskalnika ali njegova spletna stran vam bo povedala, kaj to je, običajno nekaj, kot je `192.168.1.50` z vrsto `ipp/print`. _Naprej_ nato ponudi gonilnik, pri čemer sodoben tiskalnik najbolje deluje na profilu _IPP Everywhere_ brez gonilnika, starejši pa želi gonilnik za svoj model.

Z desno miškino tipko kliknite tiskalnik in izberite _Nastavi kot privzeto_, da določite, katerega vaše aplikacije najprej dosežejo, ter _Lastnosti_, da nastavite velikost papirja, dvostransko tiskanje in kakovost.

Samodejno odkrivanje, pri katerem se tiskalniki v omrežju pojavijo, ne da bi jih dodali, je med predelavo začasno izklopljeno, zato je prvi korak zgoraj vaš in ne samodejen. Tiskanje v datoteko PDF deluje brez kakršnega koli tiskalnika.

### Kako spremenim, kam se shranjujejo posnetki zaslona ali snemanje zaslona?

Shranjeni posnetki zaslona privzeto gredo v `~/Pictures/Screenshots`. Za uporabo drugega imenika dodajte to v datoteko pod `~/.config/uwsm/env.d/` (kot je `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Enako lahko storite za snemanje zaslona z uporabo `OMARCHY_SCREENRECORD_DIR`.

Omasnap samodejno ustvari svoj imenik za posnetke zaslona. Imenik za snemanje zaslona ustvarite sami, nato znova zaženite Omarchy, da bo katera koli sprememba okolja začela veljati.

### Kako poskrbim, da zvočniki + spletna kamera delujejo na mojem Apple Studio Display?

Mislili bi, da bi moralo vse delovati že samo s priklopom USB C, a žal to ni tako. Rešitev, za katero sem ugotovil, da zanesljivo deluje, je uporaba [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Nato zvočniki in spletna kamera delujejo kot po maslu.

Ne pozabite, da imate v Omarchy vgrajen nadzor svetlosti za zaslona Apple (tako Studio kot XDR) z običajnima gumboma za svetlost na tipkovnici.

### Kako se znebim vse dodatne programske opreme?

Če ne želite programov, kot so Obsidian ali LibreOffice ali katero koli drugo prednameščeno stvar, jo lahko zelo enostavno odstranite.

Zaženite _Odstrani > Paket_, da vidite vsak nameščen paket. Nato lahko s tab izberete kateri koli paket, ki ga želite odstraniti, in z return začnete odstranjevati vse, kar ste izbrali.

Iz menija Omarchy lahko uporabite tudi _Odstrani > Spletna aplikacija_, da odstranite katere koli prednameščene spletne aplikacije, ki jih ne želite.

Ali pa zaženite _Odstrani > Prednameščene_, da v enem zamahu pometete vse prednameščene dodatke — spletne aplikacije, TUI-je in izbirne aplikacije. Bližnjice, ki so jih zagnale, izginejo z njimi, tako da vam ostane čist list vezav, ki ga lahko zapolnite s svojimi v `~/.config/hypr/bindings.lua`.

---

Za napake in pokvarjene dele glejte [razdelek Odpravljanje težav](45-troubleshooting.md).
