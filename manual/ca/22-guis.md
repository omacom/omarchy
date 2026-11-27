# GUIs

## Files

Files (Folio) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on es troba el terminal, cosa que estalvia un munt de clics. `Ctrl + L` et permet escriure un camí, i prémer `Space` sobre qualsevol fitxer el previsualitza a mida completa sense obrir-lo.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complexa —formatar una unitat, comprovar l'estat SMART, crear particions— obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

Una unitat xifrada demana la contrasenya quan es connecta. Perquè una es desbloqui tota sola, afegeix-hi un fitxer de clau amb `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` i posa aquest fitxer de clau a `~/.config/omarchy/drive-keys/<UUID>`, amb el nom de l'UUID que `lsblk -dno UUID /dev/sdX1` mostra per a la partició xifrada, i que només puguis llegir tu (`chmod 600`). Si aquest fitxer de clau falta o és rebutjat, se't demana la contrasenya com de costum.

El doble clic segueix uns valors predeterminats assenyats: les imatges, els vídeos i la música s'obren amb Omaview, els PDF amb Document Viewer, el Markdown amb Omawrite, i el text sense format amb el teu editor, Plain tret que en triïs un altre a _Setup > Defaults > Editor_.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; entra als directoris amb el teclat o el ratolí, marca el que ha de desaparèixer, i revisa les teves seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown senzills per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclosos l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial per a la sincronització](https://obsidian.md/sync) amb aplicacions mòbils per a iOS i Android. (https://obsidian.md/pricing).

Obsidian s'inicia amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és l'aplicació d'escriptura Markdown senzillíssima d'Omarchy. Sense magatzems, sense complements, només tu i les paraules.

Omawrite s'inicia amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina bàsica d'edició d'imatges ideal per retallar, redimensionar i fer altres manipulacions bàsiques. No esperis una alternativa a Photoshop. Però també té Vareta màgica i capes!

Pinta s'inicia des del llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i coherent. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Aether s'inicia des del llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, de manera que pots enviar fitxers cap a i des de Windows, macOS, Android, iOS i, és clar, Linux.

Pots obrir el menú Comparteix amb `Super + Ctrl + S` o a _Trigger > Share_ del menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia allò que has copiat com a fitxer de text. Ideal per passar un enllaç o un fragment al telèfon sense enviar-te un correu electrònic.
- **File** obre un selector de fitxers on en pots seleccionar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix es pot fer des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Si ometes el camí, obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Files i comparteix-la amb LocalSend.

El tallafocs d'Omarchy està tancat per defecte, excepte pel port de LocalSend, de manera que això funciona des del primer moment en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i molt més. És compatible amb els fitxers de Microsoft Office, de manera que és una manera fantàstica de poder obrir aquells documents de Word.

LibreOffice s'inicia des del llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és l'aplicació de presentacions senzillíssima d'Omarchy. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva a sota d'una previsualització en directe, arrossega les diapositives per ordenar-les i després presenta-la a pantalla completa o exporta-la a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Hype s'inicia des del llançador d'aplicacions (`Super + Space`). Prem `?` a dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera senzillíssima d'Omarchy de signar PDF i omplir-los. Posa la signatura desada, text i la data d'avui on vulguis d'una pàgina, i després desa una còpia signada al costat de l'original. Consulta [Omplir PDF](27-filling-out-pdfs.md) per saber com fer-ho.

Signed s'inicia des del llançador d'aplicacions (`Super + Space`), o obre-hi un PDF des del gestor de fitxers.

## Game Vibes

Game Vibes, al llançador d'aplicacions (`Super + Space`), és on viuen els petits jocs d'Omarchy: Checkmate, un joc d'escacs en 3D contra un amic o contra l'oponent incorporat; Cards, el solitari Klondike; Death Wish, un joc de plataformes de precisió al píxel amb deu sales plenes de punxes i serres; i Neon Swarm, un joc de trets arcade. Cadascun és una única pàgina web que segueix el teu tema. Tria'n un amb les fletxes i `Enter`, i torna a la llista amb `Esc` des de la pantalla de títol d'un joc o amb `Q` mentre està en pausa. S'obre a pantalla completa: `Super + F` el converteix en una finestra, i `Super + W` el tanca.

Els jocs que crees amb un agent també apareixen aquí: tria _Make something cool → Game_ al panell d'agents i descriu-ne un, o anomena un joc que ja sigui a Game Vibes per continuar treballant-hi. L'agent el copia a `~/Games/vibes`, on és teu perquè el canviïs, i l'obre quan ha acabat. Pots fer aquesta còpia tu mateix amb `omarchy games vibes copy <game>`. Un joc que comparteix una altra persona s'instal·la com un tema: tria _Install > Gaming > Game Vibes_ i enganxa'n l'adreça git, o executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ en torna a treure un, i _Update > Game Vibes Games_ n'obté versions noves. Els jocs carreguen three.js des del web, de manera que necessiten connexió per iniciar-se.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la calculadora senzillíssima d'Omarchy, que s'obre en una finestra flotant.

Omacalc s'inicia amb `Super + Shift + Q` (o amb la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E, i una gran opció de comunicació per a qualsevol que prefereixi no passar per un dels grans conglomerats tecnològics.

Signal s'inicia amb `Super + Shift + G`. No forma part de la instal·lació bàsica, de manera que la primera vegada que prems aquesta combinació, Omarchy t'oferirà instal·lar-lo (també és a _Install > Service_ del menú d'Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) és el visualitzador d'imatges i reproductor multimèdia senzillíssim d'Omarchy: una única finestra per a les teves fotos, vídeos i música. Obre una foto i les tecles de fletxa recorren la resta de la seva carpeta, `N` i `P` ho fan per a qualsevol cosa, i `Ctrl + M` mostra tota la carpeta com una quadrícula. També mostra fotos HEIC, AVIF i JPEG XL, i reprèn allò que és llarg allà on ho vas deixar.

Prem `F` per a la pantalla completa, `E` per editar una imatge amb Omasnap o retallar un vídeo amb Omacut, `Ctrl + P` per imprimir una imatge, i `Delete` per moure un fitxer a la Paperera (`Ctrl + Z` el recupera). Prem `?` a dins per veure totes les dreceres.

Omaview s'inicia com a _Media Viewer_ des del llançador d'aplicacions (`Super + Space`), o simplement fes doble clic sobre una imatge, un vídeo o una cançó al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el retallador de vídeos senzillíssim d'Omarchy. Quan tot el que necessites és tallar el principi i el final d'un clip, supera de llarg obrir un editor de vídeo complet.

Omacut s'inicia des del llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és la gravadora de càmera web senzillíssima d'Omarchy. Tria la càmera i el micròfon una vegada, després prem `Space` per gravar, i prem-lo una altra vegada per posar en pausa i reprendre la mateixa presa. Sempre grava amb la resolució més alta de la càmera, amb un mesurador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre immediatament en un editor incorporat. Fes doble clic sobre un clip per dividir-lo, arrossega les nanses per retallar cada fragment, i elimina les parts que no vols. Després desa-ho com a MP4. La gravació original es conserva fins que la descartes, de manera que sempre pots tornar-hi i tallar-la d'una altra manera.

Monologue s'inicia des del llançador d'aplicacions (`Super + Space`).
