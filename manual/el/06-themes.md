# Θέματα

Το Omarchy έρχεται με είκοσι τρία πανέμορφα θέματα. Μπορείτε να επιλέξετε ανάμεσά τους μέσω του _Εμφάνιση > Θέμα_ στο Omarchy Menu (`Super + Space`) ή να μεταβείτε απευθείας στον επιλογέα θέματος χρησιμοποιώντας το `Super + Ctrl + T`.

Κάθε θέμα διαμορφώνει το στυλ της επιφάνειας εργασίας, του τερματικού, του neovim, της οθόνης δραστηριότητας (btop), του προγράμματος περιήγησής σας (Chrome, Chromium, Edge ή Brave) και ολόκληρου του κελύφους του Omarchy: της πάνω γραμμής, του μενού, των ειδοποιήσεων, του OSD και της οθόνης κλειδώματος. (Για το Obsidian, πρέπει να επιλέξετε χειροκίνητα το θέμα Omarchy μέσω του _Εμφάνιση > Θέματα_ μέσα στην εφαρμογή).

Τα θέματα έχουν ένα σύνολο εικόνων φόντου, ανάμεσα στις οποίες μπορείτε να επιλέξετε χρησιμοποιώντας το `Super + Ctrl + W`.

Μπορείτε να βρείτε ακόμη περισσότερα θέματα στη [σελίδα με τα επιπλέον θέματα](https://omarchy.org/themes/) ή ακόμη και να [δημιουργήσετε το δικό σας θέμα](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Εικονίδια εφαρμογών

Τα εικονίδια στον εκκινητή εφαρμογών και στο dock σχεδιάζονται με τα χρώματα του θέματός σας, οπότε αλλάζουν μαζί με αυτό. Προέρχονται από ένα σύνολο εικονιδίων, το οποίο επιλέγετε ξεχωριστά από το θέμα στο _Εμφάνιση > Εικονίδια_, από προεπισκοπήσεις κάθε συνόλου, με τον ίδιο τρόπο που επιλέγετε ένα θέμα:

- Το _Papercraft_ είναι το προεπιλεγμένο: όλα όσα είναι εγκατεστημένα, σχεδιασμένα με ένα στυλ. Οι εφαρμογές που είναι γνωστές από το λογότυπό τους, όπως το Chrome, το HEY ή το YouTube, διατηρούν το σχήμα του και παίρνουν τα χρώματα του θέματος.
- Το _Arcade_ σχεδιάζει τις ίδιες εφαρμογές ως pixel art 8-bit, όπως θα έκανε μια παλιά κονσόλα παιχνιδιών.
- Το _Original_ δείχνει κάθε εφαρμογή με το εικονίδιο που της έδωσε ο δημιουργός της.

Μπορείτε να εγκαταστήσετε ένα σύνολο εικονιδίων που έχει δημιουργήσει κάποιος άλλος με το _Εγκατάσταση > Στυλ > Εικονίδια_ (ή το `omarchy icons install <git url>`) και να το αφαιρέσετε ξανά από το _Αφαίρεση > Εικονίδια_. Το _Ενημέρωση > Επιπλέον Εικονίδια_ ανακτά την τελευταία έκδοση των συνόλων που έχετε εγκαταστήσει.

Για να δημιουργήσετε το δικό σας, βάλτε τα εικονίδιά σας στο `~/.config/omarchy/icons/<name>/`, ένα αρχείο ανά εφαρμογή, ονομασμένο σύμφωνα με τη γραμμή `Icon=` του αρχείου `.desktop` της εφαρμογής. Ένα αρχείο που τελειώνει σε `.svg` εμφανίζεται ως έχει. Ένα αρχείο που τελειώνει σε `.svg.tpl` σχεδιάζεται με τα χρώματα του θέματος: γράψτε `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ή `{{ icon_shadow }}` όπου μπαίνει ένα χρώμα. Το προεπιλεγμένο σύνολο στο `/usr/share/omarchy/icons/papercraft/` είναι ένα καλό μέρος για να ξεκινήσετε. Προσθέστε ένα `preview.png` για να εμφανίζεται το σύνολό σας στον επιλογέα· χωρίς αυτό, το Omarchy σχεδιάζει μια προεπισκόπηση από τα εικονίδιά σας. Για να αλλάξετε ένα μόνο εικονίδιο του προεπιλεγμένου συνόλου, βάλτε τη δική σας έκδοση στο `~/.config/omarchy/icons/papercraft/`.

### Ξεκλειδώματα

Τα θέματα μπορούν επίσης να έχουν προσαρμοσμένο σχέδιο ξεκλειδώματος, το οποίο χρησιμοποιείται για τη διαδικασία αποκρυπτογράφησης κατά την εκκίνηση. Μπορείτε να επιλέξετε ένα από αυτά στο _Εμφάνιση > Ξεκλείδωμα_. Μοιάζουν έτσι:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
