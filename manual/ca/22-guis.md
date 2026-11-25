# Interfícies gràfiques

## Files

Files (Folio) és el gestor de fitxers gràfic. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on és el terminal, cosa que estalvia molts clics. `Ctrl + L` et permet escriure un camí, i prémer `Space` damunt de qualsevol fitxer en mostra una previsualització a mida completa sense obrir-lo.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que apareix directament a la barra lateral. Per a qualsevol cosa més complexa — donar format a una unitat, comprovar l'estat SMART, crear particions — obre _Disks_ des del llançador d'aplicacions (`Super + Space`).

En fer doble clic s'apliquen opcions predeterminades assenyades: les imatges, els vídeos i la música s'obren a Omaview, els PDF a Document Viewer, els fitxers Markdown a Omawrite i el text pla al teu editor, Plain tret que en triïs un altre a _Setup > Defaults > Editor_.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, obre [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa d'arbre gràfic del teu directori d'inici. Els blocs més grans ocupen més espai; navega pels directoris amb el teclat o el ratolí, marca el que ha de desaparèixer i revisa les seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació per prendre notes gratuïta i molt extensible que utilitza fitxers Markdown simples per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, inclosos l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial de sincronització](https://obsidian.md/sync) amb aplicacions mòbils per a iOS i Android. (https://obsidian.md/pricing).

Inicies Obsidian amb `Super + Shift + O`. Per utilitzar la sincronització de temes, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és l'aplicació d'escriptura Markdown extremadament senzilla d'Omarchy. Sense voltes, sense complements, només tu i les paraules.

Inicies Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina bàsica d'edició d'imatges que va molt bé per retallar, redimensionar i fer altres manipulacions bàsiques. No esperis, però, una alternativa a Photoshop. Però tot i així té la Magic Wand i capes!

Inicies Pinta des del llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i coherent. És la manera més fàcil de [crear el teu propi tema](43-making-your-own-theme.md).

Inicies Aether des del llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. Això sí, és multiplataforma, de manera que pots enviar i rebre fitxers amb Windows, macOS, Android, iOS i, per descomptat, Linux.

Pots obrir el menú Share amb `Super + Ctrl + S` o a _Trigger > Share_ del menú d'Omarchy. Et dona quatre opcions:

- **Clipboard** envia el que hagis copiat com a fitxer de text. Perfecte per passar un enllaç o un fragment al telèfon sense enviar-te un correu electrònic.
- **File** obre un selector de fitxers on en pots seleccionar diversos alhora.
- **Folder** envia un directori sencer.
- **Receive** obre LocalSend pròpiament dit perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Omet el camí i obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Files i comparteix-la amb LocalSend.

El tallafoc d'Omarchy està tancat per defecte excepte pel port de LocalSend, de manera que això funciona des del primer moment en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet ofimàtic complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i més. És compatible amb els fitxers de Microsoft Office, de manera que és una manera excel·lent de poder obrir aquests documents de Word.

Inicies LibreOffice des del llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és l'aplicació de presentacions extremadament senzilla d'Omarchy. La teva presentació és un únic fitxer Markdown amb les seves imatges i vídeos al costat: escriu cada diapositiva sota una previsualització en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Inicies Hype des del llançador d'aplicacions (`Super + Space`). Prem `?` un cop a dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la manera extremadament senzilla d'Omarchy de signar PDF i emplenar-los. Col·loca la signatura desada, text i la data d'avui on vulguis d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Com emplenar PDF](27-filling-out-pdfs.md) per saber com fer-ho.

Inicies Signed des del llançador d'aplicacions (`Super + Space`), o obre-hi un PDF des del gestor de fitxers.

## Game Vibes

Game Vibes, al llançador d'aplicacions (`Super + Space`), és on viuen els petits jocs d'Omarchy: Checkmate, un joc d'escacs en 3D contra un amic o contra l'oponent integrat; Cards, el solitari Klondike; Death Wish, un joc de plataformes de precisió mil·limètrica amb deu sales plenes de punxes i serres; i Neon Swarm, un joc de trets arcade. Cadascun és una única pàgina web que segueix el teu tema. Tria'n un amb les fletxes i `Enter`, i torna a la llista amb `Esc` des de la pantalla de títol d'un joc o amb `Q` mentre està en pausa. S'obre a pantalla completa: `Super + F` el converteix en finestra i `Super + W` el tanca.

Els jocs que creïs amb un agent també apareixen aquí: tria _Make something cool → Game_ al tauler d'agents i descriu-ne un, o anomena un joc que ja sigui a Game Vibes per continuar treballant-hi. L'agent el copia a `~/Games/vibes`, on és teu per modificar-lo, i l'obre quan ha acabat. Pots fer aquesta còpia tu mateix amb `omarchy games vibes copy <game>`. Un joc que comparteix una altra persona s'instal·la com un tema: tria _Install > Gaming > Game Vibes_ i enganxa'n l'adreça git, o executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ en torna a treure un, i _Update > Game Vibes Games_ n'obté les versions noves. Els jocs carreguen three.js des del web, de manera que necessiten connexió per iniciar-se.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la calculadora extremadament senzilla d'Omarchy, que s'obre en una finestra flotant.

Inicies Omacalc amb `Super + Shift + Q` (o amb la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada E2E i una opció de comunicació excel·lent per a qualsevol que prefereixi no passar per un dels grans conglomerats tecnològics.

Inicies Signal amb `Super + Shift + G`. No forma part de la instal·lació base, de manera que la primera vegada que prems aquesta combinació, Omarchy t'oferirà instal·lar-lo per tu (també és a _Install > Service_ del menú d'Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) és el visor d'imatges i reproductor multimèdia extremadament senzill d'Omarchy: una sola finestra per a les teves fotos, vídeos i música. Obre una foto i les tecles de fletxa passen per la resta de la seva carpeta, `N` i `P` ho fan per a qualsevol cosa i `Ctrl + M` mostra tota la carpeta com una quadrícula. També mostra fotos HEIC, AVIF i JPEG XL, i reprèn on ho vas deixar en qualsevol contingut llarg.

Prem `F` per a pantalla completa, `E` per editar una imatge a Omasnap o retallar un vídeo a Omacut, `Ctrl + P` per imprimir una imatge i `Delete` per moure un fitxer a la Trash (`Ctrl + Z` el recupera). Prem `?` un cop a dins per veure totes les dreceres.

Inicies Omaview com a _Media Viewer_ des del llançador d'aplicacions (`Super + Space`), o simplement fes doble clic en una imatge, un vídeo o una cançó al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el retallador de vídeo extremadament senzill d'Omarchy. Quan tot el que necessites és tallar l'inici i el final d'un clip, és millor que engegar un editor de vídeo complet.

Inicies Omacut des del llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és l'enregistrador de càmera web extremadament senzill d'Omarchy. Tria la càmera i el micròfon una vegada i després prem `Space` per enregistrar, i una altra vegada per posar en pausa i reprendre la mateixa presa. Sempre enregistra a la resolució més alta de la càmera, amb un mesurador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre immediatament en un editor integrat. Fes doble clic en un clip per dividir-lo, arrossega les nanses per retallar cada fragment i elimina les parts que no vols. Després desa'l com a MP4. L'enregistrament original es conserva fins que el descartes, de manera que sempre pots tornar i tallar-lo d'una altra manera.

Inicies Monologue des del llançador d'aplicacions (`Super + Space`).
