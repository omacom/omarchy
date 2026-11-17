# Prohlížeče

Omarchy je ve výchozím nastavení dodávána s prohlížečem [Google Chrome](https://www.google.com/chrome/). Je sladěný motivem se zbytkem vašeho systému, otevírá ho klávesová zkratka `Super + Shift + Return` a běží v něm každá [webová aplikace](25-web-apps.md). Otevře se rovnou do okna prohlížeče: žádná uvítací obrazovka ani výzva k přihlášení, statistiky používání a hlášení o pádech se Googlu neposílají a výzvy k ochraně soukromí v reklamách jsou vypnuté. K účtu Google se kvůli synchronizaci můžete kdykoli přihlásit přes tlačítko profilu.

Pokud vám Chrome nevyhovuje, nemusíte u něj zůstávat. V části _Instalovat > Prohlížeč_ v nabídce Omarchy najdete [Chromium](https://www.chromium.org/) (prostou open source sestavu, ze které Chrome vzniká), Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/). Vyberte si jeden a Omarchy ho nainstaluje, nastaví jeho adresář zásad a použije na něj váš aktuální motiv.

## Nastavení výchozího prohlížeče

Samotná instalace prohlížeč nenastaví jako výchozí. Až bude nainstalovaný, vyberte ho v části _Nastavení > Výchozí > Prohlížeč_. Nabídka zobrazuje pouze nainstalované prohlížeče a aktuální výchozí označuje zaškrtnutím.

Z terminálu to je:

```bash
omarchy default browser firefox
```

Spusťte ho bez argumentu a řekne vám aktuální výchozí prohlížeč. Tím se nastaví obsluha XDG, takže se nepřizpůsobí jen klávesové zkratky Omarchy — cokoli, co otevírá odkaz, od aplikace pro chat po příkaz v terminálu, ho otevře v prohlížeči, který jste si vybrali.

## Copy URL a Download Video

Prohlížeče z rodiny Chromia (samotné Chromium, Chrome, Edge a Brave) jsou dodávány se dvěma rozšířeními Omarchy, která sahají ven z prohlížeče do zbytku vašeho systému.

**Copy URL** umístí adresu aktuální karty do vaší schránky pomocí klávesové zkratky `Alt + Shift + L`. To je rychlejší než klikání do adresního řádku a kopírování, a protože prochází systémovou schránkou, nikoli schránkou prohlížeče, zobrazí se vám potvrzení v oznámení Omarchy a URL je okamžitě k dispozici v [historii schránky](08-unified-clipboard-history.md) a v každé další aplikaci. K dispozici je také tlačítko na panelu nástrojů, pokud raději klikáte.

**Download Video** stáhne video přehrávané na stránce, na kterou se díváte, pomocí klávesové zkratky `Alt + Shift + D`. URL předá programu [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na mnohem více webech než YouTube, a stahování skončí v adresáři `~/Videos`. Průběh se zobrazuje ve stejném OSD, které používají hlasitost a jas, a aktualizuje se na místě namísto hromadění oznámení. Nastavte proměnnou `OMARCHY_YTDLP_DIR`, pokud byste raději, aby soubory směřovaly jinam — kde umístit proměnné prostředí, najdete v kapitole [Časté dotazy](46-faq.md).

Obě rozšíření komunikují s Omarchy prostřednictvím malého pomocného programu, který se nainstaluje společně s prohlížečem. Díky němu lze video z webové stránky uložit do vašeho domovského adresáře a URL předat správci schránky. Běžné rozšíření to samo nedokáže.

Jsou k dispozici pouze pro rodinu Chromia. Firefox a Zen je nedostanou.

## Firefox a Zen

Firefox a Zen pocházejí z jiné rodiny, takže se jim dostává jiného zacházení: Omarchy nainstaluje soubor zásad pro rozumná výchozí nastavení a přepne je do nativního režimu Wayland, což chcete kvůli zlomkovému škálování a plynulému posouvání touchpadem.

Nedostanou výše uvedená rozšíření pro Chromium a Omarchy na ně nepoužije motiv, takže tyto části zážitku si musíte nastavit sami.

## Opětovné odebrání prohlížeče

Kterýkoli z těchto prohlížečů, včetně Chrome, můžete odebrat v části _Odebrat > Prohlížeč_. Odkazy se pak otevírají v Chrome nebo Chromiu, pokud vám ten druhý zůstal nainstalovaný.
