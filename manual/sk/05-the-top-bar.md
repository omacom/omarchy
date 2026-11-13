# Horný panel

Pruh pozdĺž hornej časti obrazovky je panel Omarchy. Nie je to prišróbovaný stavový riadok, ale súčasť shellu Omarchy, jediného dlho bežiaceho procesu Quickshell, ktorý kreslí aj menu, notifikácie, vyskakovacie okná OSD a uzamykaciu obrazovku. Preto perfektne ladí so všetkým ostatným a preto sa panel otvorí okamžite, namiesto spúšťania novej aplikácie.

Je to tiež jediná časť pracovnej plochy, ktorá je stále na obrazovke, takže stojí za to vedieť, čo robia všetky tie malé glyfy.

## Čo je na ňom predvolene

Panel má tri sekcie. Vľavo sedí logo Omarchy (spúšťač menu) a indikátory pracovných plôch. V strede máte indikátory stavu, hodiny, Elsewhen (svetové hodiny), počasie a odznak aktualizácie Omarchy. Vpravo: systémový zásobník, rozloženie klávesnice (keď je nakonfigurované viac než jedno), agenti, bluetooth, sieť, zvuk, displej a napájanie.

Niekoľko z nich sa ukáže len vtedy, keď majú čo povedať. Rozloženie klávesnice sa objaví len vtedy, ak ste nakonfigurovali viac než jedno rozloženie. Odznak aktualizácie sa objaví len vtedy, keď čaká aktualizácia Omarchy. A ikona agentov sa objaví pri prvom nájdení používania AI kódovania na počítači (pozrite [AI](17-ai.md)).

## Klikanie

Takmer každý widget niečo robí pri ľavom, pravom a strednom kliknutí a niekoľko z nich reaguje na posúvanie. Toto je časť, ktorú ľudia prehliadajú — pravé a stredné tlačidlá sú miestom, kde sa skrýva veľa dobrých vecí.

| Widget | Ľavé | Pravé | Stredné / posúvanie |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nový terminál | — |
| Pracovné plochy | Zamerať danú pracovnú plochu na tomto monitore | — | Posúvanie: nasledujúca/predchádzajúca pracovná plocha |
| Hodiny | Vyskakovacie okno kalendára | Prepínať formát popisku | Stredné: výber časového pásma |
| Počasie | Vyskakovacie okno predpovede | Úplné počasie ako notifikácia | Stredné: obnoviť |
| Zvuk | Panel zvuku | Stlmiť | Stredné: panel · posúvanie: hlasitosť |
| Mikrofón | Stlmiť mikrofón | — | Stredné: panel zvuku · posúvanie: vstupná hlasitosť |
| Sieť | Panel siete | — | — |
| Bluetooth | Panel Bluetooth | Prepnúť bezdrôtový adaptér | — |
| Displej | Panel displeja | — | Posúvanie: jas |
| Napájanie | Panel napájania | Prepnúť percentá batérie | — |
| Médiá | Prehrať/pozastaviť | Vyskakovacie okno s obalom | Stredné: nasledujúce · posúvanie: predchádzajúce/nasledujúce |
| Agenti | Panel agentov | Spustiť vášho agenta | Stredné: nasledujúce predplatné |
| Zásobník | Prejdením myši odhaliť zásuvku | Pravé na šípku na správu | — |
| Aktualizácia Omarchy | Spustiť aktualizáciu | — | — |

Nie všetko v tejto tabuľke je na vašom paneli hneď po vybalení. Widget médií (MPRIS práve hrajúce, s posúvajúcou sa skladbou a interpretom) aj widget mikrofónu sú vstavané, ale predvolene vypnuté — pridajte si ich, ak ich chcete, ako je opísané nižšie.

## Panely

Kliknutie na ikonu panela otvorí panel, čo je poriadne vyskakovacie okno s posúvačmi, zoznamami a navigáciou klávesnicou, a nie popisok. Každý má aj klávesovú skratku, takže nikdy nemusíte mieriť na 16-pixelový glyf:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Sieť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájanie |
| `Super + Ctrl + Alt + D` | Kalendár |
| `Super + Ctrl + Alt + E` | Svetové hodiny |
| `Super + Ctrl + 1-9` | Prepnúť n-tý panel v pravej sekcii |

