# Bara de sus

Fâșia de-a lungul părții de sus a ecranului tău este bara Omarchy. Nu este o bară de stare prinsă cu șuruburi, ci parte din shell-ul Omarchy, singurul proces Quickshell care rulează continuu și care desenează și meniul, notificările, ferestrele pop-up OSD și ecranul de blocare. De aceea se potrivește tematic perfect cu tot restul și de aceea un panou se deschide instantaneu, în loc să pornească o aplicație nouă.

Este și singura piesă a desktopului care este mereu pe ecran, așa că merită să știi ce fac toate acele mici glife.

## Ce este pe ea în mod implicit

Bara are trei secțiuni. În stânga se află logo-ul Omarchy (lansatorul meniului) și indicatorii spațiilor de lucru. În centru ai indicatorii de stare, ceasul, Elsewhen (un ceas mondial), vremea și o insignă de actualizare Omarchy. În dreapta: tava de sistem, aranjamentul tastaturii (când este configurat mai mult de unul), agenții, bluetooth, rețeaua, sunetul, ecranul și alimentarea.

Câteva dintre ele apar doar când au ceva de spus. Aranjamentul tastaturii apare doar dacă ai configurat mai mult de un aranjament. Insigna de actualizare apare doar când așteaptă o actualizare Omarchy. Iar pictograma agenților apare prima dată când Omarchy găsește utilizare de programare cu AI pe mașină (vezi [AI](17-ai.md)).

## Clicurile

Aproape fiecare widget face ceva la clic stânga, dreapta și mijloc, iar mai multe răspund la derulare. Asta este partea pe care oamenii o ratează — butoanele din dreapta și din mijloc sunt cele unde se ascunde mare parte din lucrurile bune.

| Widget | Stânga | Dreapta | Mijloc / derulare |
| --- | --- | --- | --- |
| Meniu | Meniul Omarchy | Terminal nou | — |
| Spații de lucru | Focalizează acel spațiu de lucru pe acest monitor | — | Derulare: spațiul de lucru următor/anterior |
| Ceas | Fereastră pop-up cu calendar | Schimbă ciclic formatul etichetei | Mijloc: selector de fus orar |
| Vreme | Fereastră pop-up cu prognoza | Vremea completă ca notificare | Mijloc: reîmprospătare |
| Audio | Panoul audio | Dezactivează sunetul | Mijloc: panou · derulare: volum |
| Microfon | Dezactivează microfonul | — | Mijloc: panoul audio · derulare: volumul de intrare |
| Rețea | Panoul de rețea | — | — |
| Bluetooth | Panoul Bluetooth | Comută radioul | — |
| Ecran | Panoul de ecran | — | Derulare: luminozitate |
| Alimentare | Panoul de alimentare | Comută procentul bateriei | — |
| Media | Redare/pauză | Fereastră pop-up cu coperta | Mijloc: următorul · derulare: anterior/următor |
| Agenți | Panoul de agenți | Lansează agentul tău | Mijloc: abonamentul următor |
| Tavă | Menține cursorul deasupra pentru a dezvălui sertarul | Clic dreapta pe chevron pentru a gestiona | — |
| Actualizare Omarchy | Rulează actualizarea | — | — |

Nu tot ce este în acel tabel se află pe bara ta din start. Widgetul media (MPRIS now-playing, cu o piesă și un artist care derulează) și widgetul de microfon sunt ambele integrate, dar dezactivate în mod implicit — adaugă-le dacă le vrei, așa cum este descris mai jos.

## Panourile

Un clic pe o pictogramă din bară deschide un panou, care este o fereastră pop-up adevărată, cu glisoare, liste și navigare de la tastatură, nu un tooltip. Fiecare are și o tastă rapidă, așa că nu trebuie niciodată să țintești o glifă de 16 pixeli:

| Tastă rapidă | Panou |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Rețea |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ecran |
| `Super + Ctrl + P` | Alimentare |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | Ceas mondial |
| `Super + Ctrl + 1-9` | Comută al n-lea panou din secțiunea din dreapta |

Panourile nu sunt simple afișaje. Din ele chiar faci lucrul respectiv:

