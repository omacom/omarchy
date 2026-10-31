# Näytöt

Omarchy olettaa oletuksena, että käytössäsi on 2x-skaalaukseen kykenevä retina-luokan näyttö. Sitä tarvitset saadaksesi ne kivat, terävät ohjelmoijan fontit. Siihen lähes kaikki uudet korkean tarkkuuden näytöillä varustetut premium-kannettavat on optimoitu. Sitä haluaisit käyttää 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) -näytöllä tai 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) -näytöllä.

Mutta jos käytössäsi ei ole näyttöä, jonka PPI on 218 tai enemmän, haluat muuttaa näyttöasetuksia. Jos sinulla on esimerkiksi 27" tai 32" 4K-näyttö, voit käyttää murto-osasuurennusta avaamalla `~/.config/hypr/monitors.lua` (Omarchy-valikosta kohdasta _Asetukset > Näytöt_) ja vaihtamalla siihen kyseiselle yhdistelmälle sopivan suosituksen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jos käytät 1080p- tai 1440p-näyttöä, haluat todennäköisesti vain 1x-skaalauksen, joten voit käyttää tätä:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE`-muutokset koskevat sovelluksia, jotka käynnistetään muutoksen jälkeen (ja GTK kunnioittaa vain kokonaislukuja, joten pidä se näyttösi skaalausta lähimpänä kokonaislukuna). Muista siis sulkea ikkunat, jotka ovat muutoksen jälkeen liian suuria (tai sulje kaikki ikkunat painamalla `Ctrl + Alt + Del`!).

Voit myös käydä nopeasti läpi tärkeimmät näytön skaalaussuhteet (1x, 1.25x, 1.6x, 2x, 3x, 4x) painamalla `Super + /` siirtyäksesi suurempaan ja `Super + Alt + /` siirtyäksesi pienempään, tai valita yhden yläpalkin näyttöpaneelista. Nämä muuttavat vain näyttöä, johon kohdistus on, joten kannettavan näyttö ja ulkoinen näyttö voivat kumpikin käyttää omaa skaalaustaan. Valinta tallennetaan tiedostoon `~/.config/hypr/monitors.lua` kyseisen näytön `hl.monitor`-sääntönä, joten se säilyy uudelleenkäynnistyksen yli ja ohittaa `omarchy_monitor_scale`-arvon, joka pysyy skaalauksena jokaiselle näytölle, jolla ei ole omaa sääntöään. Koska `GDK_SCALE` on yksi arvo kaikille näytöille, nämä muutokset asettavat sen pienimmän skaalauksen näytön perusteella, joten X11-sovellukset näkyvät tiheämmällä näytöllä hieman pieninä sen sijaan, että ne olisivat toisella näytöllä liian suuria.

### Tekstin suurentaminen tai pienentäminen

Näytön skaalaus muuttaa kaiken kokoa. Jos haluat vain suurempaa tai pienempää _tekstiä_, siihen on yksi säädin:

```
omarchy display text size 14
```

Se ottaa pikselikoon välillä 9–20 ja siirtää Omarchy-kuorta, GTK-sovelluksia ja päätettäsi yhdessä, joten koko työpöytä pysyy oikeassa suhteessa. Suorita se ilman argumenttia nähdäksesi nykyisen asetuksesi ja `omarchy display text size reset` palataksesi oletukseen. Foot on ainoa jäljessä laahaava: sillä ei ole tapaa ladata asetuksiaan uudelleen, joten käynnissä olevat päätteet pitävät vanhan kokonsa, kunnes avaat uuden.

### Kannettavan näyttöjen laajentaminen ja peilaaminen

Kun liität kannettavaan ulkoisen näytön, näyttö laajennetaan automaattisesti. Voit kuitenkin vaihtaa sen sen sijaan peilaamiseen Omarchy-valikosta kohdasta _Liipaisin > Laitteisto_ tai painamalla `Super + Ctrl + Alt + Delete`. Tämä on erityisen hyödyllistä, jos ulkoinen näyttö on projektori ja haluat näyttää jotakin työskennellessäsi.

Kun laajennat näyttöä, kannettavan kannen sulkeminen sammuttaa sisäisen näytön automaattisesti. Kannen avaaminen kytkee sen takaisin päälle. Voit hallita tätä myös manuaalisesti Omarchy-valikosta kohdasta _Liipaisin > Laitteisto_ tai painamalla `Super + Ctrl + Delete`.

### Useiden näyttöjen järjestäminen

Hyprland toimii hienosti useiden näyttöjen kanssa. Lue lisää niiden asettelusta [Hyprlandin näyttödokumentaatiosta](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchyssa nämä laitetaan tiedostoon `~/.config/hypr/monitors.lua` `hl.monitor`-merkintöinä — tiedoston mukana tulee kommentoituja esimerkkejä tietyn näytön kiinnittämisestä tiettyyn tarkkuuteen, sijaintiin ja kiertoon.

Jokaisella näytöllä on omat työtilansa 1–10, joten `Super + 1` tarkoittaa aina sen näytön ensimmäistä työtilaa, jolla olet. Kulissien takana Hyprland numeroi työtilat silti kaikkien näyttöjen yli: kannettavasi näyttö (tai ensimmäinen näyttö) saa tilat 1–10, seuraava näyttö 11–20 ja niin edelleen, ja jokainen näyttö pitää oman lohkonsa joka kerta, kun liität sen. Käytä näitä numeroita, jos kirjoitat tietylle näytölle [työtilasääntöjä](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) tai ikkunasääntöjä, joten työtila 12 on toisen näyttösi toinen työtila. `~/.local/state/omarchy/monitor-workspaces` luettelee, mikä lohko kullakin näytöllä on.

Nuolinäppäimet toimivat näyttöjen välillä, jotka jakavat asettelussasi reunan. Näytöt, jotka koskettavat toisiaan vain kulmasta tai joiden välissä on rako, eivät ole naapureita, joten siirry niiden välillä käyttämällä `Ctrl + Alt + Tab`.

| Pikanäppäin | Näyttöjen välillä |
| --- | --- |
| `Super + Arrow` | Siirtää kohdistuksen sillä puolella olevalle näytölle, kun ikkunoita ei enää ole siihen suuntaan |
| `Super + Shift + Arrow` | Vaihtaa paikkaa sillä puolella olevan näytön ikkunan kanssa |
| `Super + Alt + Arrow` | Siirtää ikkunan ryhmään sillä puolella olevalla näytöllä |
| `Super + Shift + Ctrl + Arrow` | Siirtää ikkunan sillä puolella olevalle näytölle, sen näyttämälle työtilalle |
| `Super + Shift + Alt + Arrow` | Siirtää työtilan sillä puolella olevalle näytölle ja säilyttää sen numeron, jos se on vapaa |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Siirtää kohdistuksen seuraavalle tai edelliselle näytölle asettelusta riippumatta |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pysyvät näytöllä, jolla olet |

Voit myös tutustua [Hyprmoniin](https://github.com/erans/hyprmon/), jos haluat TUI:n auttamaan useiden näyttöjen sijoittelussa.

### Kirkkauden säätäminen

Näytön kirkkautta säädetään kirkkauden lisäämiseen ja vähentämiseen tarkoitetuilla erillisillä toimintonäppäimillä. Jos pidät Shift-näppäintä painettuna näitä painaessasi, siirryt enimmäis- tai vähimmäiskirkkauteen. Näppäimet ohjaavat näyttöä, johon kohdistus on, joten DDC/CI:tä puhuvia ulkoisia näyttöjä säädetään samalla tavalla kuin kannettavan näyttöä.

### Apple-näytöt

Jos käytät Apple-näyttöä, tavalliset näppäimistön kirkkausnäppäimet toimivat myös automaattisesti, jos kohdistus on Apple-näytöllä. Tämä tehdään `asdcontrol`-komennolla.

Huomaa, että jos käytät Apple 6K XDR -näyttöä, saatat nähdä haamunäytön `hyprctl monitors` -listauksessasi. Voit kytkeä tämän pois päältä esimerkiksi komennolla `hl.monitor({ output = "DP-2", disabled = true })` kohdasta _Asetukset > Näytöt_.

Intel-koneilla sinun pitäisi liittää Apple-näyttöihin tavallinen Thunderbolt-kaapeli. Muilla koneilla, joissa ei ole Thunderboltia, joudut yleensä käyttämään [DP + USB-A -> USB-C -kaapelia](https://www.amazon.com/dp/B0BNX7MS6N), jotta se toimii.
