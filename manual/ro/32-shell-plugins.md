# Pluginuri de shell

Desktopul Omarchy rulează ca un singur proces Quickshell cu viață lungă, numit `omarchy-shell`, și aproape tot ce vezi pe ecran este un plugin în interiorul lui. Bara este un plugin. La fel sunt panourile care coboară din ea, suprapunerile pe tot ecranul precum selectorul de emoji și managerul de clipboard, meniul Omarchy însuși, ecranul de blocare, dialogul polkit și serviciile fără cap care îți urmăresc bateria și îți încălzesc ecranul noaptea.

Acesta nu este doar un detaliu de implementare. Înseamnă că poți opri părți ale desktopului, le poți înlocui sau îți poți scrie propriile tale fără să atingi o linie din sursa Omarchy.

Pluginurile primare vin cu Omarchy și trăiesc în `$OMARCHY_PATH/shell/plugins/`. Orice adaugi tu însuți — experimentele tale proprii sau ceva găsit pe GitHub — trăiește în `~/.config/omarchy/plugins/`. Ambele sunt descoperite în același mod la pornire, dar cele încorporate primesc interfețe de shell de încredere, în timp ce pluginurile terțe primesc o interfață limitată, restrânsă la propriul lor serviciu și ciclu de viață. Clonele celor încorporate păstrează numai configurația specifică sursei și apelurile UI necesare pentru comportamentul original.

## Cum vezi ce ai

```
omarchy plugin list
```

Asta afișează fiecare plugin descoperit cu id-ul lui, dacă este activat, dacă este primar sau terț, tipurile lui și numele de afișare. Adaugă `--json` dacă îl alimentezi în altceva.

