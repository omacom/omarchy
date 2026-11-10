# Bara de sus

Fâșia de-a lungul părții de sus a ecranului este bara Omarchy. Nu este o bară de stare atașată ulterior, ci parte din shell-ul Omarchy, singurul proces Quickshell de lungă durată care desenează și meniul, notificările, ferestrele pop-up OSD și ecranul de blocare. De aceea se potrivește perfect ca temă cu tot restul și de aceea un panou se deschide instantaneu, în loc să pornească o aplicație nouă.

Este și singura parte a desktopului care este mereu pe ecran, așa că merită să știți ce fac toate acele mici glife.

## Ce este pe ea în mod implicit

Bara are trei secțiuni. În stânga se află sigla Omarchy (lansatorul de meniu) și indicatorii spațiilor de lucru. În centru aveți indicatorii de stare, ceasul, Elsewhen (un ceas mondial), vremea și o insignă de actualizare Omarchy. În dreapta: tava de sistem, dispunerea tastaturii (când este configurată mai mult de una), agenții, bluetooth, rețeaua, sunetul, afișajul și alimentarea.

Câteva dintre acestea apar doar atunci când au ceva de spus. Dispunerea tastaturii apare doar dacă ați configurat mai mult de o dispunere. Insigna de actualizare apare doar când așteaptă o actualizare Omarchy. Iar pictograma agenților apare prima dată când Omarchy găsește utilizare AI de programare pe aparat (vedeți [AI](17-ai.md)).

## Interacțiunea prin clicuri

Aproape fiecare widget face ceva la clic stânga, dreapta și mijloc, iar mai multe răspund la derulare. Aceasta este partea pe care oamenii o ratează — butoanele din dreapta și din mijloc sunt locul unde se ascund multe dintre lucrurile bune.

| Widget | Stânga | Dreapta | Mijloc / derulare |
| --- | --- | --- | --- |
| Meniu | Meniul Omarchy | Terminal nou | — |
| Spații de lucru | Focalizează acel spațiu de lucru pe acest monitor | — | Derulare: spațiul de lucru următor/anterior |
| Ceas | Fereastră pop-up cu calendar | Parcurge ciclic formatul etichetei | Mijloc: selector de fus orar |
| Vreme | Fereastră pop-up cu prognoza | Vremea completă ca notificare | Mijloc: reîmprospătare |
| Audio | Panoul audio | Dezactivează sunetul | Mijloc: panou · derulare: volum |
| Microfon | Dezactivează microfonul | — | Mijloc: panoul audio · derulare: volum de intrare |
| Rețea | Panoul de rețea | — | — |
| Bluetooth | Panoul Bluetooth | Comută radioul | — |
| Afișaj | Panoul de afișaj | — | Derulare: luminozitate |
| Alimentare | Panoul de alimentare | Comută procentajul bateriei | — |
| Media | Redare/pauză | Fereastră pop-up cu coperta | Mijloc: următorul · derulare: anterior/următorul |
| Agenți | Panoul agenților | Lansează agentul dvs. | Mijloc: abonamentul următor |
| Tavă | Treceți cu mouse-ul pentru a dezvălui sertarul | Clic dreapta pe chevron pentru gestionare | — |
| Actualizare Omarchy | Rulează actualizarea | — | — |

Nu tot ce este în acel tabel se află pe bara dvs. din start. Widgetul media (MPRIS now-playing, cu o piesă și un artist care derulează) și widgetul microfon sunt ambele integrate, dar dezactivate în mod implicit — adăugați-le dacă le doriți, așa cum este descris mai jos.

## Panourile

Clicul pe o pictogramă din bară deschide un panou, care este o fereastră pop-up propriu-zisă cu glisoare, liste și navigare de la tastatură, mai degrabă decât un tooltip. Fiecare are și o tastă rapidă, așa că nu trebuie niciodată să țintiți o glifă de 16 pixeli:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Panourile nu sunt simple afișaje de citire. Ele sunt locul unde chiar faceți lucrul respectiv:

