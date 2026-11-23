# Horný panel

Pruh na vrchu vašej obrazovky je panel Omarchy. Nie je to prišróbovaný stavový panel, ale súčasť shellu Omarchy, jediného dlho bežiaceho procesu Quickshell, ktorý kreslí aj menu, oznámenia, vyskakovacie okná OSD a uzamykaciu obrazovku. Preto perfektne ladí témou so všetkým ostatným a preto sa panel otvára okamžite namiesto spúšťania novej aplikácie.

Je to aj jediná časť pracovnej plochy, ktorá je stále na obrazovke, takže sa oplatí vedieť, čo robia všetky tie malé glyfy.

## Čo na ňom je predvolene

Panel má tri časti. Vľavo sedí logo Omarchy (spúšťač menu) a indikátory pracovných plôch. V strede dostanete indikátory stavu, hodiny, Elsewhen (svetové hodiny), počasie a odznak aktualizácie Omarchy. Vpravo: systémovú lištu, rozloženie klávesnice (keď je nakonfigurované viac než jedno rozloženie alebo metóda vstupu), agentov, bluetooth, sieť, zvuk, displej a napájanie.

Niektoré z nich sa ukážu len vtedy, keď majú čo povedať. Rozloženie klávesnice sa zobrazí len vtedy, ak ste nakonfigurovali viac než jedno rozloženie alebo metódu vstupu. Odznak aktualizácie sa zobrazí len vtedy, keď čaká aktualizácia Omarchy.

## Klikanie

Takmer každý widget niečo robí pri kliknutí ľavým, pravým a stredným tlačidlom a niekoľko reaguje na posúvanie. Toto je časť, ktorú ľudia prehliadajú — pravé a stredné tlačidlo sú tam, kde sa skrýva veľa dobrých vecí.

| Widget | Ľavé | Pravé | Stredné / posúvanie |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nový terminál | — |
| Pracovné plochy | Zamerať túto pracovnú plochu na tomto monitore | — | Posúvanie: ďalšia/predchádzajúca pracovná plocha |
| Hodiny | Vyskakovacie okno kalendára | Prepnúť formát popisku | Stredné: výber časového pásma |
| Svetové hodiny | Panel svetových hodín | Obnoviť | Stredné: obnoviť |
| Počasie | Vyskakovacie okno predpovede | Úplné počasie ako oznámenie | Stredné: obnoviť |
| Zvuk | Panel zvuku | Stlmiť | Stredné: panel · posúvanie: hlasitosť |
| Mikrofón | Stlmiť mikrofón | — | Stredné: panel zvuku · posúvanie: vstupná hlasitosť |
| Sieť | Panel siete | — | — |
| Bluetooth | Panel Bluetooth | Prepnúť rádio | — |
| Displej | Panel displeja | — | Posúvanie: jas |
| Napájanie | Panel napájania | Prepnúť percento batérie | — |
| Médiá | Prehrať/pozastaviť | Vyskakovacie okno obalu | Stredné: ďalšie · posúvanie: predchádzajúce/ďalšie |
| Agenti | Panel agentov | Spustiť vášho agenta | Stredné: obnoviť využitie |
| Lišta | Umiestnením kurzora odhaliť zásuvku | Pravým na šípku spravovať | — |
| Aktualizácia Omarchy | Spustiť aktualizáciu | — | — |

Nie všetko v tejto tabuľke je na vašom paneli hneď po vybalení. Widget médií (MPRIS práve prehrávané, s posúvajúcou sa skladbou a interpretom) a widget mikrofónu sú oba zabudované, ale predvolene vypnuté — pridajte si ich, ak ich chcete, ako je opísané nižšie.

## Panely

Kliknutím na ikonu panela sa otvorí panel, čo je poriadne vyskakovacie okno s posuvníkmi, zoznamami a navigáciou klávesnicou namiesto tooltipu. Každý má aj klávesovú skratku, takže nikdy nemusíte mieriť na 16-pixlový glyf:

| Skratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Sieť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájanie |
| `Super + Ctrl + Alt + D` | Kalendár |
| `Super + Ctrl + Alt + E` | Svetové hodiny |
| `Super + Ctrl + X` | Agenti |
| `Super + Ctrl + 1-9` | Prepnúť n-tý panel v pravej časti |

