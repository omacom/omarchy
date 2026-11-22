# Appunti unificati e cronologia

Di solito su Linux, ti serve `Ctrl + Shift + C/V` per fare copia e incolla nel terminale e `Ctrl + C/V` per farlo ovunque altro. È difficile abituarcisi per chiunque non sia nato e cresciuto su Linux! Lo è anche il passaggio da super a ctrl, se vieni dal Mac.

Omarchy affronta entrambi i problemi con scorciatoie unificate per gli appunti che funzionano (quasi) ovunque. Sono:

| Scorciatoia | Comando |
| ------- | ----------- |
| Super + A | Seleziona tutto |
| Super + C | Copia |
| Super + X | Taglia |
| Super + V | Incolla |
| Super + Ctrl + V | Cronologia degli appunti |

_Nota che la maggior parte degli agent harness userà `Ctrl + V` per incollare le immagini, ma `Super + V` per incollare il testo._

Usa `Super + A`, poi `Super + C` per copiare tutto in un campo di testo attivo o in un'altra app che supporta `Ctrl + A`. In un terminale, `Ctrl + A` sposta all'inizio della riga di comando invece di selezionarne il testo.

### Cronologia degli appunti

La cronologia degli appunti è fornita dalla shell di Omarchy e funziona sia per il testo che per le immagini. La attivi con `Super + Ctrl + V` e selezioni la voce desiderata con Return, che la incolla direttamente nell'app in cui ti trovavi. Usa `Shift + Return` solo per copiarla negli appunti, `Alt + Return` per aprirla, `Delete` per rimuoverla dalla cronologia e `Shift + Delete` per cancellare l'intera cronologia.

 ![clipboard-history](images/clipboard-history.webp)

Puoi anche cercare nella cronologia semplicemente iniziando a digitare:

 ![clipboard-history-search](images/clipboard-history-search.webp)