Panely nie sú len výpisy. Sú miestom, kde vec skutočne urobíte:

- **Zvuk** má posúvač hlavnej hlasitosti, výber výstupného zariadenia a mixér pre jednotlivé aplikácie, takže môžete stíšiť jednu kartu prehliadača bez toho, aby ste zasiahli všetko ostatné.
- **Sieť** vyhľadáva Wi-Fi, ukazuje silu signálu, pripája a umožňuje vám vybrať poskytovateľa DNS.
- **Bluetooth** uvádza vaše zariadenia s pripojením/odpojením a úrovňami batérie.
- **Napájanie** ukazuje štatistiky batérie, prepína profily napájania (pamätá si samostatnú voľbu pre batériu a AC) a vypisuje niektoré systémové informácie.
- **Displej** nesie posúvač jasu, veľkosť textu, predvoľby škálovania monitora a — keď máte viac než jednu obrazovku — ovládanie pre jednotlivé monitory. Pozrite [monitory](33-monitors.md) pre hlbší príbeh.
- **Hodiny** otvárajú mesačnú mriežku s číslami týždňov ISO a krokovaním po mesiacoch.
- **Svetové hodiny** držia riadok pre každé mesto, s jeho počasím a tým, ako sa mu darí počas dňa. Vyhľadávanie nájde mestá aj časové pásma, takže Fort Lauderdale je Fort Lauderdale a nie New York. Ak riadok na vrchu pomenúva nesprávne mesto, kliknite naň a povedzte, kde ste; vyberte niekde v inom časovom pásme a systémové hodiny sa tam presunú tiež, čo je užitočné, keď cestujete. Prejdite myši nad mestom a kliknite na tlačidlo osoby, aby ste povedali, kto tam žije — obyčajné mená, alebo `@` GitHub handle, aby ste priniesli aj ich tváre.

Každý panel prijíma klávesnicu aj myš: šípky sa pohybujú, Return aktivuje, Tab prejde na susedný panel a Escape zavrie.

`Super + Ctrl + 1-9` počíta panely zľava doprava v pravej sekcii, pričom preskakuje zásobník, pretože nemá vlastný panel. Takže číslo zodpovedá ikone, na ktorú by ste ukázali.

### Tailscale a Dropbox

Dva ďalšie widgety sa na paneli objavia len vtedy, keď nainštalujete zodpovedajúcu službu z **Install → Service**, a oba stoja za poznanie, pretože robia viac než len hlásia stav.

Panel **Tailscale** pripája a odpája tailnet, prepína medzi účtami a vyberá exit node (vaše vlastné počítače aj regióny Mullvad sa zobrazia v tomto zozname). Tiež prehliada vaše počítače — a keď je jeden vybraný, `s` mu pošle súbory cez Taildrop, čo je najrýchlejší spôsob, ako presunúť súbor do telefónu alebo iného notebooku. `c` skopíruje IP počítača, `n` jeho názov a `d` jeho úplný názov DNS. Na každom riadku počítača je aj tlačidlo odoslania, ak radšej klikáte. To isté z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** rieši prihlásenie, ukazuje, koľko úložiska ste použili, a uvádza nedávno synchronizované súbory.

Odstránenie ktorejkoľvek služby vezme jej widget späť z panela.

## Indikátory

Malý zhluk v strede je widget indikátorov. Sú to glyfy stavu pre režimy, ktoré ste zapli: nerušiť, nočné svetlo, zaradená [pripomienka](09-reminders.md), aktívne nahrávanie obrazovky, zostať hore a [diktovanie](11-text-extraction-dictation.md). Rozsvietia sa, keď je režim aktívny, a inak zostávajú mimo cesty — prejdite myši tesne vedľa nich, kde by sedeli neaktívne, aby ste na ne nakukli. Kliknutie na indikátor prepne daný režim. Ešte jeden je len stavový: vzdialená relácia svieti načerveno, kým je niekto pripojený k tomuto počítaču cez gliff.

Ak by ste radšej mali, aby boli vždy viditeľné, nastavte `alwaysShow` na `true` na widgete. A ak vám záleží len na niektorých z nich, uveďte tie, ktoré chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Môžete mať viac než jeden widget indikátorov, takže rôzne sekcie môžu zobrazovať rôzne podmnožiny.

