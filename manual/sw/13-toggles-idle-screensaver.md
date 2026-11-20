# Vigeugeu, Muda wa Kutotumika & Kihifadhi Skrini

Mengi unayobadilisha siku hadi siku si mpangilio hasa. Ni hali unayowasha kwa saa moja kisha unaizima tena: mwanga wa usiku unapofanya kazi hadi usiku sana, usinisumbue unapowasilisha, baki macho unapotazama kitu. Omarchy huziita vigeugeu, na vyote hufanya kazi kwa njia ileile — kitufe cha mkato, kipengee cha menyu, na amri, vyote vikigusa swichi ileile.

### Menyu ya vigeugeu

`Super + Ctrl + O` hufungua _Trigger > Toggle_ moja kwa moja, au unaweza kutembea huko kutoka kwenye menyu ya Omarchy (`Super + Space`). Kila kitu kilicho kwenye orodha hiyo ni swichi unayoweza kuigeuza bila kufikiria hali yake imehifadhiwa wapi. Swichi za mwonekano wa eneo-kazi ziko karibu nayo, chini ya _Appearance_.

Kutoka kwenye terminal, swichi hizo hizo ni `omarchy toggle <thing>`. Endesha `omarchy toggle` peke yake ili kuona kundi lote.

| Kigeugeu | Kitufe cha mkato | Amri |
| ------ | ------ | ------- |
| Mwanga wa usiku | — | `omarchy toggle nightlight` |
| Nyamazisha arifa | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Baki macho (hakuna kufunga kwa kutotumika) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kunasa kuanguka | — | `omarchy toggle crash-capture` |
| Kihifadhi skrini | — | `omarchy toggle screensaver` |
| Usawazishaji wa mandhari wa [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Upau wa menyu | `Super + Shift + Space` | `omarchy toggle bar` |
| Padi ya mguso | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Skrini ya mguso | — | `omarchy device touchscreen` |
| Sitisha | — | `omarchy toggle suspend` |
| GPU mseto | — | `omarchy toggle hybrid gpu` |

Swichi za padi ya mguso, skrini ya mguso, na GPU mseto ziko chini ya _Trigger > Hardware_ (`Super + Ctrl + H`) badala ya chini ya Toggle, kwani huonekana tu unapokuwa na maunzi hayo kweli. Za padi ya mguso na skrini ya mguso hudumu hata baada ya Hyprland kupakiwa upya — jina la kifaa kilichozimwa huhifadhiwa kwenye faili ndogo ya hali ambayo Hyprland huisoma wakati wa kuanza ili kukizima tena.

_Appearance_ ina upau wa menyu na uhuishaji, pamoja na vitu vichache ambavyo si amri za `omarchy toggle` lakini hufanya kazi vivyo hivyo: asilimia ya betri kwenye upau, mpangilio chaguo-msingi wa eneo la kazi, na chini ya _Windows_, nafasi kati ya madirisha (`Super + Shift + Backspace`) na uwiano wa mraba wa dirisha 1 (`Super + Ctrl + Backspace`).

Hyprland isipokuwa na GPU ya kuchorea na badala yake huchora kwa CPU (llvmpipe), kama kwenye Mac ambazo GPU yake bado haitumiki, kwenye mashine pepe nyingi, au kiendeshi cha michoro kinaposhindwa kupakia, Omarchy huzima uhuishaji, ukungu na vivuli kwa kipindi hicho na hukujulisha mara moja kwa arifa. _Appearance > Animations On_ huzirejesha, na Omarchy hukumbuka hilo kwa vipindi vijavyo pia.

Nyingi kati ya hizi ni faili tu ya alama chini ya `~/.local/state/omarchy/toggles/`. Ukitaka kuamua kulingana na mojawapo kwenye hati, `omarchy-toggle-enabled` hukupa msimbo wa kutoka badala ya kukulazimisha kwenda kuitafuta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Alama hizo zimepewa majina ya hali ya kuzimwa — `screensaver-off`, `suspend-off`, `bar-off` — kwa hivyo uwepo wake unamaanisha kipengele kimezimwa.

### Viashiria kwenye upau

Hali ikiwa imewashwa, unapata ishara ndogo katikati ya upau wa juu karibu na saa. Hiyo ndiyo wijeti ya viashiria, na hubeba uandikaji kwa sauti, kurekodi skrini, vikumbusho vinavyosubiri, mwanga wa usiku, usinisumbue, na baki macho.

Viashiria visivyotumika hufichwa. Elea mahali popote kwenye upau na huonekana taratibu vikiwa vimefifia, ili uweze kubofya kimoja ukiwashe bila kujua kitufe chake cha mkato. Kubofya kilicho hai hukizima tena. Ukitaka kuviona vyote kila wakati, weka `alwaysShow` kuwa `true` kwenye kipengee cha `omarchy.indicators` katika `~/.config/omarchy/shell.json` — angalia [upau wa juu](05-the-top-bar.md) kwa jinsi wijeti za upau zinavyosanidiwa.

### Mwanga wa usiku

Mwanga wa usiku huipa skrini joto hadi 4000K, na kuugeuza tena huirejesha hadi 6500K. Ugeuze kutoka kwenye menyu ya vigeugeu (`Super + Ctrl + O`) au kwa `omarchy toggle nightlight`. Unaendeshwa na hyprsunset, ambayo kigeugeu hukuanzishia ikiwa bado haifanyi kazi.

Kwa chaguo-msingi hyprsunset haifanyi chochote kabisa kwenye skrini yako. `~/.config/hypr/hyprsunset.conf` huja na wasifu wa utambulisho hasa ili onyesho libaki bila kuguswa hadi uombe joto. Ukitaka badala yake ibadilike kulingana na saa, badilisha hiyo na wasifu wa muda:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kisha anzisha hyprsunset wakati wa kuingia kwa kuongeza `o.launch_on_start("hyprsunset")` kwenye `~/.config/hypr/autostart.lua`. Jozi ya 4000K/6500K inayotumiwa na kigeugeu ni thabiti, kwa hivyo faili ya usanidi ndipo unapoenda ukitaka joto tofauti.

### Usinisumbue

`Super + Ctrl + Alt + ,` hunyamazisha arifa. Hakuna jumbe ibukizi zinazojitokeza ikiwa imewashwa, na kiashiria cha kengele iliyokatwa hukaa kwenye upau kukukumbusha kwa nini eneo-kazi limekuwa kimya.

Hakuna kinachopotea, hata hivyo. Arifa zilizonyamazishwa huzuiwa: zirejeshe chache za mwisho kwenye skrini kwa `Super + Shift + Alt + ,`. Angalia [taarifa](10-notices.md) kwa mengineyo.

Aina mbili za ujumbe bado hupenya: jumbe ibukizi za uthibitisho za Omarchy yenyewe kwa kitu ulichokifanya hivi punde ("Theme changed", "Screenshot saved"), na arifa muhimu zinazotumwa kutoka kwenye mstari wa amri. Programu za gumzo zinazoweka kila kitu kuwa muhimu ili kujilazimisha mbele yako hazistahili.

### Muda wa kutotumika

Ganda la Omarchy humiliki tabia ya kutotumika, na muda wake ni kitalu cha `idle` cha kiwango cha juu katika `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Namba zote mbili ni sekunde zinazohesabiwa kuanzia wakati ulipoacha kutumika — si kutoka kwa kila moja. Kwa hivyo kwa chaguo-msingi, kihifadhi skrini huja baada ya dakika mbili na nusu na skrini ya kufunga huchukua nafasi baada ya dakika tano, iwe kihifadhi skrini kilifanya kazi au la. Hifadhi faili na ganda huchukua muda mpya mara moja.

Ukiondoa kihifadhi skrini kabla ya muda wa mwisho wa kufunga, hilo huhesabika kama shughuli na kufunga kunakosubiri hubatilishwa. Hufungiwi nje kwa kuangalia mashine yako kwa haraka.

Ili kuacha kabisa kufunga wakati wa kutotumika, `Super + Ctrl + I` — au `omarchy toggle idle` — huwasha baki macho, na kiashiria cha kikombe cha kahawa huonekana kwenye upau. Hicho ndicho cha kubofya kabla ya wasilisho refu au ujenzi unaotaka kuutazama. Kibofye tena ili kurudi kawaida. `omarchy toggle idle status` huchapisha hali ya sasa kama JSON ukiihitaji kutoka kwenye hati.

Hii inahusu kufunga na kihifadhi skrini, si nishati. Usitishaji na usingizi mzito vina usanidi wake wenyewe katika [usingizi wa mfumo](36-system-sleep.md).

### Kihifadhi skrini

Kihifadhi skrini cha Omarchy ni sanaa ya ASCII inayopitia athari za maandishi nasibu, nakala moja kwa kila kioo. Kitufe chochote au mwendo wa kipanya huiondoa.

Unaweza kuianzisha unapoitaka kutoka _System > Screensaver_ (`Super + Esc`), ambayo huilazimisha kuja hata kama umezima kihifadhi skrini cha kutotumika. Hakuna kitufe cha mkato kilichofungwa kwake kwa chaguo-msingi.

`omarchy toggle screensaver` ndicho kinachozima kile cha kutotumika, ukipendelea kwenda moja kwa moja kutoka kufanya kazi hadi kufungiwa. Kitufe chochote, kubofya, kusogeza au mwendo wa kipanya huifunga.

Nembo inayochora ni yako kubadilisha, chini ya _Appearance > Branding > Screensaver_. Pakia png au svg na Omarchy huibadilisha kuwa ASCII. Angalia [utambulisho wa chapa](41-branding.md).

### Skrini ya kufunga

`Super + Ctrl + L` huifunga mashine. Hilo huendesha skrini ya kufunga kutoka kwenye ganda la Omarchy, huzima onyesho, huweka upya mpangilio wa kibodi yako kuwa wa kwanza ili usiandike nenosiri lako kwa alfabeti isiyo sahihi, na — ikiwa unaifanya ifanye kazi — hufunga 1Password wakati wa kutoka.

Skrini ya kufunga huchukua nenosiri, na itachukua alama ya kidole pia baada ya kuiweka. Hilo, na njia nyingine za kuthibitisha, zimeelezwa katika [uthibitishaji wa maunzi](37-hardware-authentication.md).
