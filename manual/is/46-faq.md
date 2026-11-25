# Algengar spurningar

### Hvernig skipti ég á milli lyklaborðsuppsetninga?

Breyttu skránni `~/.config/hypr/input.lua` og bættu þessu við til að skipta á milli uppsetninga með `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Stikan mun sjálfkrafa sýna núverandi lyklaborðsuppsetningu þína þegar þú hefur stillt margar uppsetningar (og þú getur líka smellt á hana til að skipta).

### Hvernig breyti ég klukkusniðinu í 12 stunda snið?

Hægrismelltu á klukkuna á stikunni til að fletta í gegnum algengu sniðin, þar á meðal 12 stunda sniðin. Þú getur líka stillt sniðið beint:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Þetta mun birta sunnudagur 10:55 AM.

### Hvernig breyti ég tímabeltinu mínu?

Keyrðu _Uppsetning > Svæði > Tímabelti_ í Omarchy-valmyndinni og veldu af listanum. Ef tímabeltið er rétt en klukkan sjálf hefur rekið, endurræsir _Uppfærsla > Tími_ tímasamstillinguna fyrir þig.

### Hvernig breyti ég DNS-inu mínu, deili Wi-Fi-inu mínu eða athuga hraða tengingarinnar minnar?

Það er allt að finna í [netkerfi](35-networking.md).

### Hvernig athuga ég hversu hraður diskurinn minn er?

_Ræsa > Hraðapróf > Diskhraðapróf_ mælir lifandi les- og skrifhraða á drifinu þínu, eða `omarchy disk speedtest` úr skipanalínunni.

### Hvernig bæti ég við prentara?

Prentun er sett upp og virkar beint úr kassanum, og þú bætir hverjum prentara við sjálfur úr _Prentstillingar_ í forritaræsinum (`Super + Alt + Space`).

Veldu _Bæta við_ og gefðu því augnablik til að leita: prentari sem er tengdur með USB, og flestir netprentarar, finnast fyrir þig. Ef þinn er ekki á listanum skaltu velja _Netprentari > Internet Printing Protocol (ipp)_ og slá inn vistfang hans — skjár prentarans sjálfs eða vefsíða hans mun segja þér hvað það er, venjulega eitthvað á borð við `192.168.1.50` með biðröðina `ipp/print`. _Áfram_ býður þá upp á rekil, þar sem nútímalegur prentari virkar best á rekilausu _IPP Everywhere_ sniði og eldri prentari vill rekil gerðarinnar sjálfrar.

Hægrismelltu á prentara og veldu _Setja sem sjálfgefinn_ til að velja hvaða prentara forritin þín leita fyrst til, og _Eiginleikar_ til að stilla pappírsstærð, tvíhliða prentun og gæði.

Sjálfvirk uppgötvun, þar sem prentarar á netinu birtast án þess að þeim sé bætt við, er tímabundið slökkt á meðan verið er að endurbæta hana, og þess vegna er fyrsta skrefið hér að ofan í þínum höndum frekar en sjálfvirkt. Prentun í PDF-skrá virkar án nokkurs prentara.

### Hvernig breyti ég því hvar skjámyndir eða skjáupptökur eru vistaðar?

Vistaðar skjámyndir fara sjálfgefið í `~/Pictures/Screenshots`. Til að nota aðra möppu skaltu bæta þessu við skrá undir `~/.config/uwsm/env.d/` (eins og `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Þú getur gert það sama fyrir skjáupptökur með `OMARCHY_SCREENRECORD_DIR`.

Omasnap býr sjálfkrafa til möppu skjámyndanna sinna. Búðu til möppuna fyrir skjáupptökur sjálfur og endurræstu svo Omarchy til að önnur hvor umhverfisbreytingin taki gildi.

### Hvernig fæ ég hátalarana + vefmyndavélina til að virka á Apple Studio Display mínum?

Maður myndi halda að allt ætti bara að virka með því að stinga USB C í samband, en því miður er það ekki raunin. Lausnin sem ég hef fundið til að láta þetta virka áreiðanlega er að nota [WJESOG DisplayPort + USB-A => USB-C snúruna](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Þá virka hátalarar og vefmyndavél eins og í sögu.

Mundu að þú hefur innbyggða birtustýringu í Omarchy fyrir Apple-skjáina (bæði Studio og XDR) með venjulegu birtuhnöppunum á lyklaborðinu.

### Hvernig losna ég við allan auka hugbúnaðinn?

Ef þú vilt ekki forrit á borð við Obsidian eða LibreOffice eða neitt annað af fyrirfram uppsetta dótinu geturðu mjög auðveldlega fjarlægt það.

Keyrðu _Fjarlægja > Pakki_ til að sjá hvern pakka sem er uppsettur. Þá geturðu valið hvaða pakka sem þú vilt fjarlægja með tab og byrjað að fjarlægja allt sem þú hefur valið með return.

Og þú getur notað _Fjarlægja > Vefforrit_ úr Omarchy-valmyndinni til að fjarlægja öll fyrirfram uppsettu vefforritin sem þú vilt ekki.

Eða keyrðu _Fjarlægja > Fyrirfram uppsett_ til að sópa út öllum fyrirfram uppsettum aukahlutum — vefforritum, TUI-forritum og valfrjálsum forritum — í einu lagi. Flýtilyklarnir sem ræstu þau hverfa með þeim, svo þú situr uppi með hreint borð af bindingum til að fylla með þínum eigin í `~/.config/hypr/bindings.lua`.

---

Fyrir villur og bilaða hluti, sjá [kaflann um bilanaleit](45-troubleshooting.md).
