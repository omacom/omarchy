# Vigeuza, Kutotumika na Kihifadhi Skrini

Mengi ya unayobadilisha kila siku si mpangilio kweli. Ni hali unayowasha kwa saa moja kisha unaizima tena: mwanga wa usiku unapofanya kazi hadi usiku sana, usinisumbue unapowasilisha, baki macho unapotazama kitu. Omarchy huziita hizo vigeuza, na zote hufanya kazi kwa njia moja — kitufe cha mkato, kipengee cha menyu, na amri, vyote vikigusa swichi moja.

### Menyu ya kigeuza

`Super + Ctrl + O` hufungua _Trigger > Toggle_ moja kwa moja, au unaweza kufika huko kupitia menyu ya Omarchy (`Super + Space`). Kila kitu kwenye orodha hiyo ni swichi unayoweza kuwasha au kuzima bila kufikiria hali yake imehifadhiwa wapi. Swichi za jinsi eneo-kazi linavyoonekana ziko karibu nayo, chini ya _Appearance_.

Kutoka kwenye terminali, swichi hizo hizo ni `omarchy toggle <thing>`. Endesha `omarchy toggle` peke yake kuona kundi lote.

| Kigeuza | Kitufe cha Mkato | Amri |
| ------ | ------ | ------- |
| Mwanga wa usiku | — | `omarchy toggle nightlight` |
| Nyamazisha arifa | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Baki macho (hakuna kufunga kwa kutotumika) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kunasa kuanguka | — | `omarchy toggle crash-capture` |
| Kihifadhi skrini | — | `omarchy toggle screensaver` |
| Usawazishaji wa mandhari wa [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Upau wa menyu | `Super + Shift + Space` | `omarchy toggle bar` |
| Padi ya mguso | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skrini ya mguso | — | `omarchy toggle touchscreen` |
| Kusimamisha | — | `omarchy toggle suspend` |
| GPU mseto | — | `omarchy toggle hybrid gpu` |

Swichi za padi ya mguso, skrini ya mguso, na GPU mseto huishi chini ya _Trigger > Hardware_ (`Super + Ctrl + H`) badala ya chini ya Toggle, kwani huonekana tu unapokuwa na kifaa hicho kweli. Swichi za padi ya mguso na skrini ya mguso hubaki baada ya Hyprland kupakiwa upya — jina la kifaa kilichozimwa huhifadhiwa kwenye faili ndogo ya hali ambayo Hyprland huisoma wakati wa kuanza ili kukizima tena.

_Appearance_ hushikilia upau wa menyu na uhuishaji, pamoja na vitu vichache ambavyo si amri za `omarchy toggle` lakini hufanya kazi vivyo hivyo: asilimia ya betri kwenye upau, mpangilio chaguomsingi wa eneo la kazi, na chini ya _Windows_, mapengo ya madirisha (`Super + Shift + Backspace`) na uwiano wa mraba wa dirisha 1 (`Super + Ctrl + Backspace`).

Hyprland inapokosa GPU ya kuchora nayo na badala yake huchora kwa CPU (llvmpipe), kama kwenye Mac ambazo GPU yake bado haijaungwa mkono, kwenye mashine pepe nyingi, au kiendeshi cha michoro kinaposhindwa kupakia, Omarchy huzima uhuishaji, ukungu na vivuli kwa kipindi hicho na hukujulisha mara moja kwa arifa. _Appearance > Animations On_ huvirudisha, na Omarchy hukumbuka hilo kwa vipindi vijavyo pia.

Nyingi za hizi ni faili tu ya bendera chini ya `~/.local/state/omarchy/toggles/`. Ukitaka kuamua kulingana na mojawapo kwenye hati, `omarchy-toggle-enabled` hukupa msimbo wa kutoka badala ya kukulazimisha kwenda kuitafuta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera hizo zimepewa majina ya hali ya kuzimwa — `screensaver-off`, `suspend-off`, `bar-off` — kwa hivyo kuwepo kwake kunamaanisha kipengele kimezimwa.

### Viashiria kwenye upau

Hali inapowashwa, unapata glifu ndogo katikati ya upau wa juu karibu na saa. Hiyo ndiyo wijeti ya viashiria, na hubeba uandikaji kwa sauti, kurekodi skrini, vikumbusho vinavyosubiri, mwanga wa usiku, usinisumbue, na baki macho.

Viashiria visivyotumika hufichwa. Elekeza kipanya popote kwenye upau na vitaonekana vikiwa vimefifia, ili uweze kubofya kimoja kukiwasha bila kujua kitufe chake cha mkato. Kubofya kilicho hai hukizima tena. Ikiwa ungependa kuviwaona vyote kila wakati, weka `alwaysShow` kuwa `true` kwenye kipengee cha `omarchy.indicators` katika `~/.config/omarchy/shell.json` — tazama [upau wa juu](05-the-top-bar.md) kwa jinsi wijeti za upau zinavyosanidiwa.

### Mwanga wa usiku

Mwanga wa usiku huipa skrini joto la 4000K, na kuuwasha tena huirudisha kwenye 6500K. Uwashe kutoka kwenye menyu ya kigeuza (`Super + Ctrl + O`) au kwa `omarchy toggle nightlight`. Unaendeshwa na hyprsunset, ambayo kigeuza huianzisha kwa ajili yako ikiwa bado haiaendeshwi.

Kwa chaguomsingi hyprsunset haifanyi chochote kwenye skrini yako kabisa. `~/.config/hypr/hyprsunset.conf` huja na wasifu wa utambulisho hasa ili onyesho libaki bila kuguswa hadi uombe joto. Ikiwa ungependa ibadilike kulingana na saa, badilisha hiyo na wasifu wa wakati:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kisha anzisha hyprsunset wakati wa kuingia kwa kuongeza `o.launch_on_start("hyprsunset")` kwenye `~/.config/hypr/autostart.lua`. Jozi ya 4000K/6500K inayotumiwa na kigeuza ni isiyobadilika, kwa hivyo faili ya usanidi ndipo pa kwenda ukitaka halijoto tofauti.

### Usinisumbue

`Super + Ctrl + Alt + ,` hunyamazisha arifa. Hakuna arifa ibukizi zinazoonekana inapowashwa, na kiashiria cha kengele iliyokatwa hukaa kwenye upau kukukumbusha kwa nini eneo-kazi limekuwa kimya.

Hata hivyo, hakuna kinachopotea. Arifa zilizonyamazishwa huhifadhiwa nyuma: rudisha chache za mwisho kwenye skrini kwa `Super + Shift + Alt + ,`. Tazama [arifa](10-notices.md) kwa mengineyo.

Aina mbili za ujumbe bado hupita: arifa ibukizi za uthibitisho za Omarchy zenyewe kwa jambo ulilofanya hivi punde ("Theme changed", "Screenshot saved"), na arifa muhimu sana zinazotumwa kutoka kwenye mstari wa amri. Programu za gumzo zinazoweka kila kitu kama muhimu sana ili kujilazimisha mbele yako hazistahili.

### Kutotumika

Ganda la Omarchy ndilo humiliki tabia ya kutotumika, na muda wake ni kizuizi cha kiwango cha juu cha `idle` katika `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Nambari zote mbili ni sekunde zinazohesabiwa kuanzia wakati ulipoacha kutumika — si kutoka kwa kila moja. Kwa hivyo kwa chaguomsingi, kihifadhi skrini huja baada ya dakika mbili na nusu na skrini ya kufunga huchukua nafasi baada ya dakika tano, iwe kihifadhi skrini kiliendeshwa au la. Hifadhi faili na ganda huchukua muda mpya mara moja.

Ukiondoa kihifadhi skrini kabla ya muda wa mwisho wa kufunga, hilo huhesabika kama shughuli na kufunga kunakosubiri hubatilishwa. Hufungiwi nje kwa kuangalia mashine yako kwa haraka.

Kuacha kufunga kwa kutotumika kabisa, `Super + Ctrl + I` — au `omarchy toggle idle` — huwasha baki macho, na kiashiria cha kikombe cha kahawa huonekana kwenye upau. Hicho ndicho cha kubofya kabla ya wasilisho refu au ujenzi unaotaka kutazama. Kibofye tena kurudi kwa kawaida. `omarchy toggle idle status` huchapisha hali ya sasa kama JSON ukiwa unaihitaji kutoka kwenye hati.

Hii inahusu kufunga na kihifadhi skrini, si nishati. Kusimamisha na kulaza kwa kina vina usanidi wake katika [usingizi wa mfumo](36-system-sleep.md).

### Kihifadhi skrini

Kihifadhi skrini cha Omarchy ni sanaa ya ASCII inayopitia madoido ya maandishi nasibu, nakala moja kwa kila kioo. Kitufe chochote au mwendo wa kipanya huiondoa.

Unaweza kukianzisha unapokitaka kutoka _System > Screensaver_ (`Super + Esc`), ambayo hukilazimisha kuonekana hata kama umezima kihifadhi skrini cha kutotumika. Hakuna kitufe cha mkato kilichofungwa kwake kwa chaguomsingi.

`omarchy toggle screensaver` ndiyo huzima ile ya kutotumika, ikiwa ungependa kwenda moja kwa moja kutoka kufanya kazi hadi kufungwa. Kitufe chochote, kubofya, kusogeza au mwendo wa kipanya huifunga.

Nembo inayochora ni yako kubadilisha, chini ya _Appearance > Branding > Screensaver_. Pakia png au svg na Omarchy huibadilisha kuwa ASCII. Tazama [chapa](41-branding.md).

### Skrini ya kufunga

`Super + Ctrl + L` hufunga mashine. Hiyo huendesha skrini ya kufunga kutoka kwenye ganda la Omarchy, huzima onyesho, huweka upya mpangilio wa kibodi yako kuwa wa kwanza ili usiandike nenosiri lako kwa alfabeti isiyo sahihi, na — ikiwa unaiendesha — hufunga 1Password wakati wa kutoka.

Skrini ya kufunga huchukua nenosiri, na pia itachukua alama ya kidole baada ya kuisanidi. Hilo, na njia nyingine za kuthibitisha, zimefafanuliwa katika [uthibitishaji wa vifaa](37-hardware-authentication.md).
