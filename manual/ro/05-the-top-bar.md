# Bara superioară

Fâșia de de-a lungul părții de sus a ecranului este bara Omarchy. Nu este o bară de stare atașată ulterior, ci parte din shell-ul Omarchy, singurul proces Quickshell de lungă durată care desenează și meniul, notificările, ferestrele pop-up OSD și ecranul de blocare. De aceea se potrivește perfect ca temă cu tot restul și de aceea un panou se deschide instantaneu, în loc să pornească o aplicație nouă.

Este și singura piesă a desktopului care este mereu pe ecran, așa că merită să știi ce fac toate acele mici glife.

## Ce este pe ea în mod implicit

Bara are trei secțiuni. În stânga se află sigla Omarchy (lansatorul de meniu) și indicatoarele spațiilor de lucru. În centru ai indicatoarele de stare, ceasul, Elsewhen (un ceas mondial), vremea și o insignă de actualizare Omarchy. În dreapta: tava de sistem, dispunerea tastaturii (când este configurată mai mult de o dispunere sau o metodă de introducere), agenții, bluetooth, rețeaua, sunetul, afișajul și alimentarea.

Unele dintre acestea apar numai când au ceva de spus. Dispunerea tastaturii apare numai dacă ai configurat mai mult de o dispunere sau o metodă de introducere. Insigna de actualizare apare numai când te așteaptă o actualizare Omarchy.

## Ce fac clicurile

Aproape fiecare widget face ceva la clic stânga, dreapta și mijloc, iar mai multe răspund la derulare. Aceasta este partea pe care oamenii o ratează — butoanele din dreapta și din mijloc sunt cele unde se ascunde o mare parte din lucrurile bune.

| Widget | Stânga | Dreapta | Mijloc / derulare |
| --- | --- | --- | --- |
| Meniu | Meniul Omarchy | Terminal nou | — |
| Spații de lucru | Focalizează spațiul de lucru respectiv pe acest monitor | — | Derulare: spațiul de lucru următor/anterior |
| Ceas | Fereastră pop-up cu calendarul | Schimbă ciclic formatul etichetei | Mijloc: selector de fus orar |
| Ceas mondial | Panoul ceasului mondial | Reîmprospătează | Mijloc: reîmprospătare |
| Vreme | Fereastră pop-up cu prognoza | Vremea completă ca notificare | Mijloc: reîmprospătare |
| Audio | Panoul audio | Dezactivează sunetul | Mijloc: panou · derulare: volum |
| Microfon | Dezactivează microfonul | — | Mijloc: panoul audio · derulare: volumul de intrare |
| Rețea | Panoul de rețea | — | — |
| Bluetooth | Panoul Bluetooth | Pornește/oprește radioul | — |
| Afișaj | Panoul de afișaj | — | Derulare: luminozitate |
| Alimentare | Panoul de alimentare | Afișează/ascunde procentul bateriei | — |
| Media | Redare/pauză | Fereastră pop-up cu coperta | Mijloc: următorul · derulare: anterior/următor |
| Agenți | Panoul agenților | Lansează agentul tău | Mijloc: reîmprospătează utilizarea |
| Tavă | Ține cursorul deasupra pentru a dezvălui sertarul | Clic dreapta pe chevron pentru administrare | — |
| Actualizare Omarchy | Rulează actualizarea | — | — |

Nu tot ce este în tabelul acela se află pe bara ta din prima. Widgetul media (MPRIS now-playing, cu piesa și artistul derulând) și widgetul de microfon sunt ambele integrate, dar dezactivate în mod implicit — adaugă-le dacă le vrei, după cum este descris mai jos.

## Panourile

Un clic pe o pictogramă din bară deschide un panou, care este o fereastră pop-up adevărată, cu glisoare, liste și navigare de la tastatură, mai degrabă decât un tooltip. Fiecare are și o tastă rapidă, așa că nu trebuie niciodată să țintești o glifă de 16 pixeli:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Panourile nu sunt simple afișaje. Sunt locul unde chiar faci lucrul respectiv:

