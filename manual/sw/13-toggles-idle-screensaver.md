# Vigeuzi, Kutotenda & Kiokoa Skrini

Mengi ya unayobadilisha siku hadi siku si mpangilio hasa. Ni hali unayoiwasha kwa saa moja kisha unaizima tena: mwanga wa usiku unapofanya kazi hadi usiku wa manane, usinisumbue unapowasilisha, kaa macho unapotazama kitu. Omarchy huziita vigeuzi, na vyote hufanya kazi kwa njia ileile — kitufe cha mkato, kipengee cha menyu, na amri, vyote vikigusa swichi ileile.

### Menyu ya vigeuzi

`Super + Ctrl + O` hufungua _Trigger > Toggle_ moja kwa moja, au unaweza kufika hapo kupitia menyu ya Omarchy (`Super + Space`). Kila kitu katika orodha hiyo ni swichi unayoweza kuwasha au kuzima bila kufikiria mahali hali hiyo imehifadhiwa. Swichi za jinsi eneo-kazi linavyoonekana ziko karibu nayo, chini ya _Appearance_.

Kutoka kwenye terminali, swichi hizo hizo ni `omarchy toggle <thing>`. Endesha `omarchy toggle` peke yake ili kuona kundi lote.

| Kigeuzi | Kitufe cha Mkato | Amri |
| ------ | ------ | ------- |
| Mwanga wa usiku | — | `omarchy toggle nightlight` |
| Nyamazisha arifa | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Kaa macho (hakuna kufunga kwa kutotenda) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kunasa hitilafu | — | `omarchy toggle crash-capture` |
| Kiokoa skrini | — | `omarchy toggle screensaver` |
| Usawazishaji wa mandhari ya [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Upau wa menyu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skrini ya mguso | — | `omarchy toggle touchscreen` |
| Sitisha | — | `omarchy toggle suspend` |
| GPU mseto | — | `omarchy toggle hybrid gpu` |

Swichi za touchpad, skrini ya mguso, na GPU mseto ziko chini ya _Trigger > Hardware_ (`Super + Ctrl + H`) badala ya chini ya Toggle, kwa kuwa huonekana tu unapokuwa kweli na vifaa hivyo. Za touchpad na skrini ya mguso hubaki baada ya kupakia upya Hyprland — jina la kifaa kilichozimwa huhifadhiwa kwenye faili ndogo ya hali ambayo Hyprland huisoma wakati wa kuanza ili kukizima tena.

_Appearance_ huhifadhi upau wa menyu na uhuishaji, pamoja na vitu vichache ambavyo si amri za `omarchy toggle` lakini hufanya kazi vivyo hivyo: asilimia ya betri katika upau, mpangilio chaguo-msingi wa eneo la kazi, na chini ya _Windows_, mapengo ya madirisha (`Super + Shift + Backspace`) na uwiano wa mraba wa dirisha 1 (`Super + Ctrl + Backspace`).

Nyingi kati ya hizi ni faili tu ya bendera chini ya `~/.local/state/omarchy/toggles/`. Ikiwa unataka kuamua kulingana na mojawapo katika skripti, `omarchy-toggle-enabled` hukupa msimbo wa kutoka badala ya kukulazimisha kwenda kuitafuta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera zimepewa majina kwa ajili ya hali ya kuzimwa — `screensaver-off`, `suspend-off`, `bar-off` — kwa hiyo kuwepo kwazo kunamaanisha kipengele kimezimwa.

### Viashiria katika upau

Hali inapowashwa, unapata mchoro mdogo katikati ya upau wa juu karibu na saa. Hiyo ndiyo wijeti ya viashiria, na hubeba imla, kurekodi skrini, vikumbusho vinavyosubiri, mwanga wa usiku, usinisumbue, na kaa macho.

Viashiria visivyotumika hufichwa. Elea popote kwenye upau na huonekana vikiwa vimefifia, ili uweze kubofya kimoja ukiwashe bila kujua kitufe chake cha mkato. Kubofya kilichowashwa hukizima tena. Ikiwa ungependa kuviona vyote kila wakati, weka `alwaysShow` kuwa `true` kwenye kipengee cha `omarchy.indicators` katika `~/.config/omarchy/shell.json` — angalia [upau wa juu](05-the-top-bar.md) kwa jinsi wijeti za upau zinavyosanidiwa.

### Mwanga wa usiku

Mwanga wa usiku huipa skrini joto la 4000K, na kuuwasha tena huirudisha kwenye 6500K. Uwashe kutoka kwenye menyu ya vigeuzi (`Super + Ctrl + O`) au kwa `omarchy toggle nightlight`. Unaendeshwa na hyprsunset, ambayo kigeuzi hukuanzishia ikiwa tayari haijaendeshwa.

Kwa chaguo-msingi hyprsunset haifanyi chochote kabisa kwenye skrini yako. `~/.config/hypr/hyprsunset.conf` huja na wasifu wa utambulisho hasa ili onyesho libaki bila kuguswa hadi uombe joto. Ikiwa ungependa badala yake ibadilike kulingana na saa, badilisha hiyo na wasifu wa muda:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kisha anzisha hyprsunset unapoingia kwa kuongeza `o.launch_on_start("hyprsunset")` kwenye `~/.config/hypr/autostart.lua`. Jozi ya 4000K/6500K inayotumiwa na kigeuzi imewekwa thabiti, kwa hiyo faili ya usanidi ndipo unapoenda ikiwa unataka halijoto tofauti.

### Usinisumbue

`Super + Ctrl + Alt + ,` hunyamazisha arifa. Hakuna vidokezo vinavyojitokeza inapowashwa, na kiashiria cha kengele iliyokatwa hukaa katika upau kukukumbusha kwa nini eneo-kazi limekuwa kimya.

Hakuna kinachopotea, hata hivyo. Arifa zilizonyamazishwa hushikiliwa: rudisha chache za mwisho kwenye skrini kwa `Super + Shift + Alt + ,`. Angalia [notisi](10-notices.md) kwa mengine.

Aina mbili za ujumbe bado hupita: vidokezo vya uthibitisho vya Omarchy vyenyewe kwa kitu ulichokifanya hivi punde ("Theme changed", "Screenshot saved"), na arifa muhimu zinazotumwa kutoka kwenye mstari wa amri. Programu za gumzo zinazoweka kila kitu kuwa muhimu ili<|close|> kujilazimisha mbele yako hazistahili.

### Kutotenda

Ganda la Omarchy ndilo linalomiliki tabia ya kutotenda, na muda wake ni kizuizi cha kiwango cha juu cha `idle` katika `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Nambari zote mbili ni sekunde zinazohesabiwa kuanzia wakati ulipoacha kutenda — si kutoka kwa kila moja. Kwa hiyo kwa chaguo-msingi, kiokoa skrini huja baada ya dakika mbili na nusu na skrini ya kufunga huchukua nafasi baada ya dakika tano, iwe kiokoa skrini kiliendeshwa au la. Hifadhi faili na ganda huchukua muda mpya mara moja.

Ikiwa utaondoa kiokoa skrini kabla ya muda wa mwisho wa kufunga, hilo huhesabika kama shughuli na kufunga kunakosubiri hubatilishwa. Hulazimiki kufungiwa nje kwa kuangalia tu mashine yako.

Ili kuacha kabisa kufunga kwa kutotenda, `Super + Ctrl + I` — au `omarchy toggle idle` — huwasha kaa macho, na kiashiria cha kikombe cha kahawa huonekana katika upau. Hicho ndicho cha kubonyeza kabla ya wasilisho refu au ujenzi unaotaka kuutazama. Kibonyeze tena ili kurudi kawaida. `omarchy toggle idle status` huchapisha hali ya sasa kama JSON ikiwa unaihitaji kutoka kwenye skripti.

Hii ni kuhusu kufunga na kiokoa skrini, si nishati. Usitishaji na usingizi mzito vina usanidi wao wenyewe katika [usingizi wa mfumo](36-system-sleep.md).

### Kiokoa skrini

Kiokoa skrini cha Omarchy ni sanaa ya ASCII inayoendeshwa kupitia athari za maandishi za nasibu, nakala moja kwa kila monita. Kitufe chochote au mwendo wa kipanya huiondoa.

Unaweza kuianzisha unapotaka kutoka _System > Screensaver_ (`Super + Esc`), ambayo huilazimisha kuja hata kama umezima kiokoa skrini cha kutotenda. Hakuna kitufe cha mkato kilichofungwa kwake kwa chaguo-msingi.

`omarchy toggle screensaver` ndicho kinachozima cha kutotenda, ikiwa ungependa kwenda moja kwa moja kutoka kufanya kazi hadi kufungiwa. Kinahitaji terminali ambayo kinajua jinsi ya kusanidi — Alacritty, Foot, Ghostty, au Kitty — na kitakuambia hivyo ikiwa terminali yako chaguo-msingi ni kitu kingine.

Nembo inayochora ni yako kuibadilisha, chini ya _Appearance > Branding > Screensaver_. Pakia png au svg na Omarchy huibadilisha kuwa ASCII. Angalia [chapa](41-branding.md).

### Skrini ya kufunga

`Super + Ctrl + L` hufunga mashine. Hiyo huendesha skrini ya kufunga kutoka kwenye ganda la Omarchy, hufanya onyesho kuwa tupu, huweka upya mpangilio wa kibodi yako kwenye wa kwanza ili usiandike nenosiri lako kwa alfabeti isiyo sahihi, na — ikiwa umeiendesha — hufunga 1Password njiani kutoka.

Skrini ya kufunga huchukua nenosiri, na pia itachukua alama ya kidole mara tu unapokuwa umeiweka. Hilo, na njia nyingine za kujithibitisha, zimefafanuliwa katika [uthibitishaji wa vifaa](37-hardware-authentication.md).
