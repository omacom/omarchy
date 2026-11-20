# Vigeuzi, Kutotumika na Kihifadhiskrini

Mengi ya unayobadilisha siku hadi siku si mpangilio hasa. Ni hali unayoiwasha kwa saa moja na kuizima tena: mwangaza wa usiku unapofanya kazi hadi usiku sana, usisumbue unapowasilisha, kaa macho unapotazama kitu. Omarchy huziita vigeuzi, na vyote hufanya kazi kwa njia ile ile — mkato wa kibodi, ingizo la menyu, na amri, vyote vikigusa swichi ile ile.

### Menyu ya kugeuza

`Super + Ctrl + O` hufungua _Kichocheo > Geuza_ moja kwa moja, au unaweza kutembea huko kutoka kwenye menyu ya Omarchy (`Super + Space`). Kila kitu kwenye orodha hiyo ni swichi unayoweza kuigeuza bila kufikiria mahali ambapo hali imehifadhiwa. Swichi za jinsi eneo-kazi linavyoonekana ziko karibu nayo, chini ya _Muonekano_.

Kutoka kwenye terminali, swichi hizo hizo ni `omarchy toggle <thing>`. Endesha `omarchy toggle` peke yake ili kuona kundi lote.

| Kigeuzi | Mkato wa Kibodi | Amri |
| ------ | ------ | ------- |
| Mwangaza wa usiku | — | `omarchy toggle nightlight` |
| Nyamazisha arifa | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Kaa macho (hakuna kufunga kwa kutotumika) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Rekodi ya kuanguka | — | `omarchy toggle crash-capture` |
| Kihifadhiskrini | — | `omarchy toggle screensaver` |
| Ulinganishaji wa mandhari ya [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Upau wa menyu | `Super + Shift + Space` | `omarchy toggle bar` |
| Eneo-kazi la skrini nzima (hakuna upau, hakuna mapengo) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animasheni, ukungu na vivuli | — | `omarchy toggle animations` |
| Kiguso | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Skrini ya mguso | — | `omarchy device touchscreen` |
| Sitisha | — | `omarchy toggle suspend` |
| GPU mseto | — | `omarchy device gpu hybrid` |

Swichi za kiguso, skrini ya mguso, na GPU mseto ziko chini ya _Kichocheo > Maunzi_ (`Super + Ctrl + H`) badala ya chini ya Geuza, kwa kuwa huonekana tu unapokuwa kweli na maunzi hayo. Za kiguso na skrini ya mguso hubaki baada ya kupakia upya kwa Hyprland — jina la kifaa kilichozimwa huhifadhiwa kwenye faili ndogo ya hali ambayo Hyprland husoma wakati wa kuanza ili kukizima tena.

_Muonekano_ hushikilia upau wa menyu na animasheni, pamoja na vitu vichache ambavyo si amri za `omarchy toggle` lakini hufanya kazi vivyo hivyo: asilimia ya betri kwenye upau, mpangilio chaguo-msingi wa eneo la kazi, na chini ya _Madirisha_, mapengo ya madirisha (`Super + Shift + Backspace`) na uwiano wa mraba wa dirisha 1 (`Super + Ctrl + Backspace`).

Wakati Hyprland haina GPU ya kuchora nayo na badala yake huchora kwenye CPU (llvmpipe), kama kwenye Mac ambazo GPU yake haijaungwa mkono bado, kwenye mashine pepe nyingi, au wakati kiendeshi cha michoro kinaposhindwa kupakia, Omarchy huzima animasheni, ukungu na vivuli kwa kipindi hicho na kukuambia mara moja kwa arifa. _Muonekano > Animasheni Imewashwa_ huzirudisha, na Omarchy hukumbuka hilo kwa vipindi vijavyo pia.

Nyingi za hizi ni faili tu ya bendera chini ya `~/.local/state/omarchy/toggles/`. Kama unataka kuamua kulingana na mojawapo kwenye hati, `omarchy-toggle-enabled` hukupa msimbo wa kutoka badala ya kukulazimisha kwenda kuitafuta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera zimepewa majina ya hali ya kuzimwa — `screensaver-off`, `suspend-off`, `bar-off` — kwa hiyo kuwepo kwake kunamaanisha kipengele kimezimwa.

### Viashirio kwenye upau

Wakati hali imewashwa, unapata glifi ndogo katikati ya upau wa juu karibu na saa. Hiyo ndiyo wijeti ya viashirio, na hubeba kurekodi skrini, vikumbusho vinavyosubiri, mwangaza wa usiku, usisumbue, na kukaa macho, pamoja na maonyo wakati sudo isiyo na nenosiri imewashwa au mtu ameunganishwa kwenye kipindi cha mbali.

Viashirio visivyotumika vimefichwa. Elea popote kwenye upau na hujitokeza vikiwa vimefifia, ili uweze kubofya kimoja ukiwasha bila kujua mkato wake wa kibodi. Kubofya kilichowashwa hukizima tena. Kama ungependa kuona vyote kila wakati, weka `alwaysShow` kuwa `true` kwenye ingizo la `omarchy.indicators` katika `~/.config/omarchy/shell.json` — angalia [upau wa juu](05-the-top-bar.md) kwa jinsi wijeti za upau zinavyosanidiwa.

### Mwangaza wa usiku

Mwangaza wa usiku huipa skrini joto hadi 4000K, na kuugeuza tena huirudisha hadi 6500K. Uigeuze kutoka kwenye menyu ya kugeuza (`Super + Ctrl + O`) au kwa `omarchy toggle nightlight`. Huendeshwa na hyprsunset, ambayo kigeuzi hukuanzishia kama haijaanza bado.

Kwa chaguo-msingi hyprsunset haifanyi chochote kwenye skrini yako kabisa. `~/.config/hypr/hyprsunset.conf` huja na wasifu wa utambulisho hasa ili onyesho libaki bila kuguswa hadi uombe joto. Kama ungependa ibadilike kulingana na saa, badilisha hilo na wasifu wa muda:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kisha anzisha hyprsunset wakati wa kuingia kwa kuongeza `o.launch_on_start("hyprsunset")` kwenye `~/.config/hypr/autostart.lua`. Jozi ya 4000K/6500K inayotumiwa na kigeuzi imewekwa thabiti, kwa hiyo faili ya usanidi ndipo unapokwenda kama unataka halijoto tofauti.

### Usisumbue

`Super + Ctrl + Alt + ,` hunyamazisha arifa. Hakuna arifa ibukizi zinazojitokeza ikiwa imewashwa, na kiashirio cha kengele iliyokatwa hukaa kwenye upau kukukumbusha kwa nini eneo-kazi limekuwa kimya.

Hakuna kinachopotea, hata hivyo. Arifa zilizonyamazishwa hushikiliwa: rudisha chache za mwisho kwenye skrini kwa `Super + Shift + Alt + ,`. Angalia [taarifa](10-notices.md) kwa yaliyosalia.

Aina tatu za ujumbe bado hupita: arifa ibukizi za uthibitisho za Omarchy zenyewe kwa kitu ulichokifanya hivi punde ("Theme changed", "Screenshot saved"), arifa muhimu zilizotumwa kutoka kwenye mstari wa amri, na misimbo ya uthibitisho. Programu za mazungumzo zinazoweka kila kitu kama muhimu ili kulazimisha kuja mbele yako hazistahili.

### Kutotumika

Ganda la Omarchy ndilo linalomiliki tabia ya kutotumika, na muda wake ni kizuizi cha kiwango cha juu cha `idle` katika `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Nambari zote mbili ni sekunde zinazohesabiwa kutoka wakati ulipoanza kutotumika — si kutoka kwa kila moja. Kwa hiyo kwa chaguo-msingi, kihifadhiskrini huja baada ya dakika mbili na nusu na skrini ya kufunga huchukua nafasi baada ya dakika tano, iwe kihifadhiskrini kiliendeshwa au la. Hifadhi faili na ganda huchukua muda mpya mara moja.

Ukiiondoa kihifadhiskrini kabla ya tarehe ya mwisho ya kufunga, hilo huhesabiwa kama shughuli na kufunga kunakosubiri hubatilishwa. Hufungiwi nje kwa kuangalia tu mashine yako.

Ili kuacha kufunga kwa kutotumika kabisa, `Super + Ctrl + I` — au `omarchy toggle idle` — hugeuza kukaa macho kuwaka, na kiashirio cha kikombe cha kahawa huonekana kwenye upau. Hiyo ndiyo ya kubofya kabla ya wasilisho refu au ujenzi unaotaka kuutazama. Ibofye tena kurudi kawaida. `omarchy toggle idle status` huchapisha hali ya sasa kama JSON kama unaihitaji kutoka kwenye hati.

Hii inahusu kufunga na kihifadhiskrini, si nishati. Usitishaji na usingizi mzito vina usanidi wake wenyewe katika [usingizi wa mfumo](36-system-sleep.md).

### Kihifadhiskrini

Kihifadhiskrini cha Omarchy ni sanaa ya ASCII inayopitia athari za maandishi nasibu, nakala moja kwa kila kioo. Kitufe chochote au usogezaji wa kipanya huiondoa.

Unaweza kuianzisha unapotaka kutoka _Mfumo > Kihifadhiskrini_ (`Super + Esc`), ambayo huilazimisha kujitokeza hata kama umezima kihifadhiskrini cha kutotumika. Hakuna mkato wa kibodi uliofungwa kwake kwa chaguo-msingi.

`omarchy toggle screensaver` ndicho kinachozima ile ya kutotumika, kama ungependa kwenda moja kwa moja kutoka kufanya kazi hadi kufungiwa. Kitufe chochote, kubofya, kusogeza au usogezaji wa kipanya huifunga.

Nembo inayochora ni yako kubadilisha, chini ya _Muonekano > Chapa > Kihifadhiskrini_. Pakia png au svg na Omarchy huibadilisha kuwa ASCII. Angalia [chapa](41-branding.md).

### Skrini ya kufunga

`Super + Ctrl + L` huifunga mashine. Hiyo huendesha skrini ya kufunga kutoka kwenye ganda la Omarchy, huifanya onyesho kuwa tupu, huweka upya mpangilio wako wa kibodi kuwa wa kwanza ili usiandike nenosiri lako kwa alfabeti isiyo sahihi, na — kama umeiendesha — huifunga 1Password wakati wa kutoka.

Skrini ya kufunga huchukua nenosiri, na itachukua alama ya kidole pia mara tu unapokuwa umeiweka. Hilo, na njia zingine za kujithibitisha, zimefafanuliwa katika [uthibitishaji wa maunzi](37-hardware-authentication.md).