Panely nie sú len údaje na čítanie. Sú miestom, kde vec skutočne urobíte:

- **Audio** má hlavný posuvník hlasitosti, výber výstupného zariadenia a mixér pre jednotlivé aplikácie, takže môžete stíšiť tú jednu kartu prehliadača bez toho, aby ste sa dotkli všetkého ostatného.
- **Network** vyhľadáva Wi-Fi, ukazuje silu signálu, pripája a umožňuje vám vybrať poskytovateľa DNS.
- **Bluetooth** uvádza vaše zariadenia s pripojením/odpojením a úrovňami batérie.
- **Power** ukazuje štatistiky batérie, prepína profily napájania (pamätá si samostatnú voľbu pre batériu a AC) a vypisuje niektoré systémové informácie.
- **Display** nesie posuvník jasu, veľkosť textu, predvoľby škálovania monitora a — keď máte viac než jednu obrazovku — ovládacie prvky pre jednotlivé monitory. Pozri [monitory](33-monitors.md) pre hlbší príbeh.
- **Clock** otvára mesačnú mriežku s číslami týždňov ISO a krokovaním po mesiacoch.
- **World clock** drží riadok pre každé mesto, s jeho počasím a ako sa jeho dňu darí. Vyhľadávanie nájde mestá aj časové pásma, takže Fort Lauderdale je Fort Lauderdale a nie New York. Ak riadok na vrchu pomenúva nesprávne mesto, kliknite naň a povedzte, kde ste; vyberte si niekde v inom časovom pásme a systémové hodiny sa tam presunú tiež, čo je praktické, keď cestujete. Umiestnite kurzor na mesto a kliknite na tlačidlo osoby, aby ste povedali, kto tam žije — obyčajné mená, alebo `@` GitHub handle, aby ste priniesli aj ich tváre.

Každý panel prijíma klávesnicu aj myš: šípky sa pohybujú, Return aktivuje, Tab prejde na susedný panel a Escape zatvorí.

`Super + Ctrl + 1-9` počíta panely zľava doprava v pravej časti, pričom preskakuje lištu, keďže nemá vlastný panel. Takže číslo zodpovedá ikone, na ktorú by ste ukázali.

### Tailscale a Dropbox

Ďalšie dva widgety sa na paneli objavia až vtedy, keď nainštalujete zodpovedajúcu službu z **Inštalácia → Služba**, a oba sa oplatí poznať, pretože robia viac než len hlásia stav.

Panel **Tailscale** pripája a odpája tailnet, prepína medzi účtami a vyberá exit node (vaše vlastné stroje aj regióny Mullvad sa zobrazia v tomto zozname). Tiež prehliada vaše stroje — a keď je jeden vybraný, `s` mu pošle súbory cez Taildrop, čo je najrýchlejší spôsob, ako presunúť súbor do vášho telefónu alebo iného notebooku. `c` kopíruje IP stroja, `n` jeho meno a `d` jeho úplné meno DNS. Na každom riadku stroja je aj tlačidlo odoslania, ak radšej klikáte. To isté z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** rieši prihlásenie, ukazuje, koľko úložiska ste využili, a uvádza nedávno synchronizované súbory.

Odstránením ktorejkoľvek služby sa jej widget vráti z panela preč.

## Indikátory

Malý zhluk v strede je widget indikátorov. Sú to stavové glyfy pre režimy, ktoré ste zapli: nerušiť, nočné svetlo, zaradené [pripomenutie](09-reminders.md), aktívne nahrávanie obrazovky a zostať bdelý, plus varovania, kým je zapnuté sudo bez hesla alebo je niekto pripojený k vzdialenej relácii. Rozsvietia sa, keď je režim aktívny, a inak zostávajú mimo cesty — umiestnite kurzor hneď vedľa nich, kde by sedeli neaktívne, aby ste na ne nakukli. Kliknutím na indikátor sa tento režim prepne. Jeden ďalší je len stavový: vzdialená relácia svieti načerveno, kým je niekto pripojený k tomuto stroju cez gliff.

