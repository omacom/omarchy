# Algengar spurningar

### Hvernig skipti ég á milli lyklaborðskipana?

Breyttu `~/.config/hypr/input.lua` skránni þinni og bættu þessu við til að skipta á milli skipana með `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Stikan mun sjálfkrafa sýna núverandi lyklaborðskipan þína þegar þú hefur stillt margar skipanir (og þú getur smellt á hana til að skipta líka).

### Hvernig breyti ég klukkunni í 12 stunda snið?

Hægrismelltu á klukkuna á stikunni til að sigla í gegnum algengu sniðin, þar á meðal 12 stunda sniðin. Þú getur líka stillt sniðið beint:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Þetta mun sýna Sunday 10:55 AM.

### Hvernig breyti ég tímabelti mínu?

Keyrðu _Uppfæra > Tímabelti_ í Omarchy-valmyndinni og veldu af listanum. Ef tímabeltið er rétt en klukkan sjálf hefur rekið endurræsir _Uppfæra > Tími_ tímasamstillinguna fyrir þig.

### Hvernig breyti ég DNS mínu, deili Wi-Fi netinu mínu eða athuga tengingarhraðann minn?

Það býr allt í [neti](35-networking.md).

### Hvernig athuga ég hversu hraður diskurinn minn er?

_Kveikja > Hraðapróf > Diskahraðapróf_ mælir lifandi lestrar- og skrifhraða á drifinu þínu, eða `omarchy disk speedtest` úr terminal.

### Af hverju get ég ekki skráð mig inn á Google reikninginn minn í Chromium?

Einfalda opna Chromium byggingin flytur ekki með sér OAuth skilríkin sem Google krefst fyrir reikningsinnskráningu. Keyrðu _Setja upp > Þjónusta > Chromium-reikningur_ í Omarchy-valmyndinni til að bæta þeim við, endurræstu vafrann og innskráningin mun ganga í gegn.

### Hvernig bæti ég við prentara?

Prentun er uppsett og í gangi strax úr kassanum og þú bætir hverjum prentara við sjálfur úr _Print Settings_ í forritaræsinum (`Super + Space`).

Veldu _Add_ og gefðu því augnablik til að leita: prentari sem er tengdur með USB, og flestir netprentarar, finnast fyrir þig. Ef þinn er ekki í listanum skaltu velja _Network Printer > Internet Printing Protocol (ipp)_ og slá inn vistfang hans — eiginn skjár prentarans eða vefsíða hans mun segja þér hvað það er, venjulega eitthvað á borð við `192.168.1.50` með biðröðina `ipp/print`. _Forward_ býður þá upp á rekil, þar sem nútímaprentari virkar best á rekilalausa _IPP Everywhere_ sniðinu og eldri vill rekil gerðarinnar sjálfrar.

Hægrismelltu á prentara og veldu _Set as Default_ til að velja hvaða prentara forritin þín leita til fyrst, og _Properties_ til að stilla pappírsstærð, tvíhliða prentun og gæði.

Sjálfvirk uppgötvun, þar sem prentarar á netinu birtast án þess að vera bætt við, er tímabundið slökkt á meðan hún er endurunnin, og þess vegna er fyrsta skrefið hér að ofan þitt frekar en sjálfvirkt. Prentun í PDF-skrá virkar alls án prentara.

### Hvernig breyti ég því hvar skjámyndir eða skjáupptökur eru vistaðar?

Vistaðar skjámyndir fara sjálfgefið í `~/Pictures/Screenshots`. Til að nota aðra möppu skaltu bæta þessu við skrá undir `~/.config/uwsm/env.d/` (eins og `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Þú getur gert það sama fyrir skjáupptökur með `OMARCHY_SCREENRECORD_DIR`.

Omasnap býr til skjámyndamöppu sína sjálfkrafa. Búðu til skjáupptökumöppuna sjálfur og endurræstu svo Omarchy til að hvor umhverfisbreytingin sem er taki gildi.

### Hvernig fæ ég hátalarana + vefmyndavélina til að virka á Apple Studio Display mínum?

Þú myndir halda að allt ætti bara að virka með því að stinga USB C í samband, en því miður er það ekki svo. Lausnin sem ég hef fundið til að láta þetta virka áreiðanlega er að nota [WJESOG DisplayPort + USB-A => USB-C snúruna](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Þá virka hátalarar og vefmyndavél eins og í sögu.

Mundu að þú hefur innbyggða birtustýringu í Omarchy fyrir Apple skjáina (bæði Studio og XDR) með venjulegu birtu takkunum á lyklaborðinu.

### Hvernig losna ég við allan auka hugbúnaðinn?

Ef þú vilt ekki forrit eins og Obsidian eða LibreOffice eða neitt af öðru foruppsetta dóti geturðu fjarlægt það mjög auðveldlega.

Keyrðu _Fjarlægja > Pakki_ til að sjá sérhvern pakka sem er uppsettur. Þá geturðu valið sérhvern pakka sem þú vilt fjarlægja með tab og byrjað að fjarlægja allt sem þú hefur valið með return.

Og þú getur notað _Fjarlægja > Vefforrit_ í Omarchy-valmyndinni til að fjarlægja sérhvert af foruppsettum vefforritunum sem þú vilt ekki.

Eða keyrðu _Fjarlægja > Foruppsett_ til að sópa út öllum foruppsettum aukahlutunum — vefforritum, TUI-um og valkvæðum forritum — í einum vetvangi. Flýtilyklarnir sem ræstu þau hverfa með þeim, svo þú situr eftir með hreint borð af bindingum til að fylla með þínum eigin í `~/.config/hypr/bindings.lua`.

---

Fyrir villur og bilaða hluti, sjá [úrræðaleitarhlutann](45-troubleshooting.md).
