# VENI DE MAC AŬ WINDOWS

Se vi pasis jarojn sur macOS aŭ Windows, viajn fingrojn konas cent aferojn, kiun via cerbo forgesis, ke ĝi iam ajn lernis. Ĉi tiu kapitelo estas la traduk-tavolo: kien tiuj instinktoj iras en Omarchy. La trajtoj mem estas traktataj aliloke — ĉi tio estas nur la mapo.

### Super estas la centro de ĉio

Ĉiu memorkapaceto, kiun vi konstruis ĉirkaŭ Cmd aŭ la Windows-klavo, transiras al unu klavo: Super. Tio estas la Windows-klavo en PC-klavaro, kaj ĝi estas la ankro por preskaŭ ĉiu rapideklavo en Omarchy.

Via Spotlight aŭ Raycast aŭ Start-menua reflekso fariĝas `Super + Space`. Tio malfermas la Omarchy-menuon, kiu lanĉas aplikaĵojn, ŝanĝas agordojn, instalas softvarejn, kaptas la ekranon — preskaŭ ĉion. Komencu tajpi por filtri. `Super + Alt + Space` montras ĉiujn aplikaĵojn en unu reto, same kiel Launchpad. Vidu [navigadon](04-navigation.md).

### Ne estas doko, nek desktopaj piktogramoj

Nenio al klak por lanĉi aferojn, neniuj piktogramoj por aranĝi sur la labortablo. Aplikaĵoj startas per rapideklavo (`Super + Return` por la terminalo, `Super + Shift + Return` por la retumilo, kaj `Super + K` por listo de ĉio, kio estas mapita) aŭ per la menuo. La unika konstanta parto de la grafika interfaco estas [la supra stripo](05-the-top-bar.md), kiu kovras tion, kion la menubelto, sistemsako kaj Sciiga Centro faris por vi antaŭe — kaj preskaŭ ĉiu ilo sur ĝi faras ion per maldekstra, dekstra kaj meza klako.

### Fenestroj aranĝas sin mem

La plej granda ŝanĝo de pensmaniero: vi ne trenas fenestrojn ĉirkaŭ aŭ snapas ilin al duonoj de la ekrano. Malfermu fenestron kaj ĝi okupas la tutan ekranon. Malfermu duan kaj ili dividas ĝin. Vi neniam elŝiras fenestron el sub alia, ĉar fenestroj nekovras unu la alian.

Kiam vi vere bezonas ŝveban fenestron, `Super + T` eligas la aktivan el la kahelado (kaj reen). Sed donu al la kahelado veran ŝancon unue — ĝi estas la koro de la tuta afero. [Navigado](04-navigation.md) gvidas vin tra ĝi.

Laborspacoj ŝajnos konataj: ili estas la macOS-Spaces aŭ la Windows-virtuala labortabloj, escepto ke vi efektive uzos ilin, ĉar `Super + 1/2/3/4` saltas rekte al unu kaj `Super + Shift + 1/2/3/4` sendas la aktivan fenestron tien. Neniu animaĉa prokrasto, nur tuja salto. Ĉi tio signifas, ke vi eble ne bezonos plurajn monitorojn, se vi antaŭe kutimis tion.

### Kopiado kaj gluado simply funkcias

En Mac vi havis Cmd + C ĉie. En Windows vi havis Ctrl + C ĉie — escepto en terminalo, kie ĝi mortigas vian programon. Omarchy donas al vi `Super + C`, `Super + X` kaj `Super + V`, kaj ili funkcias ĉie, inkluzive en la terminalo. Neniu aparta reflekso por lerni por la ŝelo.

Uzantoj de Windows: via Win + V-tonuba historio loĝas sur `Super + Ctrl + V`, kaj ĝi tenas bildojn ankaŭ kiel tekston. Vidu [unified tonubo kaj historio](08-unified-clipboard-history.md).

### La traduktabelo

| Al kio vi alportas manon | En Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menuo | `Super + Space` — la Omarchy-menuo |
| AirDrop | LocalSend, per `Super + Ctrl + S` — vidu [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` aŭ `Print Screen` — vidu [ekrankopioj kaj registrado](12-screenshots-recording.md) |
| Sciiga Centro | Historio de sciigoj sur `Super + Shift + Alt + ,` |
| Time Machine (por la sistemo) | Automataj [sistemsnapshotoj](47-system-snapshots.md) ĉe ĉiu ĝisdatigo |
| App Store / elŝuti instalilon | _Instali_ en la menuo, aŭ `omarchy pkg add` — vidu [aliajn pakaĵojn](29-other-packages.md) |
| Sistemaj Agordoj / Control Panel | _Agordo_ en la menuo, kiu redaktas simplajn agorddosierojn — vidu [dotfiles](31-dotfiles.md) |

### Iuj aferoj vere diferencas

Multaj agordoj loĝas en tekstdosieroj, kiun vi redaktas, ne en paneloj, tra kiuj vi klakas. Tio sonas primitiva ĝis vi realigas, ke tio signifas, ke ĉiu ĝustigo videblas, kopieblas al via sekva maŝino kaj metiĝas sub versionan regadon. La menuo _Agordo_ vin kondukas rekte al la ĝusta dosiero kaj restartigas tion, kion necesas restartigi, kiam vi finis.

Ĝisdatigoj venas per unu komando — _Ĝisdatigi > Omarchy_ — kiu ĝisdatigas Omarchy mem kaj ĉiun pakaĵon en la sistemo, prenant snapshoton unue. Neniu ĉirkaŭa aplikaĵaj ĝisdatigantoj senatendantaj je hazardaj momentoj. Vidu [ĝisdatigojn](30-updates.md).

Softvaro venas el pakaĵmanaĝero, ne el elŝutitaj instaliloj.

Kaj kiam vi fermas fenestron, la aplikaĵo efektive ĉesiĝas. Ne ekzistas macOS-limo, kie la programo daŭre funkcias sen fenestroj. `Super + W` — aŭ `Super + Q`, se tio estas la fingromemoro, kun kiu vi alvenis — signifas for.

### Sur Mac-hardware

Omarchy funkcias bone sur Intel Mac — vidu [Mac-subtenon](44-mac-support.md). Kaj la klavaro traktas vin afable: Omarchy nemapas rearkonfigi ion, kaj Linukso traktas la Command-klavon kiel Super, do Super restas ĝuste tie, kie Cmd ĉiam estis. Via polio ne rimarkos la movon.

### Donu al ĝi du semajnojn

La instinktoj transiras pli rapide ol vi pensus. Tranzitu la [kapitelo pri rapideklavoj](07-hotkeys.md) unufoje, kaj kiam vi malamiĝas pri iu kombino, premu `Super + K` — ĝi montras al vi ĉiujn. Tio estas la sola rapideklavo, kiun vi efektive devas memorigi.