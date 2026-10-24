# Bara de sus

Fâșia de-a lungul părții de sus a ecranului este bara Omarchy. Nu este o bară de stare adăugată ulterior, ci parte a shellului Omarchy, singurul proces Quickshell cu viață lungă care desenează și meniul, notificările, pop-upurile OSD și ecranul de blocare. De aceea se tematizează perfect cu tot restul și de aceea un panou se deschide instantaneu, în loc să lanseze o aplicație nouă.

Este și singura bucată din desktop care este întotdeauna pe ecran, așa că merită să știi ce fac toate acele mici glife.

## Ce este pe ea implicit

Bara are trei secțiuni. În stânga stau logo-ul Omarchy (lansatorul meniului) și indicatorii spațiilor de lucru. În centru ai indicatorii de stare, ceasul, Elsewhen (un ceas mondial), vremea și un insignă de actualizare Omarchy. În dreapta: aranjarea tastaturii (când este configurată mai mult de una), tava de sistem, agenții, bluetooth, rețeaua, sunetul, afișajul și alimentarea.

Câteva dintre acestea apar doar când au ceva de spus. Aranjarea tastaturii apare doar dacă ai configurat mai multe aranjări. Insigna de actualizare apare doar când așteaptă o actualizare Omarchy. Iar pictograma agenților apare prima dată când Omarchy găsește utilizare de codare AI pe mașină (vezi [AI](17-ai.md)).

## Clicuri peste tot

Aproape fiecare widget face ceva la clic stânga, dreapta și mijlociu, iar câteva răspund la derulare. Aceasta este partea pe care oamenii o ratează — butoanele dreapta și mijlociu sunt locul unde se ascund multe dintre lucrurile bune.

| Widget | Stânga | Dreapta | Mijlociu / derulare |
| --- | --- | --- | --- |
| Meniu | Meniul Omarchy | Terminal nou | — |
| Spațiile de lucru | Focalizează acel spațiu de lucru | — | Derulare: spațiul următor/anterior |
| Ceas | Pop-up calendar | Parcurge formatul etichetei | Mijlociu: selector de fus orar |
| Vremea | Pop-up prognoză | Vremea completă ca notificare | Mijlociu: reîmprospătează |
| Sunet | Panou sunet | Oprește sunetul | Mijlociu: panou · derulare: volum |
| Microfon | Oprește microfonul | — | Mijlociu: panou sunet · derulare: volumul de intrare |
| Rețea | Panou rețea | — | — |
| Bluetooth | Panou Bluetooth | Comută radioul | — |
| Afișaj | Panou afișaj | — | Derulare: luminozitate |
| Alimentare | Panou alimentare | Comută procentul bateriei | — |
| Media | Redă/pune pauză | Pop-up cu coperta | Mijlociu: următorul · derulare: anteriorul/următorul |
| Agenți | Panou agenți | Lansează agentul tău | Mijlociu: următorul abonament |
| Tavă | Trece cu indicatorul ca să afișezi sertarul | Dreapta pe chevron ca să gestionezi | — |
| Actualizare Omarchy | Rulează actualizarea | — | — |

Nu tot ce e în acel tabel este pe bara ta imediat. Widgetul media (redarea curentă MPRIS, cu piesa și artistul care derulează) și widgetul microfon sunt ambele integrate, dar dezactivate implicit — adaugă-le dacă le vrei, așa cum se descrie mai jos.

## Panourile

Clicul pe o pictogramă din bară deschide un panou, care este un pop-up veritabil, cu glisoare, liste și navigare de la tastatură, nu un sfat. Fiecare are și o scurtătură, așa că nu trebuie niciodată să țintești o glifă de 16 pixeli:

| Scurtătură | Panou |
| --- | --- |
| `Super + Ctrl + A` | Sunet |
| `Super + Ctrl + W` | Rețea |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Afișaj |
| `Super + Ctrl + P` | Alimentare |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | Ceas mondial |
| `Super + Ctrl + 1-9` | Comută al n-lea panou din secțiunea din dreapta |

Panourile nu sunt simple afișaje. Aici faci cu adevărat lucrul:

- **Sunetul** are un glisor de volum principal, un selector de dispozitiv de ieșire și un mixer per aplicație, astfel încât să poți da mai încet acea filă de browser fără să atingi tot restul.
- **Rețeaua** scanează după Wi-Fi, arată puterea semnalului, se conectează și îți permite să alegi un furnizor DNS.
- **Bluetooth** enumeră dispozitivele tale cu conectare/deconectare și niveluri de baterie.
- **Alimentarea** arată statistici ale bateriei, schimbă profilurile de energie (ține minte o alegere separată pentru baterie și pentru curent alternativ) și tipărește câteva informații de sistem.
- **Afișajul** poartă un glisor de luminozitate, dimensiunea textului, presetări de scalare a monitorului și — când ai mai multe ecrane — comenzi per monitor. Vezi [monitoarele](33-monitors.md) pentru povestea mai aprofundată.
- **Ceasul** deschide o grilă lunară cu numere de săptămână ISO și pășire între luni.

Fiecare panou acceptă tastatura, precum și mouse-ul: săgețile se mișcă, Return activează, Tab pășește la panoul vecin și Escape închide.

`Super + Ctrl + 1-9` numără panourile de la stânga la dreapta în secțiunea din dreapta, sărind peste tavă, deoarece nu are un panou propriu. Așa că numărul se potrivește cu pictograma spre care ai arăta.

### Tailscale și Dropbox

Alte două widgeturi apar pe bară doar după ce instalezi serviciul corespunzător din **Instalează → Service**, și ambele merită cunoscute, pentru că fac mai mult decât să raporteze starea.

