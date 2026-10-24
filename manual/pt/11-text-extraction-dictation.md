# Extração de texto e ditado

### Extração de texto

Prime `Super + Ctrl + PrtScr` para selecionares uma região no ecrã para extração de texto. O modelo OCR de código aberto tesseract converte depois rapidamente essa seleção em texto e coloca-o na área de transferência. Depois basta premires `Super + V` para colar.

Isto é muito útil para apanhar moradas em rodapés de imagens ou números de telefone incorporados em títulos de websites.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o motor de ditado predefinido, usando processamento na nuvem sem transferências de modelos offline. Escolhe o Superwhisper ou o [Voxtype](https://voxtype.io/) através de _Configurar > Predefinições > Ditado_ no menu do Omarchy. Selecionar um motor instala-o, se for necessário, e torna-o a predefinição para o ditado. O Voxtype carrega um modelo base de inglês que ocupa 150 MB; muda o modelo com `voxtype setup model` e outras definições através de `~/.config/voxtype/config.toml`. O Superwhisper abre as suas definições para escolheres processamento na nuvem ou local, e o OPR mantém a aplicação atualizada.

Ditas segurando `Right Alt` ou `F9`, ou alternando com `Super + Ctrl + X`, e o texto ditado aparece na área de introdução em foco. Estes atalhos usam o motor selecionado. O Right Alt também inicia o ditado quando usado num acorde de modificadores; usa o Left Alt para esses acordes. Em disposições de teclado em que o Right Alt é AltGr, usa `F9` para manteres o AltGr disponível para escreveres.

Os mesmos atalhos funcionam com qualquer um dos motores. Seleciona o teu motor através de Configurar > Predefinições > Ditado. O instalador do motor configura-o e guarda a seleção. Executa `omarchy default dictation` para veres qual está selecionado. A seleção fica guardada em `~/.config/omarchy/defaults/dictation`. As instalações novas selecionam o Superwhisper automaticamente.

O Omarchy carrega automaticamente a integração de ambiente de trabalho do motor selecionado. Não é precisa qualquer configuração do Superwhisper em `~/.config/hypr/`.

Associações e scripts personalizados podem usar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O motor selecionado trata da gravação e da transcrição. Selecionar o Superwhisper desativa o seu atalho nativo de segurar e define a sua alternância nativa para `Alt + Space`, mantendo-a separada das teclas de gravação do Omarchy. O Superwhisper exige pelo menos um atalho de gravação nativo, e o seu atalho de cancelamento mantém-se disponível.

Motores adicionais podem integrar-se sem alterar o Omarchy. Fornece um executável chamado `omarchy-dictation-<motor>` no PATH que aceite `start`, `stop` e `toggle` e retorne de imediato, com um estado diferente de zero em caso de falha. O seu instalador configura o fornecedor e chama `omarchy-dictation-use <motor>` após uma configuração bem-sucedida. Isto para o motor anterior e guarda a seleção de forma atómica; `stop` tem de ter sucesso quando o fornecedor está inativo ou indisponível. Os nomes dos motores usam letras minúsculas, dígitos e hífenes. Fornece `omarchy-install-dictation-<motor>` para a configuração; `omarchy default dictation <motor>` lança-o. Adiciona uma entrada no menu de Predefinições através de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com o ambiente de trabalho pode viver em `${XDG_CONFIG_HOME:-$HOME/.config}/<motor>/shortcuts.lua`.
