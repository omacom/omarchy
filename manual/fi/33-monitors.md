# Näytöt

Omarchy olettaa oletuksena, että käytät 2x-kykyistä retina-luokan näyttöä. Tätä tarvitset niihin hienoihin, teräviin ohjelmoijafontteihin. Siihen lähes kaikki uudet premium-kannettavat korkearesoluutioisilla näytöillä on optimoitu. Tällaista haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytön kanssa.

Mutta jos et käytä näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K, voit valita sille murtolukuskaalan yläpalkin näyttöpaneelista tai asettaa oletuksen jokaiselle näytölle avaamalla `~/.config/hypr/monitors.lua` ja vaihtamalla siihen suositukseen, joka sopii kyseiselle yhdistelmälle:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat todennäköisesti vain käyttää 1x-skaalausta, ja samaa GTK- ja X11-sovelluksille, joten voit käyttää:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE`:n muutokset koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttöskaalasi lähimmässä kokonaisluvussa). Varmista siis, että suljet muutoksen jälkeen ylisuuriksi jääneet ikkunat (tai sulje kaikki ikkunat painamalla `Ctrl + Alt + Del`!).

Voit myös käydä nopeasti läpi tärkeimmät näyttöjen skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) näppäimillä `Super + /` mennäksesi suurempaan ja `Super + Alt + /` mennäksesi pienempään, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, johon olet kohdistunut, joten kannettavan näytöllä ja ulkoisella näytöllä voi kummallakin olla oma skaalansa. Paneeli määrittää myös jokaisen näytön resoluution. Valintasi tallennetaan kyseiselle fyysiselle näytölle tiedostoon `~/.local/state/omarchy/monitors/settings`, joten ne säilyvät uudelleenkäynnistyksen yli ja seuraavat näyttöä riippumatta siitä, mihin porttiin tai telakkaan sen seuraavaksi kytket. Ne ovat ensisijaisia mihin tahansa samalle näytölle tiedostossa `~/.config/hypr/monitors.lua` olevaan sääntöön nähden, jota Omarchy ei koskaan muokkaa. Jos haluat mieluummin määrittää näyttösi kokonaan siinä tiedostossa, lisää siihen `omarchy_monitor_panel_settings = false`, ja paneelin muutokset kestävät vain siihen asti, kun Hyprland latautuu uudelleen. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, valittu skaala määrittää sen pienimmän skaalan näytöstä, joten X11-sovellukset tulevat tiheämmällä näytöllä hieman pieninä eivätkä toisella ylisuurina.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi ainoa säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon välillä 9–20 ja siirtää Omarchy-kuoren, GTK-sovellukset ja päätelaitteesi yhdessä, joten koko työpöytä pysyy oikeassa suhteessa. Suorita se ilman argumenttia nähdäksesi, missä olet nyt, ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäljessä laahaaja: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat päätteet pitävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun kytket ulkoisen näytön kannettavaasi, näyttö laajennetaan automaattisesti. Mutta voit muuttaa sen sen sijaan peilaamiseksi käyttämällä Omarchy-valikosta _Trigger > Hardware_ tai näppäimiä `Super + Ctrl + Alt + Delete`. Tämä on erityisen kätevää, jos ulkoinen näyttö on projektori ja haluat näyttää jotain samalla kun työskentelet.

Kun käytät laajennusta, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit myös hallita tätä manuaalisesti käyttämällä Omarchy-valikosta _Trigger > Hardware_ tai näppäimiä `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii erinomaisesti useiden näyttöjen kanssa. Yläpalkin näyttöpaneeli piirtää ne siihen, missä ne ovat: vedä yksi toisen sivua vasten siirtääksesi sen sinne, ja järjestys tallennetaan jokaisen näytön muiden asetusten mukana. Kaikkeen, mitä paneeli ei kata, lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa nämä laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä tietyn näytön kiinnittämisestä resoluutioon, sijaintiin ja kiertoon.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Kulissien takana Hyprland numeroi työtilat silti kaikkien näyttöjen läpi: kannettavasi näyttö (tai ensimmäinen näyttö) saa 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö pitää lohkonsa joka kerta, kun kytket sen. Käytä näitä numeroita, jos kirjoitat [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä tietylle näytölle, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitors/workspaces` listaa, mikä lohko jokaisella näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, jotka jakavat reunan asettelussasi. Näytöt, jotka koskettavat vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten käytä näppäimiä `Ctrl + Alt + Tab` päästäksesi niiden välillä.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevaan näyttöön, kun siinä suunnassa ei enää ole ikkunaa |
| `Super + Shift + Arrow` | Vaihtaa sillä puolella olevalla näytöllä olevan ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevaan näyttöön, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevaan näyttöön pitäen sen numeron, jos se on vapaa |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavaan tai edelliseen näyttöön asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytöllä, jolla olet |

Voit myös tutustua [Hyprmon](https://github.com/erans/hyprmon/), jos haluaisit TUI:n auttamaan sinua useiden näyttöjen sijoittelussa.

### Kirkkauden hallinta

Näytön kirkkautta hallitaan omistetuilla kirkkaus ylös/alas -toimintonäppäimillä. Jos pidät shiftiä pohjassa näitä painaessasi, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet hallitsevat näyttöä, johon olet kohdistunut, joten ulkoiset näytöt, jotka puhuvat DDC/CI:tä, säädetään samalla tavalla kuin kannettavan näyttö.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos olet kohdistunut Apple-näyttöön. Tämä tehdään `asdcontrol`-komennon kautta.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit kytkeä tämän pois päältä jollain tällaisella tiedostossa `~/.config/hypr/monitors.lua`: `hl.monitor({ output = "DP-2", disabled = true })`.

Intel-koneilla sinun pitäisi kytkeä Apple-näytöt tavallisella Thunderbolt-kaapelilla. Muilla koneilla, joissa ei ole Thunderboltia, joudut tyypillisesti käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N) saadaksesi sen toimimaan.