- **Audio** are un glisor pentru volumul principal, un selector al dispozitivului de ieșire și un mixer per aplicație, așa că poți da mai încet acea singură filă de browser fără să atingi tot restul.
- **Network** scanează după Wi-Fi, arată puterea semnalului, se conectează și te lasă să alegi un furnizor DNS.
- **Bluetooth** îți listează dispozitivele, cu conectare/deconectare și nivelurile bateriei.
- **Power** arată statisticile bateriei, schimbă profilurile de alimentare (ține minte o alegere separată pentru baterie și pentru AC) și afișează câteva informații despre sistem.
- **Display** are un glisor de luminozitate, dimensiunea textului, presetări de scalare a monitorului și — când ai mai mult de un ecran — controale per monitor. Vezi [monitoare](33-monitors.md) pentru povestea mai detaliată.
- **Clock** deschide o grilă a lunii, cu numerele săptămânilor ISO și navigare între luni.
- **World clock** păstrează câte un rând per oraș, cu vremea lui și cu cum îi merge ziua. Căutarea găsește orășele la fel ca fuse orare, așa că Fort Lauderdale este Fort Lauderdale și nu New York. Dacă rândul de sus numește orașul greșit, dă clic pe el și spune unde ești; alege un loc de pe alt fus orar și ceasul sistemului se mută și el acolo, ceea ce este la îndemână când călătorești. Ține cursorul deasupra unui oraș și dă clic pe butonul cu persoană ca să spui cine locuiește acolo — nume simple sau identificatori GitHub cu `@` ca să le aduci și fețele.

Fiecare panou acceptă tastatura la fel de bine ca mouse-ul: săgețile mută, Return activează, Tab trece la panoul vecin, iar Escape închide.

`Super + Ctrl + 1-9` numără panourile de la stânga la dreapta în secțiunea din dreapta, sărind peste tavă, deoarece aceasta nu are un panou propriu. Așa că numărul corespunde pictogramei spre care ai arăta.

### Tailscale și Dropbox

Încă două widgeturi apar pe bară numai după ce instalezi serviciul potrivit din **Install → Service** și ambele merită știute, pentru că fac mai mult decât să raporteze starea.

Panoul **Tailscale** conectează și deconectează tailnet-ul, comută între conturi și alege un exit node (atât mașinile tale, cât și regiunile Mullvad apar în lista aceea). Îți răsfoiește și mașinile — iar cu una selectată, `s` trimite fișiere către ea prin Taildrop, ceea ce este cel mai rapid mod de a muta un fișier pe telefonul tău sau pe alt laptop. `c` copiază IP-ul mașinii, `n` numele ei, iar `d` numele ei DNS complet. Există și un buton de trimitere pe fiecare rând de mașină, dacă preferi să dai clic. Același lucru din terminal este `omarchy tailscale send <machine> [file...]`.

Panoul **Dropbox** se ocupă de autentificare, arată cât spațiu de stocare ai folosit și listează fișierele sincronizate recent.

Eliminarea oricăruia dintre servicii îi scoate widgetul înapoi de pe bară.

## Indicatoare

Micul grup din centru este widgetul de indicatoare. Acestea sunt glife de stare pentru modurile pe care le-ai pornit: nu deranja, lumină de noapte, un [reminder](09-reminders.md) aflat în coadă, o înregistrare de ecran activă și rămâi treaz, plus avertismente cât timp sudo fără parolă este pornit sau cineva este conectat la o sesiune la distanță. Se aprind când modul este activ și, în rest, stau deoparte — ține cursorul chiar lângă ele, acolo unde ar sta cele inactive, ca să arunci o privire la acelea. Un clic pe un indicator pornește sau oprește modul respectiv. Încă unul este doar de stare: o sesiune la distanță se aprinde în roșu cât timp cineva este conectat la mașina aceasta prin gliff.

Dacă preferi să fie mereu vizibile, setează `alwaysShow` la `true` pe widget. Iar dacă te interesează doar unele dintre ele, listează-le pe cele dorite în `items`: `["Dnd", "Reminder", "NightLight"]`. Poți avea mai mult de un widget de indicatoare, așa că secțiuni diferite pot arăta subseturi diferite.

## Rearanjarea barei

