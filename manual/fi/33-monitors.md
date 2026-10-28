# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-skaalaukseen kykenevää retina-luokan näyttöä. Sitä tarvitset saadaksesi ne mukavat, terävät ohjelmoijafontit. Siihen lähes kaikki uudet premium-kannettavat, joissa on korkean tarkkuuden näyttö, on optimoitu. Sitä haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytön kanssa.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K-näyttö, voit käyttää murto-osasakaalausta avaamalla `~/.config/hypr/monitors.lua` (Omarchy-valikosta _Setup > Monitors_) ja vaihtamalla kyseiselle yhdistelmälle suositeltuihin arvoihin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat luultavasti käyttää vain 1x-skaalausta, joten voit käyttää näitä:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE`-muutokset koskevat muutoksen jälkeen käynnistettyjä sovelluksia (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttösi skaalausta lähimpänä kokonaislukuna). Varmista siis, että suljet muutoksen jälkeen ylisuuriksi jääneet ikkunat (tai sulje kaikki ikkunat näppäimillä `Ctrl + Alt + Del`!).

Voit myös selata nopeasti tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) läpi näppäimellä `Super + /` suurempaan ja `Super + Alt + /` pienempään, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, jossa kohdistus on, joten kannettavan näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalauksensa. Valinta tallennetaan tiedostoon `~/.config/hypr/monitors.lua` kyseisen näytön `hl.monitor`-sääntönä, joten se säilyy uudelleenkäynnistyksen jälkeen ja ohittaa `omarchy_monitor_scale`-arvon, joka pysyy skaalauksena jokaiselle näytölle, jolla ei ole omaa sääntöään.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon väliltä 9 ja 20 ja siirtää Omarchy-kuorta, GTK-sovelluksia ja päätettäsi yhdessä, joten koko työpöytä pysyy oikeissa mittasuhteissa. Suorita se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jälkijunassa tuleva: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat päätteet säilyttävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun kytket kannettavaan ulkoisen näytön, näyttö laajennetaan automaattisesti. Mutta voit vaihtaa sen sen sijaan peilaamiseen Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos kyseinen ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun laajennat, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit myös hallita tätä manuaalisesti Omarchy-valikon kohdasta _Trigger > Hardware_ tai näppäimillä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii hienosti useiden näyttöjen kanssa. Lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa ne laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä tietyn näytön kiinnittämisestä tiettyyn tarkkuuteen, sijaintiin ja kiertoon.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Pinnan alla Hyprland numeroi työtilat silti kaikkien näyttöjen yli: kannettavan näyttö (tai ensimmäinen näyttö) saa työtilat 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö säilyttää oman lohkonsa joka kerta, kun kytket sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitor-workspaces` luetteloi, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, jotka jakavat reunan asettelussasi. Näytöt, jotka koskettavat vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten liiku niiden välillä näppäimillä `Ctrl + Alt + Tab`.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevaan näyttöön, kun kyseiseen suuntaan ei ole enää ikkunaa |
| `Super + Shift + Arrow` | Vaihtaa paikkaa sillä puolella olevalla näytöllä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevaan näyttöön, sen näyttämään työtilaan |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevaan näyttöön ja säilyttää sen numeron, jos se on vapaa |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavaan tai edelliseen näyttöön asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytöllä, jolla olet |

Tutustu myös [Hyprmon](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään erillisillä kirkkaus ylös/alas -toimintonäppäimillä. Jos pidät shift-näppäintä painettuna näitä painaessasi, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet säätävät näyttöä, jossa kohdistus on, joten DDC/CI:tä puhuvat ulkoiset näytöt säädetään samalla tavalla kuin kannettavan näyttö.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos kohdistus on Apple-näytössä. Tämä tehdään `asdcontrol`-komennolla.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit poistaa tämän käytöstä esimerkiksi koodilla `hl.monitor({ output = "DP-2", disabled = true })` kohdasta _Setup > Monitors_.

Intel-koneissa Apple-näytöt kannattaa kytkeä tavallisella Thunderbolt-kaapelilla. Muissa koneissa, joissa ei ole Thunderboltia, joudut tyypillisesti käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N), jotta se toimii.
