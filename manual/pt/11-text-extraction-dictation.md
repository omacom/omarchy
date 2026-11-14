# Extração de Texto e Ditado

### Extração de Texto

Prima `Super + Ctrl + PrtScr` para selecionar uma região no ecrã para extração de texto. O modelo OCR de código aberto tesseract converte depois rapidamente essa seleção em texto e coloca-o na área de transferência. Depois, basta premir `Super + V` para colar.

Isto é muito útil para apanhar moradas em rodapés de imagens ou números de telefone incorporados em títulos de sítios web.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Nas instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado predefinido, com processamento na nuvem sem transferências de modelos offline. Escolha Superwhisper, [Voxtype](https://voxtype.io/) ou [Hex](https://anoma.ly/hex/) através de _Setup > Defaults > Dictation_ no menu do Omarchy. Selecionar um backend instala-o, se necessário, e torna-o a predefinição para o ditado. O Voxtype carrega um modelo base de inglês que ocupa 150MB; altere o modelo com `voxtype setup model` e outras definições através de `~/.config/voxtype/config.toml`. O Superwhisper abre as suas definições para escolher entre processamento na nuvem ou local, e o OPR mantém a aplicação atualizada. O Hex transfere o seu modelo de voz no dispositivo durante a configuração e corre como o serviço de utilizador `hex.service`; abra a sua janela a partir do ícone da bandeja na barra ou executando `hex` para alterar o modelo e outras definições.

Dita ao manter premido `Right Alt`, ou ao alternar com `Alt + Space`, e o texto ditado aparece na área de introdução focada. Estes atalhos usam o backend selecionado. O Right Alt também inicia o ditado quando é usado numa combinação de modificadores; use o Left Alt para essas combinações. Nas disposições de teclado em que o Right Alt é AltGr, use `Alt + Space` para manter o AltGr disponível para escrever. As instalações anteriores a o Alt + Space se tornar a predefinição mantêm `F9` para premir para falar e `Super + Ctrl + X` para alternar, adicionados a `~/.config/hypr/bindings.lua`, onde esse `Super + Ctrl + X` ocupa o lugar do painel de agentes; remova-os aí para devolver essas teclas às aplicações e ao painel.

Os mesmos atalhos funcionam com todos os backends. Selecione o seu backend através de Setup > Defaults > Dictation. O instalador do backend configura-o e guarda a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção é guardada em `~/.config/omarchy/defaults/dictation`. As instalações novas selecionam o Superwhisper automaticamente.

O Omarchy carrega automaticamente a integração de ambiente de trabalho do backend selecionado. Não é necessária qualquer configuração do Superwhisper em `~/.config/hypr/`.

Os atalhos e scripts personalizados podem usar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado trata da gravação e da transcrição. Selecionar o Superwhisper desativa o seu atalho nativo de manter premido e define o seu alternar nativo para `Ctrl + Alt + Space`, mantendo-o separado das teclas de gravação do Omarchy. O Superwhisper requer pelo menos um atalho nativo de gravação, e o seu atalho de cancelamento mantém-se disponível.

Backends adicionais podem integrar-se sem alterar o Omarchy. Forneça um executável chamado `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e retorne prontamente, com um estado diferente de zero em caso de falha. O seu instalador configura o fornecedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isto para o backend anterior e guarda a seleção de forma atómica; `stop` tem de ter sucesso quando o fornecedor está inativo ou indisponível. Os nomes dos backends usam letras minúsculas, algarismos e hífenes. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` lança-o. Adicione uma entrada ao menu Defaults através de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com o ambiente de trabalho pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
