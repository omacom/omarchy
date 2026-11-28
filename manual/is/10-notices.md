# Tilkynningar

Tilkynningar lenda í efra hægra horni skjásins sem er í fókus. Þú getur líka fljótt nálgast dagsetningu og tíma, stöðu rafhlöðunnar og núverandi veður með tilkynningunum á flýtilyklum.

## Tilkynningar

Tilkynningar frá sama forriti eða vefsvæði staflast í bunka, svo spjallþrjósk Slack-rás ýtir ekki byggingarbiluninni þinni út af skjánum. Haltu bendlinum yfir bunka til að fletta honum út; ekkert nýtt rennur inn undir bendilinn á meðan þú ert að lesa. Smelltu á kort til að hoppa þangað sem það kom frá, hægrismelltu, miðsmelltu eða ýttu á ✕ til að vísa því frá.

Kortin bjóða upp á það sem þau bera: _Afrita kóða_ fyrir staðfestingarkóða (geymdir utan [ferils klemmuspjalds](08-unified-clipboard-history.md) og hreinsaðir eftir mínútu), auk þeirra hnappa sem forritið býður upp á. Tenglar í texta tilkynningar opnast þegar smellt er á þá.

`Super + ,` vísar nýjustu tilkynningunni frá, eða opnar það sem hún bendir á þegar hún býður upp á það, `Super + Alt + ,` vísar aðeins síðustu tilkynningunni frá, `Super + Shift + ,` vísar þeim öllum frá og `Super + Shift + Alt + ,` opnar ferilinn. Til að nota þær án músar skaltu ýta á `Super + Ctrl + ,`. Nýjasta tilkynningin er valin og hnappar hennar númeraðir: ýttu á tölu til að nota einn, `Enter` til að smella á tilkynninguna, `↑` og `↓` til að fara á milli tilkynninga, `Delete` til að vísa einni frá og `Esc` til að skila lyklaborðinu aftur. Það sleppir líka takinu af sjálfu sér eftir nokkrar aðgerðalausar sekúndur.

Að þagga tilkynningar heldur þeim aftur, nema eigin staðfestingum Omarchy, neyðarviðvörunum og staðfestingarkóðum, sem þú baðst um fyrir augnabliki síðan. Settu síðustu nokkrar aftur á skjáinn, hvort sem þeim var haldið aftur eða ekki, með `Super + Shift + Alt + ,`. Ferillinn er geymdur í einn dag.

## Tilkynningar á flýtilyklum

### Dagsetning og tími

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Veður

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Staðsetningin er greind út frá IP-tölunni þinni, sem er yfirleitt nógu nálægt, en ekki alltaf. Þú getur fest hana með `omarchy weather location --set Malibu`, eða verið nákvæmur með því að bæta við hnitum: `omarchy weather location --set Malibu 34.0259,-118.7798`. Keyrðu `omarchy weather location` eitt og sér til að sjá hvar það heldur að þú sért, og `--clear` til að fara aftur í sjálfvirka greiningu.

### Rafhlaða

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