- **Audio** are un glisor principal de volum, un selector de dispozitiv de ieșire și un mixer per aplicație, așa că puteți reduce volumul acelei file de browser fără să atingeți tot restul.
- **Network** scanează după Wi-Fi, arată puterea semnalului, se conectează și vă permite să alegeți un furnizor DNS.
- **Bluetooth** listează dispozitivele dvs. cu conectare/deconectare și niveluri ale bateriei.
- **Power** arată statisticile bateriei, comută profilurile de alimentare (reține o alegere separată pentru baterie și AC) și afișează câteva informații despre sistem.
- **Display** are un glisor de luminozitate, dimensiunea textului, presetări de scalare a monitorului și — când aveți mai mult de un ecran — comenzi per monitor. Vedeți [monitoare](33-monitors.md) pentru povestea mai detaliată.
- **Clock** deschide o grilă lunară cu numere de săptămână ISO și parcurgere a lunilor.
- **World clock** păstrează un rând per oraș, cu vremea lui și cum decurge ziua lui. Căutarea găsește orașe mici la fel ca fuse orare, așa că Fort Lauderdale este Fort Lauderdale și nu New York. Dacă rândul de sus numește orașul greșit, faceți clic pe el și spuneți unde sunteți; alegeți un loc dintr-un alt fus orar și ceasul sistemului se mută și el acolo, ceea ce este util când călătoriți. Treceți cu mouse-ul peste un oraș și faceți clic pe butonul cu persoană pentru a spune cine locuiește acolo — nume simple sau identificatori GitHub cu `@` pentru a le aduce și fețele.

Fiecare panou acceptă și tastatura, nu doar mouse-ul: săgețile mută, Return activează, Tab trece la panoul vecin, iar Escape închide.

`Super + Ctrl + 1-9` numără panourile de la stânga la dreapta în secțiunea din dreapta, sărind peste tavă, deoarece nu are un panou propriu. Așa că numărul corespunde pictogramei pe care ați indica-o.

### Tailscale și Dropbox

Încă două widgeturi apar pe bară doar după ce instalați serviciul corespunzător din **Install → Service**, iar ambele merită cunoscute pentru că fac mai mult decât să raporteze starea.

Panoul **Tailscale** conectează și deconectează tailnet-ul, comută între conturi și alege un nod de ieșire (atât propriile dvs. aparate, cât și regiunile Mullvad apar în acea listă). De asemenea, răsfoiește aparatele dvs. — și cu unul selectat, `s` trimite fișiere către el prin Taildrop, care este cel mai rapid mod de a muta un fișier pe telefon sau pe alt laptop. `c` copiază IP-ul aparatului, `n` numele lui și `d` numele lui DNS complet. Există și un buton de trimitere pe fiecare rând de aparat, dacă preferați să faceți clic. Același lucru din terminal este `omarchy tailscale send <machine> [file...]`.

Panoul **Dropbox** gestionează autentificarea, arată cât spațiu de stocare ați folosit și listează fișierele sincronizate recent.

Eliminarea oricărui dintre servicii îi scoate widgetul înapoi de pe bară.

## Indicatori

Micul grup din centru este widgetul de indicatori. Acestea sunt glife de stare pentru modurile pe care le-ați activat: nu deranjați, lumină de noapte, un [memento](09-reminders.md) aflat în coadă, o înregistrare activă a ecranului, rămâi treaz și [dictarea](11-text-extraction-dictation.md). Se aprind când modul este activ și în rest nu stau în cale — treceți cu mouse-ul oriunde pe bară pentru a arunca o privire la cele inactive. Clicul pe un indicator comută acel mod. Încă unul este doar de stare: o sesiune la distanță se aprinde în roșu în timp ce cineva este conectat la acest aparat prin gliff.

Dacă preferați să fie mereu vizibile, setați `alwaysShow` la `true` pe widget. Și dacă vă pasă doar de unele dintre ele, listați-le pe cele dorite în `items`: `["Dnd", "Reminder", "NightLight"]`. Puteți avea mai mult de un widget de indicatori, așa că secțiuni diferite pot afișa subseturi diferite.

## Rearanjarea barei

Bara se configurează singură. Nu trebuie să deschideți un fișier de configurare pentru a muta lucruri.

