# Pogosta vprašanja

### Kako preklapljam med postavitvami tipkovnice?

Uredite datoteko `~/.config/hypr/input.lua` in dodajte tole za preklapljanje med postavitvami s `Left Alt + Right Alt`:

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

### Kako spremenim obliko zapisa ure na 12-urno?

Z desnim klikom na uro v vrstici preklapljate med običajnimi oblikami zapisa, vključno z 12-urnimi. Obliko lahko nastavite tudi neposredno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To bo prikazalo Nedelja 10:55 AM.

### Kako spremenim svoj časovni pas?

V meniju Omarchy zaženite _Nastavitev > Regija > Časovni pas_ in izberite s seznama. Če je časovni pas pravilen, a je ura sama zašla, _Posodobitev > Čas_ za vas znova zažene sinhronizacijo časa.

### Kako spremenim svoj DNS, delim svoj Wi-Fi ali preverim hitrost svoje povezave?

Vse to boste našli v [omrežnem povezovanju](35-networking.md).

### Kako preverim, kako hiter je moj disk?

_Sprožilec > Preizkus hitrosti > Preizkus hitrosti diska_ meri sprotno hitrost branja in pisanja na vašem pogonu, ali pa iz terminala uporabite `omarchy disk speedtest`.

### Kako dodam tiskalnik?

Tiskanje je nastavljeno in deluje takoj po namestitvi, vsak tiskalnik pa dodate sami iz _Nastavitve tiskanja_ v zaganjalniku aplikacij (`Super + Alt + Space`).

Izberite _Dodaj_ in mu dajte trenutek, da poišče: tiskalnik, priključen prek USB, in večino omrežnih tiskalnikov bo našel namesto vas. Če vašega ni na seznamu, izberite _Omrežni tiskalnik > Internet Printing Protocol (ipp)_ in vnesite njegov naslov — zaslon samega tiskalnika ali njegova spletna stran vam bo povedala, kaj to je, običajno nekaj takega kot `192.168.1.50` s čakalno vrsto `ipp/print`. _Naprej_ nato ponudi gonilnik, pri čemer sodoben tiskalnik najbolje deluje na profilu _IPP Everywhere_ brez gonilnika, starejši pa želi gonilnik svojega modela.

Z desnim klikom kliknite tiskalnik in izberite _Nastavi kot privzeto_, da izberete, po katerem bodo vaše aplikacije najprej segle, ter _Lastnosti_, da nastavite velikost papirja, obojestransko tiskanje in kakovost.

Samodejno odkrivanje, pri katerem se tiskalniki v omrežju pojavijo, ne da bi jih dodali, je začasno izklopljeno, medtem ko ga predelujejo, zato je prvi korak zgoraj vaš in ne samodejen. Tiskanje v datoteko PDF deluje brez kakršnega koli tiskalnika.

### Kako spremenim, kam se shranjujejo posnetki zaslona ali snemanja zaslona?

Shranjeni posnetki zaslona privzeto gredo v `~/Pictures/Screenshots`. Če želite uporabiti drugo mapo, dodajte tole v datoteko pod `~/.config/uwsm/env.d/` (kot je `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Enako lahko naredite za snemanja zaslona z uporabo `OMARCHY_SCREENRECORD_DIR`.

Omasnap samodejno ustvari svojo mapo za posnetke zaslona. Mapo za snemanje zaslona ustvarite sami, nato pa znova zaženite Omarchy, da bo katera koli sprememba okolja začela veljati.

### Kako poskrbim, da bosta zvočnika + spletna kamera delovala na mojem Apple Studio Display?

Mislili bi si, da bo vse delovalo kar samo od sebe, ko priklopite USB C, a žal ni tako. Rešitev, za katero sem ugotovil, da zanesljivo deluje, je uporaba [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potem zvočnika in spletna kamera delujeta kot po maslu.

Ne pozabite, da imate v Omarchy vgrajen nadzor svetlosti za zaslona Apple (tako Studio kot XDR) z običajnimi tipkami za svetlost na tipkovnici.

### Kako se znebim vse odvečne programske opreme?

Če nočete programov, kot so Obsidian ali LibreOffice ali katera koli druga vnaprej nameščena stvar, jo lahko zelo enostavno odstranite.

Zaženite _Odstrani > Paket_, da si ogledate vsak nameščeni paket. Nato lahko s tab izberete kateri koli paket, ki bi ga radi odstranili, in z return začnete odstranjevati vse, kar ste izbrali.

Iz menija Omarchy lahko uporabite tudi _Odstrani > Spletna aplikacija_, da odstranite katero koli od vnaprej nameščenih spletnih aplikacij, ki je nočete.

Ali pa zaženite _Odstrani > Vnaprej nameščeno_, da v enem zamahu pometete vse vnaprej nameščene dodatke — spletne aplikacije, TUI-je in izbirne aplikacije. Bližnjice, ki so jih zagnale, izginejo z njimi, tako da vam ostane čist list vezav, ki jih lahko zapolnite s svojimi v `~/.config/hypr/bindings.lua`.

---

Za napake in pokvarjene stvari glejte [razdelek Odpravljanje težav](45-troubleshooting.md).
