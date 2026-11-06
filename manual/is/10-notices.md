# Tilkynningar

Tilkynningar lenda í efra hægra horni skjásins sem er í fókus. Þú getur líka fljótt séð dagsetningu og tíma, stöðu rafhlöðu og núverandi veður með flýtilykla-tilkynningunum.

## Tilkynningar

Tilkynningar frá sama forriti eða vefsíðu staflast í bunka, svo spjallmikil Slack-rás ýtir ekki bilun í smíðinni þinni út af skjánum. Haltu bendlinum yfir bunka til að breiða úr honum; ekkert nýtt rennur inn undir bendilinn þinn á meðan þú ert að lesa. Smelltu á spjald til að hoppa þangað sem það kom frá, hægrismelltu, miðjusmelltu eða ýttu á ✕ til að loka því.

Spjöld bjóða upp á það sem þau bera: _Afrita kóða_ fyrir staðfestingarkóða (geymdir utan [sögu klippiborðs](08-unified-clipboard-history.md) og hreinsaðir eftir mínútu), auk allra hnappa sem forritið býður upp á. Tenglar í texta tilkynningar opnast þegar smellt er á þá.

Til að nota þau án músar skaltu ýta á `Super + Ctrl + ,`. Nýjasta tilkynningin er valin og hnappar hennar númeraðir: ýttu á tölu til að nota einn, `Enter` til að smella á tilkynninguna, `↑` og `↓` til að færa þig á milli tilkynninga, `Delete` til að loka einni og `Esc` til að skila lyklaborðinu aftur. Það sleppir líka takinu af sjálfu sér eftir nokkrar sekúndur án aðgerða.

Að þagga niður í tilkynningum heldur þeim aftur, nema eigin staðfestingum Omarchy, neyðarviðvörunum og staðfestingarkóðum, sem þú baðst um fyrir augnabliki síðan. Settu síðustu nokkrar aftur á skjáinn, hvort sem þeim var haldið aftur eða ekki, með `Super + Shift + Alt + ,`. Sagan er geymd í einn dag.

## Tilkynningar með flýtilyklum

### Dagsetning og tími

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Veður

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Staðsetningin er greind út frá IP-tölunni þinni, sem er yfirleitt nógu nálægt lagi, en ekki alltaf. Þú getur fest hana með `omarchy weather location --set Malibu`, eða verið nákvæmur með því að bæta við hnitum: `omarchy weather location --set Malibu 34.0259,-118.7798`. Keyrðu `omarchy weather location` eitt og sér til að sjá hvar kerfið heldur að þú sért, og `--clear` til að fara aftur í sjálfvirka greiningu.

### Rafhlaða

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