- **Audio** are un glisor principal de volum, un selector de dispozitiv de ieșire și un mixer per aplicație, așa că poți da mai încet acea filă de browser fără să atingi tot restul.
- **Rețea** scanează rețele Wi-Fi, arată puterea semnalului, se conectează și te lasă să alegi un furnizor DNS.
- **Bluetooth** listează dispozitivele tale cu conectare/deconectare și niveluri de baterie.
- **Alimentare** arată statistici despre baterie, comută profilurile de alimentare (ține minte o alegere separată pentru baterie și AC) și afișează câteva informații despre sistem.
- **Ecran** are un glisor de luminozitate, dimensiunea textului, presetări de scalare a monitorului și — când ai mai mult de un ecran — controale per monitor. Vezi [monitoare](33-monitors.md) pentru povestea mai detaliată.
- **Ceas** deschide o grilă lunară cu numere de săptămâni ISO și trecere de la o lună la alta.
- **Ceas mondial** ține câte un rând pentru fiecare oraș, cu vremea lui și cum îi merge ziua. Căutarea găsește orașe mici, precum și fusuri orare, așa că Fort Lauderdale este Fort Lauderdale și nu New York. Dacă rândul de sus numește orașul greșit, dă clic pe el și spune unde ești; alege un loc de pe alt fus orar și ceasul sistemului se mută și el acolo, ceea ce este util când călătorești. Treci cu mouse-ul peste un oraș și dă clic pe butonul cu persoană ca să spui cine locuiește acolo — nume simple sau identificatori GitHub cu `@` ca să le aduci și fețele.

Fiecare panou acceptă și tastatura, nu doar mouse-ul: săgețile mută, Return activează, Tab trece la panoul vecin, iar Escape închide.

`Super + Ctrl + 1-9` numără panourile de la stânga la dreapta în secțiunea din dreapta, sărind peste tavă, deoarece aceasta nu are un panou propriu. Așa că numărul corespunde pictogramei pe care ai arăta-o.

### Tailscale și Dropbox

Încă două widgeturi apar pe bară doar după ce instalezi serviciul potrivit din **Instalare → Serviciu**, și ambele merită cunoscute pentru că fac mai mult decât să raporteze starea.

Panoul **Tailscale** conectează și deconectează tailnet-ul, comută între conturi și alege un nod de ieșire (atât mașinile tale, cât și regiunile Mullvad apar în acea listă). Îți răsfoiește și mașinile — iar cu una selectată, `s` îi trimite fișiere prin Taildrop, ceea ce este cel mai rapid mod de a muta un fișier pe telefonul tău sau pe alt laptop. `c` copiază IP-ul mașinii, `n` numele ei, iar `d` numele ei DNS complet. Există și un buton de trimitere pe fiecare rând de mașină, dacă preferi să dai clic. Același lucru din terminal este `omarchy tailscale send <machine> [file...]`.

Panoul **Dropbox** se ocupă de autentificare, arată cât spațiu de stocare ai folosit și listează fișierele sincronizate recent.

Eliminarea oricăruia dintre servicii îi scoate din nou widgetul de pe bară.

## Indicatori

Micul grup din centru este widgetul de indicatori. Acestea sunt glife de stare pentru modurile pe care le-ai activat: nu deranja, lumină de noapte, un [memento](09-reminders.md) în așteptare, o înregistrare activă a ecranului, rămâi treaz și [dictare](11-text-extraction-dictation.md). Se aprind când modul este activ și în rest nu stau în cale — treci cu mouse-ul chiar lângă ele, acolo unde ar sta cele inactive, ca să arunci o privire la acelea. Un clic pe un indicator comută acel mod. Încă unul este doar de stare: o sesiune la distanță se aprinde roșu cât timp cineva este conectat la această mașină prin gliff.

Dacă preferi să fie mereu vizibile, setează `alwaysShow` la `true` pe widget. Și dacă te interesează doar unele dintre ele, listează-le pe cele dorite în `items`: `["Dnd", "Reminder", "NightLight"]`. Poți avea mai mult de un widget de indicatori, așa că secțiuni diferite pot arăta subseturi diferite.

