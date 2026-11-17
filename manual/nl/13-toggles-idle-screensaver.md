# Schakelaars, inactiviteit & de schermbeveiliging

Veel van wat je dagelijks verandert, is eigenlijk geen instelling. Het is een modus die je voor een uur aanzet en daarna weer uitzet: nachtlicht terwijl je laat doorwerkt, niet storen terwijl je presenteert, wakker blijven terwijl je ergens naar kijkt. Omarchy noemt die dingen schakelaars, en ze werken allemaal op dezelfde manier — een sneltoets, een menu-item en een commando, die allemaal dezelfde schakelaar bedienen.

### Het schakelaarmenu

`Super + Ctrl + O` opent _Trigger > Toggle_ direct, of je loopt ernaartoe vanuit het Omarchy-menu (`Super + Space`). Alles in die lijst is een schakelaar die je omzet zonder na te denken over waar de status wordt bijgehouden. Schakelaars voor hoe het bureaublad eruitziet staan ernaast, onder _Appearance_.

Vanuit de terminal zijn dezelfde schakelaars `omarchy toggle <thing>`. Voer `omarchy toggle` op zichzelf uit om de hele groep te zien.

| Schakelaar | Sneltoets | Commando |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Meldingen dempen | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wakker blijven (geen inactiviteitsvergrendeling) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crashvastlegging | — | `omarchy toggle crash-capture` |
| Schermbeveiliging | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-themasynchronisatie | — | `omarchy toggle theme sync` |
| Menubalk | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Slaapstand | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy toggle hybrid gpu` |

De schakelaars voor touchpad, touchscreen en hybride GPU staan onder _Trigger > Hardware_ (`Super + Ctrl + H`) en niet onder Toggle, omdat ze alleen verschijnen als je die hardware ook echt hebt. De schakelaars voor touchpad en touchscreen overleven een herlaadbeurt van Hyprland — de naam van het uitgeschakelde apparaat wordt opgeslagen in een klein statusbestand dat Hyprland bij het opstarten leest om het opnieuw uit te schakelen.

_Appearance_ bevat de menubalk en animaties, plus een paar dingen die geen `omarchy toggle`-commando's zijn maar zich hetzelfde gedragen: het batterijpercentage in de balk, de standaardindeling van werkruimtes, en onder _Windows_, vensterafstanden (`Super + Shift + Backspace`) en de vierkante beeldverhouding met 1 venster (`Super + Ctrl + Backspace`).

Wanneer Hyprland geen GPU heeft om mee te tekenen en in plaats daarvan op de CPU rendert (llvmpipe), zoals op Macs waarvan de GPU nog niet wordt ondersteund, in de meeste virtuele machines, of wanneer een grafisch stuurprogramma niet laadt, schakelt Omarchy animaties, vervaging en schaduwen uit voor die sessie en laat je dat eenmalig weten met een melding. _Appearance > Animations On_ brengt ze terug, en Omarchy onthoudt dat ook voor latere sessies.

De meeste hiervan zijn gewoon een vlagbestand onder `~/.local/state/omarchy/toggles/`. Als je er in een script op wilt vertakken, geeft `omarchy-toggle-enabled` je een exitcode in plaats van dat je zelf moet gaan zoeken:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

De vlaggen zijn genoemd naar de uit-stand — `screensaver-off`, `suspend-off`, `bar-off` — dus hun aanwezigheid betekent dat de functie is uitgeschakeld.

### Indicatoren in de balk

Wanneer een modus aanstaat, krijg je een klein pictogram in het midden van de bovenbalk naast de klok. Dat is de indicatoren-widget, en die bevat dicteren, schermopname, openstaande herinneringen, nachtlicht, niet storen en wakker blijven.

Inactieve indicatoren zijn verborgen. Beweeg je muis ergens over de balk en ze verschijnen gedimd, zodat je er een kunt aanklikken om hem aan te zetten zonder de sneltoets te kennen. Klikken op een actieve indicator zet hem weer uit. Als je ze liever allemaal altijd ziet, zet je `alwaysShow` op `true` bij het item `omarchy.indicators` in `~/.config/omarchy/shell.json` — zie [de bovenbalk](05-the-top-bar.md) voor hoe balk-widgets worden geconfigureerd.

### Nachtlicht

Nachtlicht verwarmt het scherm naar 4000K, en nog een keer schakelen zet het terug naar 6500K. Zet het om vanuit het schakelaarmenu (`Super + Ctrl + O`) of met `omarchy toggle nightlight`. Het wordt aangestuurd door hyprsunset, dat de schakelaar voor je start als het nog niet draait.

Standaard doet hyprsunset helemaal niets met je scherm. `~/.config/hypr/hyprsunset.conf` wordt geleverd met een identiteitsprofiel, precies zodat het scherm onaangeroerd blijft tot je om warmte vraagt. Als je het liever op de klok wilt laten schakelen, vervang je dat door een tijdprofiel:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start hyprsunset vervolgens bij het inloggen door `o.launch_on_start("hyprsunset")` toe te voegen aan `~/.config/hypr/autostart.lua`. Het paar 4000K/6500K dat de schakelaar gebruikt ligt vast, dus het configuratiebestand is de plek waar je moet zijn als je een andere temperatuur wilt.

### Niet storen

`Super + Ctrl + Alt + ,` dempt meldingen. Er poppen geen meldingen op zolang het aanstaat, en de indicator met de doorgestreepte bel staat in de balk om je eraan te herinneren waarom het bureaublad stil is geworden.

Er gaat echter niets verloren. Gedempte meldingen worden achtergehouden: zet de laatste paar terug op het scherm met `Super + Shift + Alt + ,`. Zie [meldingen](10-notices.md) voor de rest.

Twee soorten berichten komen er nog wel door: Omarchy's eigen bevestigingsmeldingen voor iets wat je net hebt gedaan ("Theme changed", "Screenshot saved"), en kritieke waarschuwingen die vanaf de commandoregel worden verzonden. Chat-apps die alles als kritiek markeren om zich aan je op te dringen, komen daar niet voor in aanmerking.

### Inactiviteit

De Omarchy-shell is eigenaar van het inactiviteitsgedrag, en de timings vormen een `idle`-blok op het hoogste niveau in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide getallen zijn seconden, geteld vanaf het moment dat je inactief werd — niet vanaf elkaar. Dus met de standaardwaarden verschijnt de schermbeveiliging na tweeënhalve minuut en neemt het vergrendelscherm het na vijf minuten over, of de schermbeveiliging nu heeft gedraaid of niet. Sla het bestand op en de shell pikt de nieuwe timings meteen op.

Als je de schermbeveiliging wegdoet vóór de vergrendelingsdeadline, telt dat als activiteit en wordt de wachtende vergrendeling geannuleerd. Je wordt niet buitengesloten omdat je even naar je machine hebt gekeken.

Om het vergrendelen bij inactiviteit helemaal te stoppen, zet `Super + Ctrl + I` — of `omarchy toggle idle` — wakker blijven aan, en de indicator met het koffiekopje verschijnt in de balk. Dat is degene die je moet indrukken vóór een lange presentatie of een build die je wilt volgen. Druk er nog een keer op om terug te gaan naar normaal. `omarchy toggle idle status` print de huidige status als JSON als je die vanuit een script nodig hebt.

Dit gaat over vergrendelen en de schermbeveiliging, niet over stroom. Slaapstand en sluimerstand hebben hun eigen instellingen in [systeemslaap](36-system-sleep.md).

### De schermbeveiliging

De schermbeveiliging van Omarchy is ASCII-kunst die door willekeurige teksteffecten loopt, één instantie per monitor. Elke toets of muisbeweging beëindigt hem.

Je kunt hem op verzoek starten vanuit _System > Screensaver_ (`Super + Esc`), wat hem geforceerd tevoorschijn brengt, zelfs als je de schermbeveiliging bij inactiviteit hebt uitgezet. Er is standaard geen sneltoets aan gekoppeld.

`omarchy toggle screensaver` is wat de inactieve variant uitzet, als je liever rechtstreeks van werken naar vergrendeld gaat. Elke toets, klik, scroll of muisbeweging sluit hem.

Het logo dat hij tekent kun je zelf veranderen, onder _Appearance > Branding > Screensaver_. Upload een png of svg en Omarchy zet hem om naar ASCII. Zie [huisstijl](41-branding.md).

### Het vergrendelscherm

`Super + Ctrl + L` vergrendelt de machine. Dat start het vergrendelscherm vanuit de Omarchy-shell, maakt het scherm leeg, zet je toetsenbordindeling terug naar de eerste zodat je je wachtwoord niet in het verkeerde alfabet typt, en — als je het hebt draaien — vergrendelt het onderweg ook 1Password.

Het vergrendelscherm accepteert een wachtwoord, en het accepteert ook een vingerafdruk zodra je er een hebt ingesteld. Dat, en de andere manieren om te authenticeren, worden behandeld in [hardware-authenticatie](37-hardware-authentication.md).
