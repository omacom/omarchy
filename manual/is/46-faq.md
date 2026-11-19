# Algengar spurningar

### Hvernig skipti ég á milli lyklaborðsuppsetninga?

Breyttu `~/.config/hypr/input.lua` skránni þinni og bættu þessu við til að skipta á milli uppsetninga með `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Stikan sýnir núverandi lyklaborðsuppsetningu þína sjálfkrafa þegar þú hefur stillt fleiri en eina uppsetningu (og þú getur líka smellt á hana til að skipta).

### Hvernig breyti ég klukkunni í 12 stunda snið?

Hægrismelltu á klukkuna í stikunni til að fletta í gegnum algengu sniðin, þar á meðal 12 stunda sniðin. Þú getur líka stillt sniðið beint:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Þetta birtir sunnudag 10:55 AM.

### Hvernig breyti ég tímabeltinu mínu?

Keyrðu _Uppsetning > Svæði > Tímabelti_ í Omarchy-valmyndinni og veldu af listanum. Ef tímabeltið er rétt en klukkan sjálf hefur rekið, endurræsir _Uppfærsla > Tími_ samstillingu tímans fyrir þig.

### Hvernig breyti ég DNS-inu mínu, deili Wi-Fi-inu mínu eða athuga hraðann á tengingunni minni?

Það er allt í [netkerfinu](35-networking.md).

### Hvernig athuga ég hversu hraður diskurinn minn er?

_Kveikja > Hraðapróf > Hraðapróf disks_ mælir les- og skrifhraða drifsins í beinni, eða `omarchy disk speedtest` í útstöðinni.

### Hvernig bæti ég við prentara?

Prentun er uppsett og keyrir beint úr kassanum og þú bætir hverjum prentara við sjálfur úr _Prentstillingum_ í forritaræsinum (`Super + Space`).

Veldu _Bæta við_ og gefðu því smá stund til að leita: prentari sem er tengdur með USB og flestir netprentarar finnast fyrir þig. Ef þinn er ekki á listanum skaltu velja _Netprentari > Internet Printing Protocol (ipp)_ og slá inn vistfang hans — skjár prentarans sjálfs eða vefsíða hans segir þér hvað það er, yfirleitt eitthvað eins og `192.168.1.50` með biðröðina `ipp/print`. _Áfram_ býður þá upp á rekil, þar sem nútímaprentari virkar best með reklalausa _IPP Everywhere_ sniðinu og eldri prentari vill rekil viðkomandi gerðar.

Hægrismelltu á prentara og veldu _Setja sem sjálfgefinn_ til að velja þann sem forritin þín grípa fyrst til, og _Eiginleikar_ til að stilla pappírsstærð, tvíhliða prentun og gæði.

Sjálfvirk leit, þar sem prentarar á netinu birtast án þess að þeim sé bætt við, er tímabundið slökkt á meðan verið er að endurgera hana og þess vegna er fyrsta skrefið hér að ofan þitt en ekki sjálfvirkt. Að prenta í PDF-skrá virkar án nokkurs prentara.

### Hvernig breyti ég því hvar skjáskot eða skjáupptökur eru vistaðar?

Vistuð skjáskot fara sjálfgefið í `~/Pictures/Screenshots`. Til að nota aðra möppu skaltu bæta þessu við skrá undir `~/.config/uwsm/env.d/` (eins og `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Þú getur gert það sama fyrir skjáupptökur með `OMARCHY_SCREENRECORD_DIR`.

Omasnap býr skjáskotamöppuna til sjálfkrafa. Búðu skjáupptökumöppuna til sjálfur og endurræstu síðan Omarchy til að önnur hvor umhverfisbreytan taki gildi.

### Hvernig fæ ég hátalara + vefmyndavél til að virka á Apple Studio Display skjánum mínum?

Maður myndi halda að allt ætti bara að virka með því að stinga USB C í samband, en því miður er það ekki raunin. Lausnin sem ég hef fundið til að fá þetta til að virka áreiðanlega er að nota [WJESOG DisplayPort + USB-A => USB-C snúruna](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Þá virka hátalarar og vefmyndavél eins og í sögu.

Mundu að þú ert með innbyggða birtustýringu í Omarchy fyrir Apple-skjáina (bæði Studio og XDR) með venjulegu birtuhnöppunum á lyklaborðinu.

### Hvernig losna ég við allan auka hugbúnaðinn?

Ef þú vilt ekki forrit eins og Obsidian eða LibreOffice eða eitthvað annað af fyrirfram uppsetta dótinu geturðu fjarlægt það mjög auðveldlega.

Keyrðu _Fjarlægja > Pakki_ til að sjá hvern pakka sem er uppsettur. Síðan geturðu valið hvaða pakka sem þú vilt fjarlægja með tab og byrjað að fjarlægja allt sem þú hefur valið með return.

Og þú getur notað _Fjarlægja > Vefforrit_ úr Omarchy-valmyndinni til að fjarlægja öll fyrirfram uppsettu vefforritin sem þú vilt ekki.

Eða keyrðu _Fjarlægja > Fyrirfram uppsett_ til að sópa út öllum fyrirfram uppsettum aukaforritum — vefforritum, TUI-forritum og valfrjálsum forritum — í einu lagi. Flýtilyklarnir sem ræstu þau hverfa með þeim, þannig að þú situr uppi með hreint borð af bindingum til að fylla með þínum eigin í `~/.config/hypr/bindings.lua`.

---

Fyrir villur og bilaða hluti, sjá [kaflann um bilanaleit](45-troubleshooting.md).