Panoul **Tailscale** conectează și deconectează tailnetul, comută între conturi și alege un nod de ieșire (în acea listă apar atât mașinile tale, cât și regiunile Mullvad). De asemenea, răsfoiește mașinile tale — și, cu una selectată, `s` îi trimite fișiere prin Taildrop, care este cel mai rapid mod de a muta un fișier pe telefon sau pe alt laptop. `c` copiază IP-ul mașinii, `n` numele ei și `d` numele ei DNS complet. Există și un buton de trimitere pe fiecare rând de mașină, dacă preferi clicul. Același lucru din terminal este `omarchy tailscale send <machine> [file...]`.

Panoul **Dropbox** se ocupă de autentificare, arată cât spațiu de stocare ai folosit și enumeră fișierele sincronizate recent.

Eliminarea oricăruia dintre servicii îi ia widgetul înapoi de pe bară.

## Indicatorii

Micul grup din centru este widgetul de indicatori. Acestea sunt glife de stare pentru modurile pe care le-ai activat: nu deranja, lumina de noapte, un [memento](09-reminders.md) în așteptare, o înregistrare de ecran activă, rămâi treaz și [dictarea](11-text-extraction-dictation.md). Se aprind când modul este activ și în rest stau deoparte — treci cu indicatorul în stânga ceasului (deasupra lui pe o bară verticală) ca să tragi cu ochiul la cele inactive. Clicul pe un indicator comută acel mod. Încă unul este doar de stare: o sesiune la distanță se aprinde în roșu cât timp cineva este conectat la această mașină prin gliff.

Dacă preferi să fie întotdeauna vizibile, setează `alwaysShow` la `true` pe widget. Și dacă îți pasă doar de unele dintre ele, enumeră-le pe cele pe care le vrei în `items`: `["Dnd", "Reminder", "NightLight"]`. Poți avea mai multe widgeturi de indicatori, astfel încât secțiuni diferite să poată arăta subseturi diferite.

## Rearanjarea barei

Bara se configurează singură. Nu trebuie să deschizi un fișier de configurare ca să muți lucruri.

Prinde o zonă goală din bară din jurul centrului și trage-o spre altă margine a ecranului, iar bara se mută acolo — stânga, dreapta, sus sau jos funcționează toate, iar fiecare widget se adaptează (barele verticale revin la forme compacte, doar cu pictograme). Un clic menținut începe aceeași tragere. Fă dublu clic stânga pe același spațiu gol ca să parcurgi fundalul barei de la transparent la sticlos la opac. Și trage orice widget ca să-l rearanjezi sau să-l arunci în altă secțiune.

Un widget pe care îl vrei la îndemână, dar nu mereu la vedere, poate merge în sertarul tăvii: trage-l pe tavă și sertarul se deschide ca să-l primească. Stă acolo după pictogramele aplicațiilor, apare de fiecare dată când apare și sertarul și își ține sertarul deschis cât timp panoul său este deschis. Trage-l înapoi pe bară ca să-l pui la loc.

Dacă preferi să alegi dintr-un meniu, **Declanșator → Aspect → Bară de meniu** are poziția, iar **Fundal bară** alege cum este desenată bara: **Bară opacă**, **Bară sticloasă** (transparentă, cu ce e în spate estompat) sau **Bară transparentă**.

Aceleași lucruri au comenzi, ceea ce vrei pentru o configurare de [fișiere dot](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Ca să adaugi sau să elimini complet un widget, folosește comenzile de plugin. `omarchy plugin list` tipărește fiecare widget pe care îl cunoaște shellul, cu id-ul lui, și apoi:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ascunderea barei

`Super + Shift + Space` comută bara între oprit și pornit, fără să omoare shellul — panourile și scurtăturile continuă să funcționeze, doar că îți recuperezi pixelii. Se află și în meniu, sub **Declanșator → Aspect → Bară de meniu → Ascunde bara**.

## Fișierul de configurare

Totul este stocat în `~/.config/omarchy/shell.json`, sub cheia `bar`. Iată o versiune trunchiată:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Fiecare widget este o intrare în una dintre cele trei matrice de aranjare, iar setările ei stau inline pe acea intrare — nu există un fișier de setări separat și niciun sub-obiect `config`. `format` al ceasului, `formatAlt` (ceea ce se parcurge la clic dreapta) și `verticalFormat` trăiesc toate chiar acolo, pe `{ "id": "omarchy.clock" }`.

`centerAnchor` numește singurul widget central care este fixat exact în centrul ecranului, cu celelalte flancându-l. Așa rămâne ceasul exact în centru chiar și atunci când vremea și insigna de actualizare vin și pleacă. Setează-l la un șir gol și lista centrală este centrată doar ca grup.

O regulă care merită interiorizată: **odată ce ai propriul tău `shell.json`, el este canonic**. Până când personalizezi ceva, shellul citește fișierul implicit al Omarchy. În momentul în care tragi un widget, rulezi `omarchy bar` sau editezi fișierul singur, el îți aparține — nu există nicio îmbinare profundă, așa că noile widgeturi implicite din versiunile viitoare Omarchy nu vor apărea automat pe bara ta. `omarchy bar defaults` pune aranjarea livrată înapoi oricând vrei un început curat.

Același fișier ține și timpii tăi de inactivitate la nivelul superior, în afara cheii `bar`: `idle.screensaver` și `idle.lock`, ambele în secunde de când ai devenit inactiv. Astfel, economizorul de ecran implicit pornește la 150 de secunde, iar blocarea la 300.
