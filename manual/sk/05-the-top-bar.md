# Horný panel

Pruh pozdĺž vrchu obrazovky je panel Omarchy. Nie je to priskrutkovaná stavová lišta, ale súčasť shellu Omarchy, jediného dlho bežiaceho procesu Quickshell, ktorý kreslí aj ponuku, oznámenia, vyskakovacie okná OSD a zamykaciu obrazovku. Preto dokonale ladí so všetkým ostatným a panel sa otvorí okamžite, namiesto toho, aby spúšťal novú aplikáciu.

Je to aj jediný kus pracovnej plochy, ktorý je stále na obrazovke, takže stojí za to vedieť, čo všetky tie malé glyfy robia.

## Čo je na ňom predvolene

Panel má tri sekcie. Vľavo sedí logo Omarchy (spúšťač ponuky) a indikátory pracovných plôch. V strede máte indikátory stavu, hodiny, Elsewhen (svetové hodiny), počasie a odznak aktualizácie Omarchy. Vpravo: systémový zásobník, rozloženie klávesnice (keď je nakonfigurované viac než jedno), agenti, bluetooth, sieť, zvuk, displej a napájanie.

Niekoľko z nich sa zobrazí len vtedy, keď majú čo povedať. Rozloženie klávesnice sa zobrazí len vtedy, ak ste nakonfigurovali viac než jedno rozloženie. Odznak aktualizácie sa zobrazí len vtedy, keď čaká aktualizácia Omarchy. A ikona agentov sa zobrazí pri prvom nájdení využívania AI kódovania na počítači (pozri [AI](17-ai.md)).

## Klikanie

Takmer každý widget robí niečo po kliknutí ľavým, pravým a stredným tlačidlom a niekoľko z nich reaguje na posúvanie. Toto je časť, ktorú ľudia prehliadajú — pravé a stredné tlačidlo sú miestom, kde sa skrýva veľa dobrých vecí.

| Widget | Ľavé | Pravé | Stredné / posúvanie |
| --- | --- | --- | --- |
| Ponuka | Ponuka Omarchy | Nový terminál | — |
| Pracovné plochy | Zamerať tú pracovnú plochu na tomto monitore | — | Posúvanie: ďalšia/predchádzajúca pracovná plocha |
| Hodiny | Vyskakovací kalendár | Precykliť formát štítka | Stredné: výber časového pásma |
| Počasie | Vyskakovacia predpoveď | Úplné počasie ako oznámenie | Stredné: obnoviť |
| Zvuk | Panel zvuku | Stlmiť | Stredné: panel · posúvanie: hlasitosť |
| Mikrofón | Stlmiť mikrofón | — | Stredné: panel zvuku · posúvanie: vstupná hlasitosť |
| Sieť | Panel siete | — | — |
| Bluetooth | Panel Bluetooth | Prepnúť rádio | — |
| Displej | Panel displeja | — | Posúvanie: jas |
| Napájanie | Panel napájania | Prepnúť percento batérie | — |
| Médiá | Prehrať/pozastaviť | Vyskakovací obal albumu | Stredné: ďalšie · posúvanie: predchádzajúce/ďalšie |
| Agenti | Panel agentov | Spustiť vášho agenta | Stredné: ďalšie predplatné |
| Zásobník | Prejdením myšou odhaliť zásuvku | Pravým na šípku spravovať | — |
| Aktualizácia Omarchy | Spustiť aktualizáciu | — | — |

Nie všetko v tej tabuľke je na vašom paneli hneď po vybalení. Widget médií (MPRIS now-playing, s posúvajúcou sa skladbou a interpretom) a widget mikrofónu sú oba zabudované, ale predvolene vypnuté — pridajte si ich, ak ich chcete, ako je popísané nižšie.

## Panely

Kliknutie na ikonu panela otvorí panel, čo je poriadne vyskakovacie okno s posuvníkmi, zoznamami a klávesovou navigáciou namiesto tooltipu. Každý má aj klávesovú skratku, takže nikdy nemusíte mieriť na 16-pixelový glyf:

| Klávesová skratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Sieť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájanie |
| `Super + Ctrl + Alt + D` | Kalendár |
| `Super + Ctrl + Alt + E` | Svetové hodiny |
| `Super + Ctrl + 1-9` | Prepnúť n-tý panel v pravej sekcii |