Id-urile pluginurilor sunt în spații de nume. Cele încorporate încep toate cu `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — iar acel spațiu de nume este rezervat, așa că un plugin terț nu-l poate revendica niciodată.

## Pornirea și oprirea lor

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Sau folosește meniul: _Configurare > Plugins_ are Activează plugin, Dezactivează plugin, Adaugă plugin, Clonează plugin și Elimină plugin, fiecare cu un selector care oferă numai pluginurile care au sens pentru acea acțiune.

Starea activată este stocată în `~/.config/omarchy/shell.json`, iar regula diferă ușor pentru cele două feluri de plugin. Un plugin terț este activat exact atunci când id-ul lui apare undeva în acel fișier — ca intrare în aranjarea barei, ca intrare în `plugins[]` sau ca `bar.id`. Pluginurile primare care nu sunt widgeturi de bară sunt invers: sunt pornite implicit și se opresc numai fiind listate în `disabledPlugins[]`.

Un plugin de bară complet nu are deloc o stare oprită. Există întotdeauna exact o bară, așa că o înlocuiești activând alta. Plasarea widgeturilor de bară este acoperită în [bara de sus](05-the-top-bar.md).

## Adăugarea unui plugin din git

Un plugin terț este doar un depozit git cu un `manifest.json` la rădăcina lui.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Înainte să facă orice, îți spune răspicat că pluginurile rulează ca cod arbitrar, fără sandbox, în interiorul procesului tău shell cu viață lungă, îți arată URL-ul și îți cere să confirmi. Ia asta în serios. Interfața pluginurilor terțe nu expune direct serviciile de autentificare, iar o bară de înlocuire primește numai capabilități limitate pentru interfața configurată non-autentificare. Pluginurile vizuale partajează totuși scena QML a shell-ului și pot umbla prin obiecte părinte obișnuite, în timp ce tot codul de plugin rulează cu tot ce poate atinge contul tău de utilizator. Starea de autentificare este protejată separat, păstrând acele servicii în afara grafului de obiecte gazdă accesibil. Adaugă numai depozite pe care ești dispus să le rulezi și citește-le înainte să le activezi.

O bară de înlocuire poate randa widgeturi instalate, dar widgeturile terțe sprijinite de servicii pot avea funcționalitate redusă acolo, pentru că barei nu i se permite să ceară obiectul serviciu viu al altui plugin. Treci înapoi la `omarchy.bar` încorporat dacă un astfel de widget are nevoie de serviciul lui însoțitor.

Apoi clonează depozitul într-un director de pregătire, validează manifestul, refuză instalarea dacă alt plugin revendică deja acel id și îl mută în `~/.config/omarchy/plugins/<id>/`. Fără `--enable`, întreabă dacă îl vrei pornit acum, iar tu poți spune nu și poți merge mai întâi să citești codul. Nu rulează niciodată nimic din plugin, nu execută niciodată un cârlig de instalare și nu cere niciodată sudo — clonează fișiere, verifică manifestul și răsucește un bit prin IPC.

Actualizarea este un pull fast-forward al aceleași copii:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Fără id, actualizează fiecare plugin gestionat prin git pe care îl ai. Îți arată diff-ul înainte să-l aplice, refuză să actualizeze dacă ai schimbări locale pe care nu le poate depăși prin fast-forward și revine înapoi dacă revizia nouă pică validarea.

```
omarchy plugin remove acme.weather
```

Eliminarea dezactivează mai întâi pluginul, apoi îl șterge dacă este o copie git (depozitul este încă în amonte) sau îl dezleagă dacă este o legătură simbolică. Un folder de plugin făcut manual, fără depozit git, este mutat într-o copie de rezervă ștampilată cu data în interiorul directorului de pluginuri, în loc să fie șters de tot.

## Clonarea unui plugin încorporat ca să-l modifici

Aceasta este partea mea favorită. Dacă vrei să schimbi cum se comportă un widget încorporat, nu edita fișierele de sub `$OMARCHY_PATH` — acelea aparțin pachetului, iar următoarea actualizare le va suprascrie. Clonează-l în schimb:

```
omarchy plugin clone omarchy.clock
```

Asta copiază întregul plugin în `~/.config/omarchy/plugins/dhh.clock` (numele tău de utilizator, nu al meu), îl redenumește „My Clock”, îl activează și trece shell-ul de la cel încorporat la copia ta — păstrând poziția și setările unui widget de bară existent. Adaugă `--edit` ca să deschizi directorul nou în `$EDITOR` imediat, ceea ce face pentru tine intrarea _Configurare > Plugins > Clonează plugin_ din meniu.

Prefixul cu numele de utilizator ține id-ul clonei tale al tău, așa că partajarea ei nu se ciocnește cu a altcuiva. Apelurile făcute către id-ul încorporat original sunt direcționate către clona ta, așa că nimic din ce se referea la `omarchy.clock` nu are nevoie de actualizare. Iar dacă o dai în bară cu ea, `omarchy plugin remove dhh.clock` pune încorporatul înapoi.

Salvarea unui fișier oriunde sub `~/.config/omarchy/plugins/` reîncarcă codul pluginului automat, așa că poți lăsa editorul deschis și poți urmări cum ajung schimbările tale.

## Scrie-ți propriul plugin

Un plugin este un director cu un `manifest.json` și niște QML. Manifestul declară `schemaVersion: 1`, un `id`, `name`, `version`, unul sau mai multe `kinds` și un obiect `entryPoints` care indică fișierul QML pentru fiecare tip:

| Tip | Ce este |
|------|------------|
| `bar-widget` | O componentă pe care bara activă o poate pune într-o secțiune |
| `panel` | O fereastră plutitoare persistentă sau chemată |
| `overlay` | O suprapunere pe tot ecranul |
| `menu` | O suprafață de meniu chemată |
| `service` | Un singleton fără cap, fără UI |
| `bar` | O bară completă care o înlocuiește pe cea încorporată |

Un plugin poate declara mai multe tipuri deodată — pluginul media este atât un `service`, cât și un `bar-widget`. Widgeturile de bară primesc un bloc `barWidget` suplimentar, cu un nume de afișare, o categorie, un `defaultSection` opțional și `allowMultiple`, care spune dacă are sens să ai mai mult de unul pe bară. Majoritatea widgeturilor îl setează la `false`; distanțierele și indicatoarele îl setează la `true`.

Înainte să publici ceva, verifică-l:

```
omarchy plugin validate ./my-plugin
```

Asta rulează aceleași verificări pe care le face shell-ul la momentul încărcării: versiunea schemei, câmpurile cerute, un id care nu este rezervat, puncte de intrare care sunt căi relative sigure și există de fapt, un punct de intrare pentru fiecare tip revendicat și fără legături simbolice nicăieri în interiorul folderului.

Pentru dezvoltarea de pluginuri, vezi [referința de shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) și [catalogul de pluginuri primare](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Partajarea pluginului tău cu lumea

Odată ce ai făcut ceva ce-ți place, pune-l într-un depozit git public. Acesta este întregul mecanism de distribuție — oricine poate apoi rula `omarchy plugin add` pentru URL-ul tău și îl poate avea rulând în câteva secunde.

Ca să ajuți oamenii să-l găsească de fapt, listează-l la [plugins.omarchy.org](https://plugins.omarchy.org). Aceea este piața pentru pluginurile de shell Omarchy și este primul loc în care să te uiți când te întrebi dacă cineva a construit deja widgetul pe care ești pe cale să-l scrii. Răsfoiește-o înainte să începi!