Bara se configurează singură. Nu trebuie să deschizi un fișier de configurare ca să muți lucrurile.

Apucă o porțiune goală a barei din jurul centrului și trage-o spre altă margine a ecranului, iar bara se mută acolo — stânga, dreapta, sus sau jos funcționează toate, iar fiecare widget se adaptează (barele verticale revin la forme compacte, doar cu pictograme). Un clic menținut pornește aceeași tragere. Fă dublu-clic stânga pe același spațiu gol ca să schimbi ciclic fundalul barei de la transparent la sticlos la opac. Și trage orice widget ca să-l reordonezi sau să-l arunci în altă secțiune; celelalte widgeturi se despart glisând ca să facă loc acolo unde va ateriza.

Mijlocul barei este o casetă: tot ce este în ea rămâne centrat ca un singur grup, iar widgeturile de o parte și de alta a ei atârnă de marginile ei. Cât timp tragi un widget, caseta se arată ca un contur sau ca o linie de-a curmezișul barei când este goală, și poți lăsa widgetul în ea sau lângă ea. Când o lăsare ar ateriza în casetă, caseta crește ca să primească widgetul.

Un widget pe care îl vrei prin preajmă, dar nu mereu la vedere, poate merge în sertarul tăvii: trage-l peste tavă, iar sertarul se deschide ca să-l primească. Stă acolo după pictogramele aplicațiilor, apare ori de câte ori apare sertarul și își ține sertarul deschis cât timp panoul lui este sus. Trage-l înapoi pe bară ca să-l pui la loc.

Dacă preferi să alegi dintr-un meniu, **Appearance → Menu Bar** are poziția, iar **Bar Background** alege cum este desenată bara: **Opaque Bar**, **Glassy Bar** (transparentă, cu ceea ce este în spatele ei estompat) sau **Clear Bar**.

Aceleași lucruri au comenzi, ceea ce este ceea ce vrei pentru o configurare cu [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Ca să adaugi sau să elimini un widget cu totul, folosește comenzile de plugin. `omarchy plugin list` afișează fiecare widget pe care shell-ul îl cunoaște, împreună cu id-ul lui, iar apoi:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ascunderea barei

`Super + Shift + Space` oprește bara și o pornește la loc fără să omoare shell-ul — panourile și tastele rapide continuă să funcționeze, doar că îți recuperezi pixelii. Se află și în meniu, la **Appearance → Menu Bar → Hide Bar**.

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

Fiecare widget este o singură intrare într-una dintre cele cinci matrice de dispunere, iar setările lui stau inline pe intrarea aceea — nu există un fișier de setări separat și niciun sub-obiect `config`. `format`, `formatAlt` (la care trece clicul dreapta, ciclic) și `verticalFormat` ale ceasului trăiesc toate chiar acolo, pe `{ "id": "omarchy.clock" }`.

`center` este caseta din mijlocul barei: tot ce este în ea este centrat pe ecran ca un singur grup. `centerBegin` și `centerEnd` atârnă de o parte și de alta a casetei, motiv pentru care ceasul rămâne exact în centru chiar și atunci când vremea și insigna de actualizare vin și pleacă. Pune mai mult de un widget în `center` și vor fi centrați împreună; lasă-l gol și `centerBegin` și `centerEnd` se întâlnesc în mijlocul barei.

O regulă care merită interiorizată: **odată ce ai propriul tău `shell.json`, acesta este canonic**. Până când nu personalizezi nimic, shell-ul citește fișierul implicit al Omarchy. În clipa în care tragi un widget, rulezi `omarchy bar` sau editezi singur fișierul, el îți aparține — nu există nicio îmbinare profundă, așa că widgeturile implicite noi din versiunile viitoare Omarchy nu vor apărea automat pe bara ta. `omarchy bar defaults` pune dispunerea livrată la loc ori de câte ori vrei să pornești de la zero.

Același fișier ține și timpii tăi de inactivitate la nivelul superior, în afara cheii `bar`: `idle.screensaver` și `idle.lock`, ambele în secunde de când ai devenit inactiv. Așa că screensaver-ul implicit pornește la 150 de secunde, iar blocarea la 300.
