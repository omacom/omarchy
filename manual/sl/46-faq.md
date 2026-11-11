# Pogosta vprašanja

### Kako preklopim med postavitvami tipkovnice?

Uredite svojo datoteko `~/.config/hypr/input.lua` in dodajte to, da preklapljate med postavitvami z `Left Alt + Right Alt`:

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

Z desno tipko miške kliknite uro v vrstici, da preklapljate med običajnimi oblikami, vključno z 12-urnimi. Obliko lahko nastavite tudi neposredno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To bo prikazalo nedelja 10:55 AM.

### Kako spremenim svoj časovni pas?

Zaženite _Posodobi > Časovni pas_ v meniju Omarchy in izberite s seznama. Če je časovni pas pravilen, a je ura sama zdriftirala, bo _Posodobi > Čas_ namesto vas znova zagnal sinhronizacijo časa.

### Kako spremenim svoj DNS, delim svoj Wi-Fi ali preverim hitrost svoje povezave?

Vse to najdete v razdelku [omrežje](35-networking.md).

### Kako preverim, kako hiter je moj disk?

_Sprožilec > Preizkus hitrosti > Preizkus hitrosti diska_ meri trenutno hitrost branja in pisanja na vašem pogonu, ali pa `omarchy disk speedtest` iz terminala.

### Kako dodam tiskalnik?

Tiskanje je nastavljeno in deluje takoj po namestitvi, vsak tiskalnik pa dodate sami iz _Nastavitve tiskanja_ v zaganjalniku aplikacij (`Super + Space`).

Izberite _Dodaj_ in mu dajte trenutek za iskanje: tiskalnik, priključen prek USB, in večino omrežnih tiskalnikov bo našel namesto vas. Če vašega ni na seznamu, izberite _Omrežni tiskalnik > Internet Printing Protocol (ipp)_ in vnesite njegov naslov — kaj je ta naslov, vam bo povedal zaslon na samem tiskalniku ali njegova spletna stran, običajno nekaj takega kot `192.168.1.50` s čakalno vrsto `ipp/print`. _Naprej_ nato ponudi gonilnik, pri čemer sodoben tiskalnik najbolje deluje s profilom _IPP Everywhere_ brez gonilnika, starejši pa želi gonilnik samega modela.

Z desno tipko miške kliknite tiskalnik in izberite _Nastavi kot privzeto_, da izberete, katerega bodo vaše aplikacije najprej dosegle, ter _Lastnosti_, da nastavite velikost papirja, obojestransko tiskanje in kakovost.

Samodejno odkrivanje, pri katerem se tiskalniki v omrežju pojavijo, ne da bi jih dodali, je začasno izklopljeno, medtem ko ga predelujejo, zato je prvi korak zgoraj vaš in ne samodejen. Tiskanje v datoteko PDF deluje brez kakršnegakoli tiskalnika.

### Kako spremenim, kam se shranjujejo posnetki zaslona ali snemanja zaslona?

Shranjeni posnetki zaslona gredo privzeto v `~/Pictures/Screenshots`. Če želite uporabiti drugo mapo, dodajte to v datoteko pod `~/.config/uwsm/env.d/` (na primer `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Enako lahko naredite za snemanja zaslona z uporabo `OMARCHY_SCREENRECORD_DIR`.

Omasnap samodejno ustvari svojo mapo za posnetke zaslona. Mapo za snemanja zaslona ustvarite sami, nato znova zaženite Omarchy, da bo katera koli od sprememb okolja začela veljati.

### Kako usposobim zvočnike + spletno kamero na mojem Apple Studio Display?

Mislili bi si, da bi moralo vse delovati že samo s priklopom USB C, a žal ni tako. Rešitev, za katero sem ugotovil, da zanesljivo deluje, je uporaba [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Potem zvočniki in spletna kamera delujejo kot po maslu.

Ne pozabite, da imate v Omarchy vgrajeno upravljanje svetlosti za zaslone Apple Display (tako Studio kot XDR) z običajnima tipkama za svetlost na tipkovnici.

### Kako se znebim vse dodatne programske opreme?

Če ne želite programov, kot sta Obsidian ali LibreOffice, ali katere koli druge vnaprej nameščene stvari, jo lahko zelo enostavno odstranite.

Zaženite _Odstrani > Paket_, da si ogledate vsak nameščeni paket. Nato lahko s tab izberete kateri koli paket, ki ga želite odstraniti, in z return začnete odstranjevati vse, kar ste izbrali.

Iz menija Omarchy lahko uporabite tudi _Odstrani > Spletna aplikacija_, da odstranite katero koli vnaprej nameščeno spletno aplikacijo, ki je ne želite.

Ali pa zaženite _Odstrani > Vnaprej nameščene dodatke_, da z enim zamahom počistite vse vnaprej nameščene dodatke — spletne aplikacije, TUIs in izbirne aplikacije. Bližnjice, ki so jih zagnale, izginejo z njimi, tako da vam ostane čist list vezav, ki jih lahko zapolnite s svojimi v `~/.config/hypr/bindings.lua`.

---

Za napake in pokvarjene dele si oglejte [razdelek Odpravljanje težav](45-troubleshooting.md).
