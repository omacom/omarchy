# Extração de Texto e Ditado

### Extração de Texto

Prima `Super + Ctrl + PrtScr` para selecionar uma região no ecrã para extração de texto. O modelo OCR de código aberto tesseract converterá então rapidamente essa seleção em texto e colocá-la-á na área de transferência. Depois, basta premir `Super + V` para colar.

Isto é muito útil para retirar moradas de rodapés de imagens ou números de telefone incorporados em títulos de sítios web.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado predefinido, com processamento na nuvem sem transferências de modelos offline. Escolha o Superwhisper ou o [Voxtype](https://voxtype.io/) através de _Setup > Defaults > Dictation_ no menu do Omarchy. Ao selecionar um backend, este é instalado, se necessário, e torna-se a predefinição para o ditado. O Voxtype carrega um modelo base em inglês que ocupa 150MB; altere o modelo com `voxtype setup model` e outras definições através de `~/.config/voxtype/config.toml`. O Superwhisper abre as suas definições para escolher entre processamento na nuvem ou local, e o OPR mantém a aplicação atualizada.

Para ditar, mantenha premido `Right Alt` ou ative e desative com `Alt + Space`, e o texto ditado aparecerá na área de introdução focada. Estes atalhos utilizam o backend selecionado. O Right Alt também inicia o ditado quando utilizado numa combinação de modificadores; utilize o Left Alt para essas combinações. Em disposições de teclado em que o Right Alt é AltGr, utilize `Alt + Space` para manter o AltGr disponível para escrever. As instalações anteriores a Alt + Space se tornar a predefinição mantêm `F9` para premir para falar e `Super + Ctrl + X` para alternar, adicionados a `~/.config/hypr/bindings.lua`; remova-os aí para devolver essas teclas às aplicações.

Os mesmos atalhos funcionam com qualquer um dos backends. Selecione o seu backend através de Setup > Defaults > Dictation. O instalador do backend configura-o e guarda a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção é guardada em `~/.config/omarchy/defaults/dictation`. As instalações novas selecionam automaticamente o Superwhisper.

O Omarchy carrega automaticamente a integração com o ambiente de trabalho do backend selecionado. Não é necessária qualquer configuração do Superwhisper em `~/.config/hypr/`.

As atribuições de teclas personalizadas e os scripts podem utilizar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado trata da gravação e da transcrição. Ao selecionar o Superwhisper, o seu atalho nativo de manter premido é desativado e o seu atalho nativo de alternância é definido para `Ctrl + Alt + Space`, o que o mantém separado das teclas de gravação do Omarchy. O Superwhisper requer pelo menos um atalho nativo de gravação, e o seu atalho de cancelamento permanece disponível.

Backends adicionais podem integrar-se sem alterar o Omarchy. Forneça um executável chamado `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e retorne prontamente, com um estado diferente de zero em caso de falha. O seu instalador configura o fornecedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isto para o backend anterior e guarda a seleção de forma atómica; `stop` tem de ser bem-sucedido quando o fornecedor está inativo ou indisponível. Os nomes dos backends utilizam letras minúsculas, dígitos e hífenes. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` inicia-o. Adicione uma entrada no menu Defaults através de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com o ambiente de trabalho pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