## Rearanjarea barei

Bara se configurează singură. Nu trebuie să deschizi un fișier de configurare ca să muți lucruri.

Prinde o porțiune goală a barei din jurul centrului și trage-o spre altă margine a ecranului, iar bara se mută acolo — stânga, dreapta, sus sau jos funcționează toate, iar fiecare widget se adaptează (barele verticale revin la forme compacte, doar cu pictograme). Un clic lung pornește aceeași tragere. Dă dublu clic stânga pe același spațiu gol pentru a schimba ciclic fundalul barei de la transparent la sticlos la opac. Și trage orice widget pentru a-l reordona sau pentru a-l arunca în altă secțiune; celelalte widgeturi se dau la o parte ca să facă loc acolo unde va ajunge.

Mijlocul barei este o casetă: tot ce este în ea rămâne centrat ca un singur grup, iar widgeturile de o parte și de alta a ei atârnă de marginile ei. Când tragi un widget, caseta apare ca un contur sau, când este goală, ca o linie de-a lungul barei, și poți să plasezi în ea sau lângă ea. Când o plasare ar ajunge în casetă, caseta crește ca să primească widgetul.

Un widget pe care îl vrei la îndemână, dar nu mereu la vedere, poate merge în sertarul tăvii: trage-l peste tavă, iar sertarul se deschide ca să-l primească. Stă acolo după pictogramele aplicațiilor, apare ori de câte ori apare sertarul și își ține sertarul deschis cât timp panoul lui este sus. Trage-l înapoi pe bară ca să-l pui la loc.

Dacă preferi să alegi dintr-un meniu, **Aspect → Bara de meniu** are poziția, iar **Fundalul barei** alege modul în care este desenată bara: **Bară opacă**, **Bară sticloasă** (transparentă, cu ceea ce este în spatele ei estompat) sau **Bară transparentă**.

Aceleași lucruri au comenzi, ceea ce îți trebuie pentru o configurare [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Pentru a adăuga sau elimina complet un widget, folosește comenzile de plugin. `omarchy plugin list` afișează fiecare widget cunoscut de shell, cu id-ul lui, iar apoi:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ascunderea barei

`Super + Shift + Space` ascunde bara și o readuce fără să oprească shell-ul — panourile și tastele rapide continuă să funcționeze, doar că îți recuperezi pixelii. Se află și în meniu, la **Aspect → Bara de meniu → Ascunde bara**.

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

Fiecare widget este o singură intrare într-unul dintre cele cinci tablouri de aranjament, iar setările lui stau inline pe acea intrare — nu există un fișier separat de setări și niciun sub-obiect `config`. `format`, `formatAlt` (la care trece clicul dreapta, ciclic) și `verticalFormat` ale ceasului trăiesc toate chiar acolo, pe `{ "id": "omarchy.clock" }`.

`center` este caseta din mijlocul barei: tot ce este în ea este centrat pe ecran ca un singur grup. `centerBegin` și `centerEnd` atârnă de o parte și de alta a casetei, motiv pentru care ceasul rămâne exact în centru chiar și atunci când vremea și insigna de actualizare vin și pleacă. Pune mai mult de un widget în `center` și ele sunt centrate împreună; las-o goală și `centerBegin` și `centerEnd` se întâlnesc în mijlocul barei.

O regulă care merită interiorizată: **odată ce ai propriul tău `shell.json`, el este canonic**. Până când personalizezi ceva, shell-ul citește fișierul implicit al Omarchy. În clipa în care tragi un widget, rulezi `omarchy bar` sau editezi singur fișierul, el îți aparține — nu există o îmbinare profundă, așa că widgeturile implicite noi din versiunile viitoare Omarchy nu vor apărea automat pe bara ta. `omarchy bar defaults` readuce aranjamentul livrat ori de câte ori vrei o tablă curată.

Același fișier ține și timpii tăi de inactivitate la nivelul superior, în afara cheii `bar`: `idle.screensaver` și `idle.lock`, ambele în secunde de când ai devenit inactiv. Așa că screensaverul implicit pornește la 150 de secunde, iar blocarea la 300.