## Preusporiadanie panela

Panel sa konfiguruje sám. Nemusíte otvárať konfiguračný súbor, aby ste veci presúvali.

Chyťte prázdnu plochu panela okolo stredu a potiahnite ju smerom k inému okraju obrazovky a panel sa tam presunie — ľavá, pravá, horná alebo dolná strana fungujú všetky a každý widget sa prispôsobí (vertikálne panely sa vrátia ku kompaktným formám len s ikonami). Kliknutie a podržanie spustí rovnaké ťahanie. Dvojité ľavé kliknutie na to isté prázdne miesto prepne pozadie panela z priehľadného na sklené a nepriehľadné. A potiahnite ktorýkoľvek widget, aby ste ho preusporiadali alebo hodili do inej sekcie; ostatné widgety sa rozostúpia, aby urobili miesto tam, kde pristane.

Stred panela je box: čokoľvek v ňom zostáva vycentrované ako jedna skupina a widgety na oboch jeho stranách visia z jeho okrajov. Počas ťahania widgetu sa box ukazuje ako obrys, alebo ako čiara cez panel, keď je prázdny, a môžete pustiť doň alebo vedľa neho. Keď by pustenie pristálo v boxe, box narastie, aby widget prijal.

Widget, ktorý chcete mať poruke, ale nie vždy na očiach, môže ísť do zásuvky zásobníka: potiahnite ho na zásobník a zásuvka sa otvorí, aby ho prijala. Sedí tam za ikonami aplikácií, ukáže sa vždy, keď sa ukáže zásuvka, a drží svoju zásuvku otvorenú, kým je jeho panel hore. Potiahnite ho späť von na panel, aby ste ho vrátili.

Ak by ste radšej vyberali z menu, **Appearance → Menu Bar** má pozíciu a **Bar Background** vyberá, ako sa panel kreslí: **Opaque Bar**, **Glassy Bar** (priehľadný, s rozmazaným pozadím) alebo **Clear Bar**.

Tie isté veci majú príkazy, čo je to, čo chcete pre nastavenie [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Ak chcete widget úplne pridať alebo odstrániť, použite príkazy pluginov. `omarchy plugin list` vypíše každý widget, ktorý shell pozná, s jeho id, a potom:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrytie panela

`Super + Shift + Space` prepne panel vypnutý a späť zapnutý bez zabitia shellu — panely a klávesové skratky naďalej fungujú, len získate pixely späť. Je to aj v menu pod **Appearance → Menu Bar → Hide Bar**.

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

Každý widget je jeden záznam v jednom z piatich polí rozloženia a jeho nastavenia sedia priamo na tomto zázname — neexistuje samostatný súbor nastavení a žiadny podobjekt `config`. `format`, `formatAlt` (na čo prepne pravé kliknutie) a `verticalFormat` hodín žijú priamo tam na `{ "id": "omarchy.clock" }`.

`center` je box v strede panela: všetko v ňom je vycentrované na obrazovke ako jedna skupina. `centerBegin` a `centerEnd` visia z oboch strán boxu, čo je spôsob, ako hodiny zostávajú presne v strede, aj keď počasie a odznak aktualizácie prichádzajú a odchádzajú. Dajte do `center` viac než jeden widget a budú vycentrované spolu; nechajte ho prázdny a `centerBegin` a `centerEnd` sa stretnú v strede panela.

Jedno pravidlo, ktoré stojí za to si vryť: **keď máte vlastný `shell.json`, je kanonický**. Kým nič neprispôsobíte, shell číta predvolený súbor Omarchy. V okamihu, keď potiahnete widget, spustíte `omarchy bar` alebo súbor upravíte sami, vlastníte ho — neexistuje hlboké zlučovanie, takže nové predvolené widgety v budúcich vydaniach Omarchy sa na vašom paneli automaticky neobjavia. `omarchy bar defaults` vráti dodávané rozloženie späť, kedykoľvek chcete čistý štít.

Ten istý súbor drží aj vaše časovania nečinnosti na najvyššej úrovni, mimo kľúča `bar`: `idle.screensaver` a `idle.lock`, obe v sekundách od vašej nečinnosti. Takže predvolený šetrič obrazovky naskočí po 150 sekundách a zámok po 300.
