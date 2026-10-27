# Näytöt

Omarchy olettaa oletuksena, että käytössäsi on 2x-skaalaukseen pystyvä retina-luokan näyttö. Tätä tarvitset saadaksesi ne kauniit, terävät ohjelmoijafontit. Lähes kaikki uudet premium-kannettavat korkean tarkkuuden näytöillä on optimoitu tähän. Tätä haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) -näytöllä tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos käytössäsi ei ole näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K -näyttö, voit käyttää murto-osaskaalausta avaamalla `~/.config/hypr/monitors.lua` (Omarchy-valikon kohdan _Setup > Monitors_ kautta) ja vaihtamalla kyseiselle yhdistelmälle suositeltuun asetukseen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat todennäköisesti käyttää vain 1x-skaalausta, joten voit käyttää:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Muutokset asetukseen `GDK_SCALE` koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK hyväksyy vain kokonaislukuja, joten pidä se näytön skaalausta lähimpänä kokonaislukuna). Varmista siis, että suljet ikkunat, jotka ovat muutoksen jälkeen ylisuuria (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös selata nopeasti läpi tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) näppäimillä `Super + /` siirtyäksesi suurempaan ja `Super + Alt + /` siirtyäksesi pienempään. Jos käytät oletuskokoonpanoa, nämä muutokset säilyvät myös uudelleenkäynnistyksen jälkeen.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon väliltä 9 ja 20 ja siirtää Omarchy shelliä, GTK-sovelluksia ja terminaaliasi yhdessä, joten koko työpöytä pysyy mittasuhteiltaan oikeana. Aja se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäljessä laahaaja: sillä ei ole mitään tapaa ladata kokoonpanoaan uudelleen, joten käynnissä olevat terminaalit säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun liität ulkoisen näytön kannettavaasi, työpöytä laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaamiseen Omarchy-valikon kohdalla _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos kyseinen ulkoinen näyttö on projektori ja haluat näyttää jotakin samalla kun työskentelet.

Kun laajennat työpöytää, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit myös ohjata tätä manuaalisesti Omarchy-valikon kohdalla _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii erinomaisesti useiden näyttöjen kanssa. Lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa ne laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä tietyn näytön kiinnittämisestä tiettyyn tarkkuuteen, sijaintiin ja kiertoon.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sillä näytöllä, jolla olet, olevaa ensimmäistä työtilaa. Taustalla Hyprland kuitenkin numeroi työtilat kaikkien näyttöjen yli: kannettavasi näyttö (tai ensimmäinen näyttö) saa 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö säilyttää oman lohkonsa joka kerta, kun liität sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitor-workspaces` luettelee, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat niiden näyttöjen välillä, jotka jakavat reunan asettelussasi. Näytöt, jotka koskettavat toisiaan vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten käytä näppäimiä `Ctrl + Alt + Tab` siirtyäksesi niiden välillä.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevalle näytölle, kun kyseiseen suuntaan ei ole enää ikkunaa |
| `Super + Shift + Arrow` | Vaihtaa paikkaa sillä puolella olevan näytön ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevalle näytölle, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevalle näytölle ja säilyttää sen numeron, jos se on vapaana |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavalle tai edelliselle näytölle asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät sillä näytöllä, jolla olet |

Voit myös tutustua [Hyprmoniin](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan sinua useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään siihen tarkoitetuilla kirkkauden lisäys- ja vähennystoimintonäppäimillä. Jos pidät Shift-näppäintä pohjassa painaessasi niitä, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet ohjaavat sitä näyttöä, johon kohdistus on, joten ulkoiset näytöt, jotka puhuvat DDC/CI:tä, säädetään samalla tavalla kuin kannettavan näyttö.

### Apple Displays

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos kohdistus on Apple-näytöllä. Tämä tehdään `asdcontrol`-komennon avulla.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -luettelossasi. Voit kytkeä tämän pois päältä esimerkiksi komennolla `hl.monitor({ output = "DP-2", disabled = true })` kohdan _Setup > Monitors_ kautta.

Intel-koneilla sinun pitäisi liittää Apple-näyttöihin tavallisella Thunderbolt-kaapelilla. Muilla koneilla, joissa ei ole Thunderboltia, joudut yleensä käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N), jotta se toimisi.
