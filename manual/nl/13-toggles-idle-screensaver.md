# Schakelaars, inactiviteit en de schermbeveiliging

Veel van wat je dagelijks verandert, is eigenlijk geen instelling. Het is een modus die je voor een uur aanzet en daarna weer uitzet: nachtlicht terwijl je laat doorwerkt, niet storen terwijl je presenteert, wakker blijven terwijl je ergens naar kijkt. Omarchy noemt die dingen schakelaars, en ze werken allemaal op dezelfde manier — een sneltoets, een menu-item en een opdracht, die allemaal dezelfde schakelaar omzetten.

### Het schakelaarsmenu

`Super + Ctrl + O` opent _Trigger > Toggle_ rechtstreeks, of je kunt er via het Omarchy-menu (`Super + Space`) naartoe navigeren. Alles in die lijst is een schakelaar die je kunt omzetten zonder na te denken over waar de status wordt bewaard. Schakelaars voor hoe het bureaublad eruitziet, zitten ernaast, onder _Appearance_.

Vanuit de terminal zijn dezelfde schakelaars `omarchy toggle <thing>`. Voer `omarchy toggle` op zichzelf uit om de hele groep te zien.

| Schakelaar | Sneltoets | Opdracht |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Meldingen dempen | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wakker blijven (geen vergrendeling bij inactiviteit) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crashvastlegging | — | `omarchy toggle crash-capture` |
| Schermbeveiliging | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) themasynchronisatie | — | `omarchy toggle theme sync` |
| Menubalk | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Aanraakscherm | — | `omarchy device touchscreen` |
| Slaapstand | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy toggle hybrid gpu` |

De schakelaars voor het touchpad, het aanraakscherm en de hybride GPU staan onder _Trigger > Hardware_ (`Super + Ctrl + H`) in plaats van onder Toggle, omdat ze alleen verschijnen als je die hardware ook echt hebt. De schakelaars voor touchpad en aanraakscherm overleven een herlaadbeurt van Hyprland — de naam van het uitgeschakelde apparaat wordt opgeslagen in een klein statusbestand dat Hyprland bij het opstarten leest om het opnieuw uit te schakelen.

_Appearance_ bevat de menubalk en animaties, plus een paar dingen die geen `omarchy toggle`-opdrachten zijn maar zich hetzelfde gedragen: het batterijpercentage in de balk, de standaardindeling van werkruimtes, en onder _Windows_, venstertussenruimtes (`Super + Shift + Backspace`) en de vierkante beeldverhouding voor 1 venster (`Super + Ctrl + Backspace`).

Wanneer Hyprland geen GPU heeft om mee te tekenen en in plaats daarvan op de CPU rendert (llvmpipe), zoals op Macs waarvan de GPU nog niet wordt ondersteund, in de meeste virtuele machines, of wanneer een grafisch stuurprogramma niet laadt, schakelt Omarchy animaties, vervaging en schaduwen voor die sessie uit en laat je dat één keer weten met een melding. _Appearance > Animations On_ brengt ze terug, en Omarchy onthoudt dat ook voor latere sessies.

De meeste hiervan zijn gewoon een vlagbestand onder `~/.local/state/omarchy/toggles/`. Als je er in een script op wilt vertakken, geeft `omarchy-toggle-enabled` je een exitcode in plaats van dat je zelf moet gaan zoeken:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

De vlaggen zijn genoemd naar de uit-stand — `screensaver-off`, `suspend-off`, `bar-off` — dus hun aanwezigheid betekent dat de functie is uitgeschakeld.

### Indicatoren in de balk

Als een modus aanstaat, krijg je een klein pictogram in het midden van de bovenste balk naast de klok. Dat is de indicatorenwidget, en die bevat dicteren, schermopname, openstaande herinneringen, nachtlicht, niet storen en wakker blijven.

Inactieve indicatoren zijn verborgen. Beweeg de muis ergens over de balk en ze verschijnen gedimd in beeld, zodat je er een kunt aanklikken om hem aan te zetten zonder de sneltoets te kennen. Door op een actieve te klikken, zet je hem weer uit. Als je ze liever altijd allemaal wilt zien, zet `alwaysShow` dan op `true` bij het item `omarchy.indicators` in `~/.config/omarchy/shell.json` — zie [de bovenste balk](05-the-top-bar.md) voor hoe balkwidgets worden geconfigureerd.

### Nachtlicht

Nachtlicht warmt het scherm op naar 4000K, en door het opnieuw om te schakelen zet je het terug naar 6500K. Zet het om vanuit het schakelaarsmenu (`Super + Ctrl + O`) of met `omarchy toggle nightlight`. Het wordt aangestuurd door hyprsunset, dat de schakelaar voor je start als het nog niet draait.

Standaard doet hyprsunset helemaal niets met je scherm. `~/.config/hypr/hyprsunset.conf` wordt geleverd met een identiteitsprofiel, juist zodat het scherm onaangeroerd blijft totdat je om warmte vraagt. Als je het liever op tijd wilt laten schakelen, vervang dat dan door een tijdsprofiel:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start hyprsunset vervolgens bij het inloggen door `o.launch_on_start("hyprsunset")` toe te voegen aan `~/.config/hypr/autostart.lua`. Het paar 4000K/6500K dat de schakelaar gebruikt, ligt vast, dus het configuratiebestand is de plek waar je moet zijn als je een andere temperatuur wilt.

### Niet storen

`Super + Ctrl + Alt + ,` dempt meldingen. Er verschijnen geen toastmeldingen zolang het aanstaat, en de indicator met de doorgestreepte bel zit in de balk om je eraan te herinneren waarom het bureaublad stil is geworden.

Er gaat echter niets verloren. Gedempte meldingen worden achtergehouden: zet de laatste paar terug op het scherm met `Super + Shift + Alt + ,`. Zie [meldingen](10-notices.md) voor de rest.

Twee soorten berichten komen er nog wel door: Omarchy's eigen bevestigingstoasts voor iets wat je net hebt gedaan ("Theme changed", "Screenshot saved"), en kritieke waarschuwingen die vanaf de opdrachtregel worden verzonden. Chat-apps die alles als kritiek markeren om zich aan je op te dringen, komen daarvoor niet in aanmerking.

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

Beide getallen zijn seconden, geteld vanaf het moment dat je inactief werd — niet vanaf elkaar. Dus met de standaardwaarden verschijnt de schermbeveiliging na tweeënhalve minuut en neemt het vergrendelscherm het na vijf minuten over, of de schermbeveiliging nu heeft gedraaid of niet. Sla het bestand op en de shell pikt de nieuwe tijden meteen op.

Als je de schermbeveiliging weghaalt vóór de vergrendelingsdeadline, telt dat als activiteit en wordt de wachtende vergrendeling geannuleerd. Je wordt niet buitengesloten omdat je even naar je machine kijkt.

Om het vergrendelen bij inactiviteit helemaal te stoppen, zet `Super + Ctrl + I` — of `omarchy toggle idle` — wakker blijven aan, en verschijnt de indicator met het koffiekopje in de balk. Die moet je indrukken vóór een lange presentatie of een build die je wilt volgen. Druk er opnieuw op om terug te gaan naar normaal. `omarchy toggle idle status` drukt de huidige status af als JSON als je die vanuit een script nodig hebt.

Dit gaat over vergrendelen en de schermbeveiliging, niet over stroom. Slaapstand en sluimerstand hebben hun eigen instellingen in [systeemslaapstand](36-system-sleep.md).

### De schermbeveiliging

De schermbeveiliging van Omarchy is ASCII-kunst die door willekeurige teksteffecten loopt, één exemplaar per monitor. Elke toets of muisbeweging sluit hem af.

Je kunt hem op verzoek starten vanuit _System > Screensaver_ (`Super + Esc`), wat hem geforceerd tevoorschijn haalt, zelfs als je de schermbeveiliging bij inactiviteit hebt uitgezet. Er is standaard geen sneltoets aan gekoppeld.

`omarchy toggle screensaver` is wat de versie bij inactiviteit uitzet, als je liever rechtstreeks van werken naar vergrendeld gaat. Elke toets, klik, scroll of muisbeweging sluit hem.

Het logo dat hij tekent, kun je zelf veranderen, onder _Appearance > Branding > Screensaver_. Upload een png of svg en Omarchy zet hem om naar ASCII. Zie [branding](41-branding.md).

### Het vergrendelscherm

`Super + Ctrl + L` vergrendelt de machine. Dat start het vergrendelscherm van de Omarchy-shell, maakt het scherm leeg, zet je toetsenbordindeling terug naar de eerste, zodat je je wachtwoord niet in het verkeerde alfabet typt, en — als je het hebt draaien — vergrendelt het onderweg ook 1Password.

Het vergrendelscherm accepteert een wachtwoord, en het accepteert ook een vingerafdruk zodra je er een hebt ingesteld. Dat, en de andere manieren om je te authenticeren, worden behandeld in [hardware-authenticatie](37-hardware-authentication.md).