Ak by ste radšej mali, aby boli vždy viditeľné, nastavte `alwaysShow` na `true` na widgete. A ak vám záleží len na niektorých z nich, uveďte tie, ktoré chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Môžete mať viac než jeden widget indikátorov, takže rôzne časti môžu zobrazovať rôzne podmnožiny.

## Preskupovanie panela

Panel sa konfiguruje sám. Nemusíte otvárať konfiguračný súbor, aby ste veci presunuli.

Chyťte prázdne miesto panela okolo stredu a potiahnite ho k inému okraju obrazovky a panel sa tam presunie — ľavý, pravý, horný alebo dolný fungujú všetky a každý widget sa prispôsobí (zvislé panely sa vrátia ku kompaktným formám len s ikonami). Kliknutie a podržanie spustí rovnaké ťahanie. Dvojitým kliknutím ľavým tlačidlom na to isté prázdne miesto prepnete pozadie panela z priehľadného na sklené na nepriehľadné. A potiahnite ľubovoľný widget, aby ste ho preusporiadali alebo hodili do inej časti; ostatné widgety sa roztiahnu, aby urobili miesto tam, kde pristane.

Stred panela je krabica: čokoľvek je v nej, zostáva vycentrované ako jedna skupina a widgety po jej stranách visia z jej okrajov. Kým ťaháte widget, krabica sa ukazuje ako obrys, alebo ako čiara cez panel, keď je prázdna, a môžete pustiť do nej alebo vedľa nej. Keď by pustenie pristálo v krabici, krabica narastie, aby widget prijala.

Widget, ktorý chcete mať poruke, ale nie vždy na očiach, môže ísť do zásuvky lišty: potiahnite ho na lištu a zásuvka sa otvorí, aby ho prijala. Sedí tam za ikonami aplikácií, ukáže sa vždy, keď sa ukáže zásuvka, a drží svoju zásuvku otvorenú, kým je jeho panel hore. Potiahnite ho späť von na panel, aby ste ho vrátili.

Ak si radšej vyberáte z menu, **Vzhľad → Panel ponúk** má pozíciu a **Pozadie panela** vyberá, ako sa panel kreslí: **Nepriehľadný panel**, **Sklený panel** (priehľadný, s tým, čo je za ním, rozmazaným) alebo **Priehľadný panel**.

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

`Super + Shift + Space` prepne panel vypnutý a späť zapnutý bez zabitia shellu — panely a skratky fungujú ďalej, len získate pixely späť. Je to aj v menu pod **Vzhľad → Panel ponúk → Skryť panel**.

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

Každý widget je jedna položka v jednom z piatich polí rozloženia a jeho nastavenia sedia inline na tejto položke — nie je žiadny samostatný súbor nastavení a žiadny podobjekt `config`. `format` hodín, `formatAlt` (to, na čo pravé kliknutie prepína) a `verticalFormat` žijú všetky priamo tam na `{ "id": "omarchy.clock" }`.

`center` je krabica v strede panela: všetko v nej je vycentrované na obrazovke ako jedna skupina. `centerBegin` a `centerEnd` visia z oboch strán krabice, čo je spôsob, ako hodiny zostávajú presne v strede, aj keď počasie a odznak aktualizácie prichádzajú a odchádzajú. Dajte do `center` viac než jeden widget a budú vycentrované spolu; nechajte ho prázdny a `centerBegin` a `centerEnd` sa stretnú v strede panela.

Jedno pravidlo, ktoré sa oplatí zvnútorniť: **keď máte vlastný `shell.json`, je kanonický**. Kým si nič neprispôsobíte, shell číta predvolený súbor Omarchy. V okamihu, keď potiahnete widget, spustíte `omarchy bar` alebo súbor upravíte sami, vlastníte ho — nie je žiadne hlboké zlučovanie, takže nové predvolené widgety v budúcich vydaniach Omarchy sa na vašom paneli automaticky neobjavia. `omarchy bar defaults` vráti dodávané rozloženie späť, kedykoľvek chcete čistý štít.

Ten istý súbor tiež drží vaše časovania nečinnosti na najvyššej úrovni, mimo kľúča `bar`: `idle.screensaver` a `idle.lock`, obe v sekundách odvtedy, čo ste šli do nečinnosti. Takže predvolený šetrič obrazovky naskočí pri 150 sekundách a zámok pri 300.
