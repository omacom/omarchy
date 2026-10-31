# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-skaalaukseen kykenevää retina-luokan näyttöä. Sitä tarvitset saadaksesi ne kivat, terävät ohjelmoijafontit. Siihen lähes kaikki uudet korkean resoluution näytöillä varustetut premium-kannettavat on optimoitu. Sen haluaisit 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K, voit valita sille murto-osaskaalauksen yläpalkin näyttöpaneelista tai asettaa oletuksen jokaiselle näytölle avaamalla `~/.config/hypr/monitors.lua` ja vaihtamalla kyseiselle yhdistelmälle suositeltuun asetukseen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat luultavasti käyttää vain 1x-skaalausta, ja samaa myös GTK- ja X11-sovelluksille, joten voit käyttää:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE`-muutokset koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK hyväksyy vain kokonaislukuja, joten pidä se näyttösi skaalausta lähimpänä kokonaislukuna). Varmista siis, että suljet ikkunat, jotka ovat muutoksen jälkeen ylisuuria (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös selata nopeasti tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) läpi näppäimellä `Super + /` kasvattaaksesi ja `Super + Alt + /` pienentääksesi, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, johon olet keskittynyt, joten kannettavan näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalauksensa. Paneeli asettaa myös jokaisen näytön resoluution. Valintasi tallennetaan kyseiselle fyysiselle näytölle tiedostoon `~/.local/state/omarchy/monitors/settings`, joten ne säilyvät uudelleenkäynnistyksen jälkeen ja seuraavat näyttöä riippumatta siitä, mihin porttiin tai telakkaan se seuraavaksi kytketään. Ne ohittavat kaikki samalle näytölle tiedostossa `~/.config/hypr/monitors.lua` olevat säännöt, jota Omarchy ei koskaan muokkaa. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, valittu skaalaus asettaa sen alimman skaalauksen näytön perusteella, joten X11-sovellukset näkyvät hieman pieninä tiheämmällä näytöllä sen sijaan, että ne olisivat ylisuuria toisella.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon väliltä 9 ja 20 ja liikuttaa Omarchy-kuorta, GTK-sovelluksia ja terminaaliasi yhdessä, joten koko työpöytä pysyy oikeissa mittasuhteissa. Aja se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jälkijunassa tuleva: sillä ei ole tapaa ladata määritystään uudelleen, joten käynnissä olevat terminaalit säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun kytket ulkoisen näytön kannettavaasi, näyttö laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaamiseen Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Alt + Delete`. Tästä on erityisesti hyötyä, jos ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun käytät laajennusta, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen käynnistää sen uudelleen. Voit myös hallita tätä manuaalisesti Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii erinomaisesti useiden näyttöjen kanssa. Yläpalkin näyttöpaneeli piirtää ne siihen, missä ne sijaitsevat: vedä yksi toisen sivua vasten siirtääksesi sen sinne, ja järjestely tallennetaan kunkin näytön muiden asetusten kanssa. Kaikkea, mitä paneeli ei kata, varten lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa nämä laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä tietyn näytön kiinnittämisestä tiettyyn resoluutioon, sijaintiin ja kiertoon.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Kulissien takana Hyprland numeroi työtilat silti kaikkien näyttöjen kesken: kannettavasi näyttö (tai ensimmäinen näyttö) saa 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö säilyttää oman lohkonsa joka kerta, kun kytket sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitors/workspaces` luettelee, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, jotka jakavat reunan asettelussasi. Näytöt, jotka koskettavat vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten käytä näppäimiä `Ctrl + Alt + Tab` liikkuaksesi niiden välillä.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää fokuksen sillä puolella olevaan näyttöön, kun siinä suunnassa ei ole enää ikkunaa jäljellä |
| `Super + Shift + Arrow` | Vaihtaa paikkaa sillä puolella olevalla näytöllä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevaan näyttöön, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevaan näyttöön säilyttäen sen numeron, jos se on vapaana |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää fokuksen seuraavaan tai edelliseen näyttöön asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät sillä näytöllä, jolla olet |

Voit myös tutustua [Hyprmon](https://github.com/erans/hyprmon/)-työkaluun, jos haluaisit TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään siihen tarkoitetuilla kirkkauden lisäys-/vähennysfunktionäppäimillä. Jos pidät shift-näppäintä painettuna näitä painaessasi, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet säätävät näyttöä, johon olet keskittynyt, joten DDC/CI:tä puhuvia ulkoisia näyttöjä säädetään samalla tavalla kuin kannettavan näyttöä.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos olet keskittynyt Apple-näyttöön. Tämä tapahtuu `asdcontrol`-komennon kautta.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit poistaa tämän käytöstä esimerkiksi merkinnällä `hl.monitor({ output = "DP-2", disabled = true })` tiedostossa `~/.config/hypr/monitors.lua`.

Intel-koneilla Apple-näyttöihin kannattaa kytkeytyä tavallisella Thunderbolt-kaapelilla. Muilla koneilla, joissa ei ole Thunderboltia, joudut tyypillisesti käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N) saadaksesi sen toimimaan.
