# Pinag-isang Clipboard at Kasaysayan

Karaniwan sa Linux, kailangan mo ng `Ctrl + Shift + C/V` para mag-copy'n'paste sa terminal at `Ctrl + C/V` para gawin ito sa lahat ng iba pang lugar. Mahirap iyong masanay para sa sinumang hindi ipinanganak at lumaki sa Linux! Ganun din ang paglipat mula super papuntang ctrl, kung galing ka sa Mac.

Tinatalakay ng Omarchy ang parehong problema gamit ang pinag-isang mga clipboard hotkey na gumagana (halos) kahit saan. Ito ang mga ito:

| Hotkey | Command |
| ------- | ----------- |
| Super + C | Kopyahin |
| Super + X | I-cut |
| Super + V | I-paste |
| Super + Ctrl + V | Kasaysayan ng clipboard |

_Tandaan na karamihan sa mga agent harness ay gagamit ng `Ctrl + V` para sa pag-paste ng mga larawan, ngunit `Super + V` para sa pag-paste ng teksto._

### Kasaysayan ng clipboard

Ang kasaysayan ng clipboard ay ibinibigay ng shell ng Omarchy at gumagana para sa parehong teksto at mga larawan. Tri-trigger mo ito sa pamamagitan ng `Super + Ctrl + V`, pipiliin ang iyong entry gamit ang return, at pagkatapos ay mailalagay iyon sa clipboard na handa nang i-paste sa `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Maaari mo ring hanapin ang kasaysayan sa pamamagitan lang ng pagsisimulang mag-type:

 ![clipboard-history-search](images/clipboard-history-search.webp)