Panely nie sú výpisy. Sú miestom, kde vec skutočne urobíte:

- **Zvuk** má hlavný posuvník hlasitosti, výber výstupného zariadenia a mixér pre jednotlivé aplikácie, takže môžete stíšiť tú jednu kartu prehliadača bez toho, aby ste sa dotkli všetkého ostatného.
- **Sieť** vyhľadáva Wi-Fi, ukazuje silu signálu, pripája a umožňuje vám vybrať poskytovateľa DNS.
- **Bluetooth** uvádza vaše zariadenia s pripojením/odpojením a úrovňami batérie.
- **Napájanie** ukazuje štatistiky batérie, prepína profily napájania (pamätá si samostatnú voľbu pre batériu a AC) a vypisuje nejaké systémové informácie.
- **Displej** nesie posuvník jasu, veľkosť textu, predvoľby škálovania monitora a — keď máte viac než jednu obrazovku — ovládacie prvky pre jednotlivé monitory. Hlbší príbeh pozri v [monitory](33-monitors.md).
- **Hodiny** otvárajú mesačnú mriežku s číslami týždňov ISO a krokovaním po mesiacoch.
- **Svetové hodiny** držia riadok pre každé mesto, s jeho počasím a tým, ako sa jeho dňu darí. Vyhľadávanie nájde mestečká rovnako ako časové pásma, takže Fort Lauderdale je Fort Lauderdale a nie New York. Ak riadok na vrchu pomenúva nesprávne mesto, kliknite naň a povedzte, kde ste; vyberte niekde v inom časovom pásme a systémové hodiny sa tam presunú tiež, čo je praktické, keď cestujete. Prejdite myšou nad mesto a kliknite na tlačidlo osoby, aby ste povedali, kto tam žije — obyčajné mená, alebo `@` GitHub handles, aby ste priniesli aj ich tváre.

Každý panel prijíma klávesnicu rovnako ako myš: šípky sa pohybujú, Return aktivuje, Tab prejde na susedný panel a Escape zatvorí.

`Super + Ctrl + 1-9` počíta panely zľava doprava v pravej sekcii, pričom preskakuje zásobník, keďže nemá vlastný panel. Takže číslo zodpovedá ikone, na ktorú by ste ukázali.

### Tailscale a Dropbox

Ďalšie dva widgety sa na paneli zobrazia až po nainštalovaní zodpovedajúcej služby z **Install → Service** a oba stoja za to poznať, pretože robia viac než len hlásia stav.

Panel **Tailscale** pripája a odpája tailnet, prepína medzi účtami a vyberá výstupný uzol (vaše vlastné počítače aj regióny Mullvad sa zobrazia v tom zozname). Tiež prehliada vaše počítače — a pri vybratom jednom z nich `s` odosiela súbory naň cez Taildrop, čo je najrýchlejší spôsob, ako presunúť súbor do vášho telefónu alebo iného laptopu. `c` skopíruje IP počítača, `n` jeho názov a `d` jeho úplný názov DNS. Na každom riadku počítača je aj tlačidlo odoslania, ak radšej klikáte. To isté z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** rieši prihlásenie, ukazuje, koľko úložiska ste využili, a uvádza nedávno synchronizované súbory.

Odstránenie ktorejkoľvek služby vezme jej widget späť z panela.

## Indikátory

Malý zhluk v strede je widget indikátorov. Sú to stavové glyfy pre režimy, ktoré ste zapli: nerušiť, nočné svetlo, zaradená [pripomienka](09-reminders.md), aktívne nahrávanie obrazovky, zostať hore a [diktovanie](11-text-extraction-dictation.md). Rozsvietia sa, keď je režim aktívny, a inak zostávajú mimo cesty — prejdite myšou kdekoľvek na paneli, aby ste nakukli na neaktívne. Kliknutie na indikátor prepne ten režim. Ešte jeden je len stavový: vzdialená relácia svieti načerveno, kým je niekto pripojený k tomuto počítaču cez gliff.

Ak by ste radšej mali, aby boli vždy viditeľné, nastavte `alwaysShow` na `true` na widgete. A ak vám záleží len na niektorých z nich, uveďte tie, ktoré chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Môžete mať viac než jeden widget indikátorov, takže rôzne sekcie môžu zobrazovať rôzne podmnožiny.

## Preusporiadanie panela

