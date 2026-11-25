# Schakelaars, inactiviteit en de schermbeveiliging

Veel van wat je dagelijks verandert, is eigenlijk geen instelling. Het is een modus die je voor een uurtje aanzet en daarna weer uit: nachtlicht terwijl je laat doorwerkt, niet storen terwijl je presenteert, wakker blijven terwijl je ergens naar kijkt. Omarchy noemt die dingen schakelaars, en ze werken allemaal op dezelfde manier — een sneltoets, een menu-item en een commando, die allemaal dezelfde schakelaar raken.

### Het schakelaarmenu

`Super + Ctrl + O` opent _Trigger > Toggle_ direct, of je kunt ernaartoe lopen vanuit het Omarchy-menu (`Super + Space`). Alles in die lijst is een schakelaar die je kunt omzetten zonder na te denken over waar de status leeft. Schakelaars voor hoe het bureaublad eruitziet, zitten ernaast, onder _Appearance_.

Vanuit de terminal zijn dezelfde schakelaars `omarchy toggle <thing>`. Voer `omarchy toggle` op zichzelf uit om de hele groep te zien.

| Schakelaar | Sneltoets | Commando |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Meldingen dempen | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wakker blijven (geen vergrendeling bij inactiviteit) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crashvastlegging | — | `omarchy toggle crash-capture` |
| Schermbeveiliging | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) themasynchronisatie | — | `omarchy toggle theme sync` |
| Menubalk | `Super + Shift + Space` | `omarchy toggle bar` |
| Bureaublad op volledig scherm (geen balk, geen tussenruimtes) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animaties, vervaging en schaduwen | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Aanraakscherm | — | `omarchy device touchscreen` |
| Onderbreken | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy device gpu hybrid` |

De schakelaars voor touchpad, aanraakscherm en hybride GPU staan onder _Trigger > Hardware_ (`Super + Ctrl + H`) in plaats van onder Toggle, omdat ze alleen verschijnen als je die hardware ook echt hebt. Die voor touchpad en aanraakscherm overleven een herlaadbeurt van Hyprland — de naam van het uitgeschakelde apparaat wordt opgeslagen in een klein statusbestand dat Hyprland bij het opstarten leest om het opnieuw uit te schakelen.

_Appearance_ bevat de menubalk en animaties, plus een paar dingen die geen `omarchy toggle`-commando's zijn maar zich hetzelfde gedragen: het batterijpercentage in de balk, de standaardindeling van werkruimtes, en onder _Windows_, tussenruimtes tussen vensters (`Super + Shift + Backspace`) en de vierkante beeldverhouding voor 1 venster (`Super + Ctrl + Backspace`).

Als Hyprland geen GPU heeft om mee te tekenen en in plaats daarvan op de CPU rendert (llvmpipe), zoals op Macs waarvan de GPU nog niet wordt ondersteund, in de meeste virtuele machines, of wanneer een grafisch stuurprogramma niet laadt, schakelt Omarchy animaties, vervaging en schaduwen voor die sessie uit en laat je dat eenmalig weten met een melding. _Appearance > Animations On_ zet ze weer aan, en Omarchy onthoudt dat ook voor latere sessies.

De meeste hiervan zijn gewoon een vlagbestand onder `~/.local/state/omarchy/toggles/`. Als je er in een script op wilt vertakken, geeft `omarchy-toggle-enabled` je een exitcode in plaats van dat je zelf moet gaan zoeken:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

De vlaggen zijn genoemd naar de uit-stand — `screensaver-off`, `suspend-off`, `bar-off` — dus hun aanwezigheid betekent dat de functie is uitgeschakeld.

### Indicatoren in de balk

Als een modus aanstaat, krijg je een klein symbool in het midden van de bovenbalk naast de klok. Dat is de indicatorenwidget, en die bevat schermopname, openstaande herinneringen, nachtlicht, niet storen en wakker blijven, plus waarschuwingen zolang wachtwoordloos sudo aanstaat of er iemand verbonden is met een externe sessie.

Inactieve indicatoren zijn verborgen. Beweeg je muis ergens over de balk en ze verschijnen gedimd in beeld, zodat je er een kunt aanklikken om hem aan te zetten zonder de sneltoets ervan te kennen. Klik je op een actieve indicator, dan zet je hem weer uit. Als je ze liever altijd allemaal ziet, zet dan `alwaysShow` op `true` bij de `omarchy.indicators`-invoer in `~/.config/omarchy/shell.json` — zie [de bovenbalk](05-the-top-bar.md) voor hoe balkwidgets worden geconfigureerd.

### Nachtlicht

Nachtlicht verwarmt het scherm naar 4000K, en als je het opnieuw schakelt, gaat het terug naar 6500K. Zet het om vanuit het schakelaarmenu (`Super + Ctrl + O`) of met `omarchy toggle nightlight`. Het wordt aangestuurd door hyprsunset, dat de schakelaar voor je start als het nog niet draait.

Standaard doet hyprsunset helemaal niets met je scherm. `~/.config/hypr/hyprsunset.conf` wordt geleverd met een identiteitsprofiel, precies zodat het scherm onaangeroerd blijft totdat je om warmte vraagt. Als je het liever op de klok laat schakelen, vervang dat dan door een tijdprofiel:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start hyprsunset vervolgens bij het inloggen door `o.launch_on_start("hyprsunset")` toe te voegen aan `~/.config/hypr/autostart.lua`. Het 4000K/6500K-paar dat de schakelaar gebruikt, ligt vast, dus het configuratiebestand is de plek waar je moet zijn als je een andere temperatuur wilt.

### Niet storen

`Super + Ctrl + Alt + ,` dempt meldingen. Er verschijnen geen toasts zolang het aanstaat, en de indicator met de doorgestreepte bel staat in de balk om je eraan te herinneren waarom het bureaublad stil is geworden.

Er gaat echter niets verloren. Gedempte meldingen worden achtergehouden: zet de laatste paar weer op het scherm met `Super + Shift + Alt + ,`. Zie [meldingen](10-notices.md) voor de rest.

Drie soorten berichten komen er nog wel doorheen: Omarchy's eigen bevestigingstoasts voor iets dat je net hebt gedaan ("Theme changed", "Screenshot saved"), kritieke waarschuwingen die vanaf de commandoregel zijn verzonden, en verificatiecodes. Chat-apps die alles als kritiek markeren om zich bij je naar voren te dringen, komen daarvoor niet in aanmerking.

### Inactiviteit

De Omarchy-shell is eigenaar van het gedrag bij inactiviteit, en de tijden staan in een `idle`-blok op het hoogste niveau in `~/.config/omarchy/shell.json`:

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

Als je de schermbeveiliging wegdoet voordat de deadline voor vergrendeling is bereikt, telt dat als activiteit en wordt de openstaande vergrendeling geannuleerd. Je wordt niet buitengesloten omdat je even naar je machine kijkt.

Om vergrendeling bij inactiviteit helemaal te stoppen, zet je met `Super + Ctrl + I` — of `omarchy toggle idle` — wakker blijven aan, en verschijnt de indicator met het koffiekopje in de balk. Die moet je hebben vóór een lange presentatie of een build die je in de gaten wilt houden. Druk er opnieuw op om terug te gaan naar normaal. `omarchy toggle idle status` drukt de huidige status af als JSON als je die vanuit een script nodig hebt.

Dit gaat over vergrendeling en de schermbeveiliging, niet over stroom. Onderbreken en slaapstand hebben hun eigen instellingen in [systeemslaap](36-system-sleep.md).

### De schermbeveiliging

De schermbeveiliging van Omarchy is ASCII-kunst die door willekeurige teksteffecten loopt, één instantie per monitor. Elke toets of muisbeweging sluit hem af.

Je kunt hem op verzoek starten vanuit _System > Screensaver_ (`Super + Esc`), wat hem geforceerd tevoorschijn haalt, zelfs als je de schermbeveiliging bij inactiviteit hebt uitgezet. Er is standaard geen sneltoets aan gekoppeld.

`omarchy toggle screensaver` is wat de schermbeveiliging bij inactiviteit uitzet, als je liever rechtstreeks van werken naar vergrendeld gaat. Elke toets, klik, scroll of muisbeweging sluit hem.

Het logo dat hij tekent, kun je zelf aanpassen, onder _Appearance > Branding > Screensaver_. Upload een png of svg en Omarchy zet het om naar ASCII. Zie [huisstijl](41-branding.md).

### Het vergrendelscherm

`Super + Ctrl + L` vergrendelt de machine. Dat start het vergrendelscherm van de Omarchy-shell, maakt het scherm leeg, zet je toetsenbordindeling terug naar de eerste, zodat je je wachtwoord niet in het verkeerde alfabet typt, en — als je het hebt draaien — vergrendelt 1Password op weg naar buiten.

Het vergrendelscherm accepteert een wachtwoord, en het accepteert ook een vingerafdruk zodra je er een hebt ingesteld. Dat, en de andere manieren om te authenticeren, worden behandeld in [hardwareauthenticatie](37-hardware-authentication.md).
