# Prohlížeče

Omarchy je ve výchozím nastavení dodávána s prohlížečem [Chromium](https://www.chromium.org/). Je to prostá open source sestava, sladěná motivem se zbytkem vašeho systému, a je to to, co otevírá klávesová zkratka `Super + Shift + Return` a uvnitř čeho běží každá [webová aplikace](25-web-apps.md).

Pokud vám Chromium nevyhovuje, nejste na něm zaseknutí. V části _Instalovat > Prohlížeč_ v nabídce Omarchy najdete Chrome, Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/). Vyberte si jeden a Omarchy ho nainstaluje, nastaví jeho adresář zásad a použije na něj váš aktuální motiv.

## Nastavení jednoho jako výchozího

Instalace prohlížeče ho nepovýší. Jakmile je v počítači, přejděte do části _Nastavení > Výchozí > Prohlížeč_ a vyberte ho — nabídka uvádí pouze prohlížeče, které máte skutečně nainstalované, a aktuální výchozí označí zaškrtnutím.

Z terminálu to je:

```bash
omarchy default browser firefox
```

Spusťte ho bez argumentu a řekne vám aktuální výchozí prohlížeč. Tím se nastaví obsluha XDG, takže to nejsou jen klávesové zkratky Omarchy, které se přizpůsobí — cokoliv, co otevírá odkaz, od aplikace pro chat po příkaz v terminálu, přejde do prohlížeče, který jste si vybrali.

## Kopírovat URL a Stáhnout video

Prohlížeče z rodiny Chromia (samotné Chromium, Chrome, Edge a Brave) jsou dodávány se dvěma rozšířeními Omarchy, která sahají ven z prohlížeče do zbytku vašeho systému.

**Copy URL** umístí adresu aktuální karty do vaší schránky pomocí klávesové zkratky `Alt + Shift + L`. To je rychlejší než klikání do adresního řádku a kopírování, a protože prochází systémovou schránkou, nikoli schránkou prohlížeče, zobrazí se vám potvrzení v oznámení Omarchy a URL je okamžitě k dispozici v [historii schránky](08-unified-clipboard-history.md) a v každé další aplikaci. K dispozici je také tlačítko na panelu nástrojů, pokud raději klikáte.

**Download Video** uchopí video přehrávané na stránce, na kterou se díváte, pomocí klávesové zkratky `Alt + Shift + D`. URL předá programu [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na mnohem více webech než YouTube, a stahování skončí v adresáři `~/Videos`. Průběh se zobrazuje ve stejném zobrazování na obrazovce, které používá hlasitost a jas, a aktualizuje se na místě namísto hromadění oznámení. Nastavte proměnnou `OMARCHY_YTDLP_DIR`, pokud byste raději, aby soubory směřovaly jinam — kde umístit proměnné prostředí, najdete v části [FAQ](46-faq.md).

Obě rozšíření komunikují s Omarchy prostřednictvím malého nativního hostitele zasílání zpráv, který se pro vás nainstaluje společně s prohlížečem. To je část, díky které video z webové stránky skončí ve vašem domovském adresáři a URL skončí ve správci schránky, což běžné rozšíření samo o sobě nedokáže.

Jsou k dispozici pouze pro rodinu Chromia. Firefox a Zen je nedostanou.

## Firefox a Zen

Firefox a Zen pocházejí z jiné rodiny, takže se jim dostává jiného zacházení: Omarchy nainstaluje soubor zásad pro rozumná výchozí nastavení a přepne je do nativního režimu Wayland, což chcete kvůli zlomkovému škálování a plynulému posouvání trackpadem.

Nedostanou výše uvedená rozšíření pro Chromium a Omarchy na ně nepoužije motiv, takže tyto části zážitku si musíte nastavit sami.

## Opětovné odebrání prohlížeče

Cokoli, co jste sem nainstalovali, můžete znovu odebrat v části _Odebrat > Prohlížeč_. Chromium v tomto seznamu není — je součástí základního systému.
