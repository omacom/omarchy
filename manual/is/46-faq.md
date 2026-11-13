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

Stikan sýnir núverandi lyklaborðsuppsetningu þína sjálfkrafa þegar þú ert með fleiri en eina uppsetningu stillta (og þú getur líka smellt á hana til að skipta).

### Hvernig breyti ég klukkuforminu í 12 stunda form?

Hægri-smelltu á klukkuna í stikunni til að fletta í gegnum algengu formin, þar á meðal 12 stunda formin. Þú getur líka stillt formið beint:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Þetta birtir sunnudag 10:55 AM.

### Hvernig breyti ég tímabeltinu mínu?

Keyrðu _Uppfæra > Tímabelti_ í Omarchy valmyndinni og veldu af listanum. Ef tímabeltið er rétt en klukkan sjálf hefur rekið endurræsir _Uppfæra > Tími_ tímasamstillinguna fyrir þig.

### Hvernig breyti ég DNS-inu mínu, deili Wi-Fi-inu mínu eða athuga hraða tengingarinnar minnar?

Það er allt að finna í [netkerfi](35-networking.md).

### Hvernig athuga ég hve hraður diskurinn minn er?

_Kveikja > Hraðapróf > Hraðapróf fyrir disk_ mælir lifandi les- og skrifhraða á drifinu þínu, eða `omarchy disk speedtest` úr útstöðinni.

### Hvernig bæti ég við prentara?

Prentun er sett upp og keyrir beint úr kassanum, og þú bætir hverjum prentara við sjálf/ur úr _Prentstillingum_ í forritaræsinum (`Super + Space`).

Veldu _Bæta við_ og gefðu því augnablik til að leita: prentari tengdur með USB, og flestir netprentarar, finnast fyrir þig. Ef þinn er ekki á listanum skaltu velja _Netprentari > Internet Printing Protocol (ipp)_ og slá inn vistfang hans — eigin skjár prentarans eða vefsíða hans segir þér hvað það er, venjulega eitthvað á borð við `192.168.1.50` með biðröðina `ipp/print`. _Áfram_ býður þá upp á rekil, þar sem nútímaprentari virkar best á reklalausa _IPP Everywhere_ sniðinu og eldri prentari vill rekil eigin gerðar.

Hægri-smelltu á prentara og veldu _Setja sem sjálfgefinn_ til að velja hvaða prentara forritin þín leita fyrst til, og _Eiginleikar_ til að stilla pappírsstærð, tvíhliða prentun og gæði.

Sjálfvirk leit, þar sem prentarar á netinu birtast án þess að þeim sé bætt við, er tímabundið slökkt á meðan hún er endurgerð, og þess vegna er fyrsta skrefið hér að ofan þitt frekar en sjálfvirkt. Að prenta í PDF-skrá virkar án nokkurs prentara.

### Hvernig breyti ég því hvar skjámyndir eða skjáupptökur eru vistaðar?

Vistaðar skjámyndir fara sjálfgefið í `~/Pictures/Screenshots`. Til að nota aðra möppu skaltu bæta þessu við skrá undir `~/.config/uwsm/env.d/` (eins og `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Þú getur gert það sama fyrir skjáupptökur með því að nota `OMARCHY_SCREENRECORD_DIR`.

Omasnap býr skjámyndamöppuna til sjálfkrafa. Búðu skjáupptökumöppuna til sjálf/ur, endurræstu svo Omarchy til að hvor umhverfisbreytingin sem er taki gildi.

### Hvernig fæ ég hátalarana + vefmyndavélina til að virka á Apple Studio Display skjánum mínum?

Maður skyldi halda að allt ætti bara að virka með því að stinga USB C í samband, en því miður er það ekki raunin. Lausnin sem ég hef fundið til að láta þetta virka áreiðanlega er að nota [WJESOG DisplayPort + USB-A => USB-C snúruna](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Þá virka hátalarar og vefmyndavél eins og smurt.

Mundu að þú ert með innbyggða birtustýringu í Omarchy fyrir Apple skjáina (bæði Studio og XDR) með venjulegu birtuhnöppunum á lyklaborðinu.

### Hvernig losna ég við allan auka hugbúnaðinn?

Ef þú vilt ekki forrit eins og Obsidian eða LibreOffice eða eitthvað annað af fyrirfram uppsetta dótinu geturðu fjarlægt það mjög auðveldlega.

Keyrðu _Fjarlægja > Pakki_ til að sjá hvern einasta pakka sem er uppsettur. Síðan geturðu valið hvaða pakka sem þú vilt fjarlægja með tab, og byrjað að fjarlægja allt sem þú hefur valið með return.

Og þú getur notað _Fjarlægja > Vefforrit_ úr Omarchy valmyndinni til að fjarlægja einhver af fyrirfram uppsettu vefforritunum sem þú vilt ekki.

Eða keyrðu _Fjarlægja > Fyrirfram uppsett_ til að sópa út öllum fyrirfram uppsettu aukahlutunum — vefforritum, TUI-forritum og valkvæðum forritum — í einu lagi. Flýtilyklarnir sem ræstu þau hverfa með þeim, svo þú situr eftir með hreint borð af bindingum til að fylla með þínum eigin í `~/.config/hypr/bindings.lua`.

---

Fyrir villur og bilaða hluti, sjá [hlutann um úrræðaleit](45-troubleshooting.md).