Prindeți o porțiune goală a barei din jurul centrului și trageți-o spre o altă margine a ecranului, iar bara se mută acolo — stânga, dreapta, sus sau jos funcționează toate, iar fiecare widget se adaptează (barele verticale revin la forme compacte, doar cu pictograme). Un clic-și-menținere pornește aceeași tragere. Faceți dublu-clic stânga pe același spațiu gol pentru a parcurge ciclic fundalul barei de la transparent la sticlos la opac. Și trageți orice widget pentru a-l reordona sau a-l arunca în altă secțiune; celelalte widgeturi se depărtează pentru a face loc unde va ajunge.

Mijlocul barei este o casetă: orice se află în ea rămâne centrat ca un singur grup, iar widgeturile de o parte și de alta a ei atârnă de marginile ei. În timp ce trageți un widget, caseta apare ca un contur sau ca o linie de-a lungul barei când este goală și puteți plasa în ea sau lângă ea. Când o plasare ar ajunge în casetă, caseta crește pentru a primi widgetul.

Un widget pe care îl doriți aproape, dar nu mereu la vedere, poate merge în sertarul tăvii: trageți-l pe tavă, iar sertarul se deschide pentru a-l primi. Stă acolo după pictogramele aplicațiilor, apare ori de câte ori apare sertarul și își păstrează sertarul deschis cât timp panoul său este afișat. Trageți-l înapoi pe bară pentru a-l pune la loc.

Dacă preferați să alegeți dintr-un meniu, **Appearance → Menu Bar** are poziția, iar **Bar Background** alege cum este desenată bara: **Opaque Bar**, **Glassy Bar** (transparentă, cu ce se află în spatele ei estompat) sau **Clear Bar**.

Aceleași lucruri au comenzi, care este ceea ce doriți pentru o configurare [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Pentru a adăuga sau a elimina complet un widget, folosiți comenzile de plugin. `omarchy plugin list` afișează fiecare widget cunoscut de shell, cu id-ul său, și apoi:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ascunderea barei

`Super + Shift + Space` comută bara oprită și repornită fără a opri shell-ul — panourile și tastele rapide continuă să funcționeze, pur și simplu recuperați pixelii. Se află și în meniu, sub **Appearance → Menu Bar → Hide Bar**.

## Fișierul de configurare

Totul este stocat în `~/.config/omarchy/shell.json`, sub cheia `bar`. Iată o versiune prescurtată:

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

Fiecare widget este o intrare într-una dintre cele cinci matrice de dispunere, iar setările sale se află inline în acea intrare — nu există un fișier de setări separat și niciun sub-obiect `config`. `format`, `formatAlt` (la care trece clicul dreapta) și `verticalFormat` ale ceasului se află toate chiar acolo, pe `{ "id": "omarchy.clock" }`.

`center` este caseta din mijlocul barei: tot ce se află în ea este centrat pe ecran ca un singur grup. `centerBegin` și `centerEnd` atârnă de o parte și de alta a casetei, motiv pentru care ceasul rămâne exact în centru chiar și atunci când vremea și insigna de actualizare vin și pleacă. Puneți mai mult de un widget în `center` și sunt centrate împreună; lăsați-l gol și `centerBegin` și `centerEnd` se întâlnesc în mijlocul barei.

O regulă care merită interiorizată: **odată ce aveți propriul `shell.json`, acesta este canonic**. Până când nu personalizați nimic, shell-ul citește fișierul implicit al Omarchy. În momentul în care trageți un widget, rulați `omarchy bar` sau editați singuri fișierul, el vă aparține — nu există o îmbinare profundă, așa că widgeturile implicite noi din versiunile viitoare Omarchy nu vor apărea automat pe bara dvs. `omarchy bar defaults` repune dispunerea livrată ori de câte ori doriți să porniți de la zero.

Același fișier conține și timpii dvs. de inactivitate la nivelul superior, în afara cheii `bar`: `idle.screensaver` și `idle.lock`, ambele în secunde de când ați devenit inactiv. Așa că screensaverul implicit pornește la 150 de secunde, iar blocarea la 300.