Panel sa konfiguruje sám. Na presúvanie vecí nemusíte otvárať konfiguračný súbor.

Chyťte prázdne miesto panela okolo stredu a potiahnite ho k inému okraju obrazovky a panel sa tam presunie — ľavý, pravý, horný alebo dolný fungujú všetky a každý widget sa prispôsobí (zvislé panely sa vrátia ku kompaktným formám len s ikonami). Kliknutie a podržanie spustí rovnaké ťahanie. Dvojité kliknutie ľavým na to isté prázdne miesto precykľuje pozadie panela z priehľadného na sklenené na nepriehľadné. A potiahnite ktorýkoľvek widget, aby ste ho preusporiadali alebo hodili do inej sekcie; ostatné widgety sa rozostúpia, aby urobili miesto tam, kde pristane.

Stred panela je box: čokoľvek je v ňom, zostáva vycentrované ako jedna skupina a widgety po jeho stranách visia z jeho okrajov. Kým ťaháte widget, box sa zobrazuje ako obrys, alebo ako čiara cez panel, keď je prázdny, a môžete pustiť doň alebo vedľa neho. Keď by pustenie pristálo v boxe, box narastie, aby widget prijal.

Widget, ktorý chcete mať poruke, ale nie vždy na očiach, môže ísť do zásuvky zásobníka: potiahnite ho na zásobník a zásuvka sa otvorí, aby ho prijala. Sedí tam za ikonami aplikácií, zobrazí sa vždy, keď sa zobrazí zásuvka, a drží svoju zásuvku otvorenú, kým je jeho panel hore. Potiahnite ho späť von na panel, aby ste ho vrátili.

Ak by ste radšej vyberali z ponuky, **Appearance → Menu Bar** má pozíciu a **Bar Background** vyberá, ako sa panel kreslí: **Opaque Bar**, **Glassy Bar** (priehľadný, s rozmazaným tým, čo je za ním), alebo **Clear Bar**.

Tie isté veci majú príkazy, čo je to, čo chcete pre nastavenie [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Na úplné pridanie alebo odstránenie widgetu použite príkazy pluginov. `omarchy plugin list` vypíše každý widget, ktorý shell pozná, s jeho id, a potom:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrytie panela

`Super + Shift + Space` prepne panel vypnutý a späť zapnutý bez zabitia shellu — panely a klávesové skratky fungujú ďalej, len získate pixely späť. Je to aj v ponuke pod **Appearance → Menu Bar → Hide Bar**.

## Konfiguračný súbor

Všetko je uložené v `~/.config/omarchy/shell.json`, pod kľúčom `bar`. Tu je orezaná verzia:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Každý widget je jeden záznam v jednom z piatich polí layoutu a jeho nastavenia sedia priamo na tom zázname — nie je žiadny samostatný súbor nastavení a žiadny podobobjekt `config`. `format`, `formatAlt` (na čo pravé kliknutie precykľuje) a `verticalFormat` hodín žijú všetky priamo tam na `{ "id": "omarchy.clock" }`.

`center` je box v strede panela: všetko v ňom je vycentrované na obrazovke ako jedna skupina. `centerBegin` a `centerEnd` visia z oboch strán boxu, čo je spôsob, ako hodiny zostávajú presne v strede, aj keď počasie a odznak aktualizácie prichádzajú a odchádzajú. Dajte do `center` viac než jeden widget a budú vycentrované spolu; nechajte ho prázdny a `centerBegin` a `centerEnd` sa stretnú v strede panela.

Jedno pravidlo, ktoré stojí za to si vryť do pamäti: **keď už máte vlastný `shell.json`, je kanonický**. Kým si nič neprispôsobíte, shell číta predvolený súbor Omarchy. V okamihu, keď potiahnete widget, spustíte `omarchy bar` alebo súbor upravíte sami, vlastníte ho — nie je žiadne hlboké zlučovanie, takže nové predvolené widgety v budúcich vydaniach Omarchy sa na vašom paneli neobjavia automaticky. `omarchy bar defaults` vráti dodávaný layout, kedykoľvek chcete čistý štít.

Ten istý súbor tiež drží vaše časovania nečinnosti na najvyššej úrovni, mimo kľúča `bar`: `idle.screensaver` a `idle.lock`, obe v sekundách od vašej nečinnosti. Takže predvolený šetrič obrazovky naskočí pri 150 sekundách a zámok pri 300.
