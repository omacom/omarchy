# Schakelaars, inactiviteit en de schermbeveiliging

Veel van wat je dagelijks verandert, is eigenlijk geen instelling. Het is een modus die je een uur aanzet en daarna weer uitzet: nachtlicht terwijl je laat doorwerkt, niet storen terwijl je presenteert, wakker blijven terwijl je ergens naar kijkt. Omarchy noemt dat schakelaars, en ze werken allemaal op dezelfde manier — een sneltoets, een menu-item en een opdracht, die allemaal dezelfde schakelaar omzetten.

### Het schakelaarsmenu

`Super + Ctrl + O` opent _Trigger > Toggle_ rechtstreeks, of je kunt ernaartoe lopen via het Omarchy-menu (`Super + Space`). Alles in die lijst is een schakelaar die je omzet zonder na te denken over waar de status wordt bewaard. Schakelaars voor hoe het bureaublad eruitziet, staan ernaast, onder _Appearance_.

Vanuit de terminal zijn dezelfde schakelaars `omarchy toggle <thing>`. Voer `omarchy toggle` op zichzelf uit om de hele groep te zien.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Meldingen dempen | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wakker blijven (geen vergrendeling bij inactiviteit) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crashvastlegging | — | `omarchy toggle crash-capture` |
| Schermbeveiliging | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-themasynchronisatie | — | `omarchy toggle theme sync` |
| Menubalk | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Aanraakscherm | — | `omarchy toggle touchscreen` |
| Slaapstand | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy toggle hybrid gpu` |

De schakelaars voor touchpad, aanraakscherm en hybride GPU staan onder _Trigger > Hardware_ (`Super + Ctrl + H`) in plaats van onder Toggle, omdat ze alleen verschijnen als je die hardware daadwerkelijk hebt. De schakelaars voor touchpad en aanraakscherm overleven een herlaadactie van Hyprland — de naam van het uitgeschakelde apparaat wordt opgeslagen in een klein statusbestand dat Hyprland bij het opstarten leest om het opnieuw uit te schakelen.

_Appearance_ bevat de menubalk en animaties, plus een paar dingen die geen `omarchy toggle`-opdrachten zijn maar zich hetzelfde gedragen: het batterijpercentage in de balk, de standaardindeling van werkruimtes, en onder _Windows_ de vensterafstanden (`Super + Shift + Backspace`) en de vierkante beeldverhouding voor 1 venster (`Super + Ctrl + Backspace`).

De meeste hiervan zijn gewoon een vlagbestand onder `~/.local/state/omarchy/toggles/`. Als je er in een script op wilt vertakken, geeft `omarchy-toggle-enabled` je een exitcode in plaats van dat je ernaar moet zoeken:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

De vlaggen zijn vernoemd naar de uit-status — `screensaver-off`, `suspend-off`, `bar-off` — dus hun aanwezigheid betekent dat de functie is uitgeschakeld.

### Indicatoren in de balk

Als een modus aan staat, krijg je een klein symbool in het midden van de bovenste balk, naast de klok. Dat is de indicatorenwidget, en die bevat dicteren, schermopname, openstaande herinneringen, nachtlicht, niet storen en wakker blijven.

Inactieve indicatoren zijn verborgen. Beweeg je muis ergens over de balk en ze verschijnen gedimd, zodat je er een kunt aanklikken om hem aan te zetten zonder de sneltoets te kennen. Klik je op een actieve, dan zet je hem weer uit. Als je ze liever altijd allemaal ziet, stel dan `alwaysShow` in op `true` bij het item `omarchy.indicators` in `~/.config/omarchy/shell.json` — zie [de bovenste balk](05-the-top-bar.md) voor hoe balkwidgets worden geconfigureerd.

### Nachtlicht

Nachtlicht verwarmt het scherm naar 4000K, en als je het opnieuw omzet, gaat het terug naar 6500K. Zet het om via het schakelaarsmenu (`Super + Ctrl + O`) of met `omarchy toggle nightlight`. Het wordt aangestuurd door hyprsunset, dat de schakelaar voor je start als het nog niet draait.

Standaard doet hyprsunset helemaal niets met je scherm. `~/.config/hypr/hyprsunset.conf` wordt geleverd met een identiteitsprofiel, precies zodat het beeldscherm onaangeroerd blijft totdat je om warmte vraagt. Als je liever hebt dat het op de klok schakelt, vervang dat dan door een tijdprofiel:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start hyprsunset daarna bij het inloggen door `o.launch_on_start("hyprsunset")` toe te voegen aan `~/.config/hypr/autostart.lua`. Het 4000K/6500K-paar dat de schakelaar gebruikt, ligt vast, dus in het configuratiebestand moet je zijn als je een andere temperatuur wilt.

### Niet storen

`Super + Ctrl + Alt + ,` dempt meldingen. Er verschijnen geen toastmeldingen zolang het aan staat, en de indicator met de doorgestreepte bel staat in de balk om je eraan te herinneren waarom het bureaublad stil is geworden.

Er gaat echter niets verloren. Gedempte meldingen worden tegengehouden: zet de laatste paar terug op het scherm met `Super + Shift + Alt + ,`. Zie [meldingen](10-notices.md) voor de rest.

Twee soorten berichten komen er nog wel door: Omarchy's eigen bevestigingstoasts voor iets wat je net hebt gedaan ("Theme changed", "Screenshot saved"), en kritieke waarschuwingen die vanaf de opdrachtregel zijn verzonden. Chatapps die alles als kritiek markeren om zich aan je op te dringen, komen daar niet voor in aanmerking.

### Inactiviteit

De Omarchy-shell beheert het gedrag bij inactiviteit, en de tijden staan in een `idle`-blok op het hoogste niveau in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide getallen zijn seconden, geteld vanaf het moment dat je inactief werd — niet vanaf elkaar. Dus met de standaardwaarden verschijnt de schermbeveiliging na tweeënhalve minuut en neemt het vergrendelscherm het na vijf minuten over, of de schermbeveiliging nu heeft gedraaid of niet. Sla het bestand op en de shell neemt de nieuwe tijden meteen over.

Als je de schermbeveiliging wegdrukt vóór de vergrendelingsdeadline, telt dat als activiteit en wordt de geplande vergrendeling geannuleerd. Je wordt niet buitengesloten omdat je even naar je machine kijkt.

Om vergrendeling bij inactiviteit helemaal te stoppen, zet je met `Super + Ctrl + I` — of `omarchy toggle idle` — wakker blijven aan, en verschijnt de indicator met het koffiekopje in de balk. Dat is degene die je moet indrukken vóór een lange presentatie of een build die je wilt volgen. Druk er nogmaals op om terug te gaan naar normaal. `omarchy toggle idle status` drukt de huidige status af als JSON als je die vanuit een script nodig hebt.

Dit gaat over vergrendelen en de schermbeveiliging, niet over stroom. Slaapstand en sluimerstand hebben hun eigen instellingen in [slaapstand van het systeem](36-system-sleep.md).

### De schermbeveiliging

Omarchy's schermbeveiliging is ASCII-kunst die door willekeurige teksteffecten loopt, één instantie per monitor. Elke toets of muisbeweging beëindigt hem.

Je kunt hem op verzoek starten vanuit _System > Screensaver_ (`Super + Esc`), waarmee hij geforceerd verschijnt, zelfs als je de schermbeveiliging bij inactiviteit hebt uitgezet. Er is standaard geen sneltoets aan gebonden.

`omarchy toggle screensaver` is wat de versie bij inactiviteit uitzet, als je liever rechtstreeks van werken naar vergrendeld gaat. Hij heeft een terminal nodig die hij weet te configureren — Alacritty, Foot, Ghostty of Kitty — en laat het je weten als je standaardterminal iets anders is.

Het logo dat hij tekent, kun je zelf veranderen, onder _Appearance > Branding > Screensaver_. Upload een png of svg en Omarchy zet hem om naar ASCII. Zie [branding](41-branding.md).

### Het vergrendelscherm

`Super + Ctrl + L` vergrendelt de machine. Dat voert het vergrendelscherm van de Omarchy-shell uit, maakt het beeldscherm zwart, zet je toetsenbordindeling terug naar de eerste, zodat je je wachtwoord niet in het verkeerde alfabet typt, en — als je het hebt draaien — vergrendelt 1Password bij het afsluiten.

Het vergrendelscherm accepteert een wachtwoord, en het accepteert ook een vingerafdruk zodra je die hebt ingesteld. Dat, en de andere manieren om je te authenticeren, worden behandeld in [hardware-authenticatie](37-hardware-authentication.md).
