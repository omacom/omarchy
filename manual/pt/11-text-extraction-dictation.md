# Extração de Texto e Ditado

### Extração de Texto

Prima `Super + Ctrl + PrtScr` para selecionar uma região no ecrã para a extração de texto. O modelo de OCR de código aberto tesseract irá então converter rapidamente essa seleção em texto e colocá-lo na área de transferência. Depois, basta premir `Super + V` para colar.

Isto é muito útil para extrair endereços de rodapés de imagens ou números de telefone incorporados em títulos de sítios web.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado predefinido, com processamento na nuvem sem transferências de modelos para utilização offline. Escolha o Superwhisper, o [Voxtype](https://voxtype.io/) ou o [Hex](https://anoma.ly/hex/) através de _Setup > Defaults > Dictation_ no menu do Omarchy. Ao selecionar um backend, este é instalado se for necessário e passa a ser o predefinido para o ditado. O Voxtype carrega um modelo base em inglês que ocupa 150MB; altere o modelo com `voxtype setup model` e outras definições através de `~/.config/voxtype/config.toml`. O Superwhisper abre as suas definições para escolher o processamento na nuvem ou local, e o OPR mantém a aplicação atualizada. O Hex descarrega o seu modelo de voz no dispositivo durante a configuração e corre como o serviço de utilizador `hex.service`; abra a sua janela a partir do ícone da bandeja da barra ou ao executar `hex` para alterar o modelo e outras definições.

Dita ao manter premido o `Right Alt`, ou ao alternar com `Alt + Space`, e o texto ditado irá surgir na área de introdução focada. Estes atalhos utilizam o backend selecionado. O Right Alt também inicia o ditado quando é utilizado numa combinação de modificadores; utilize o Left Alt para essas combinações. Em disposições de teclado em que o Right Alt é AltGr, incluindo quando essa disposição é uma para a qual comuta, mantenha-o premido sozinho durante um momento para ditar; o AltGr premido em conjunto com outra tecla continua a escrever o seu caráter. As instalações anteriores à data em que o `Alt + Space` passou a ser a predefinição mantêm o `F9` para premir para falar e o `Super + Ctrl + X` para alternar, adicionados a `~/.config/hypr/bindings.lua`, onde esse `Super + Ctrl + X` ocupa o lugar do painel de agentes; remova-os aí para devolver essas teclas às aplicações e ao painel.

Os mesmos atalhos funcionam com todos os backends. Selecione o seu backend através de Setup > Defaults > Dictation. O instalador do backend configura-o e guarda a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção fica guardada em `~/.config/omarchy/defaults/dictation`. As instalações novas selecionam automaticamente o Superwhisper.

O Omarchy carrega automaticamente a integração com o ambiente de trabalho do backend selecionado. Não é necessária qualquer configuração do Superwhisper em `~/.config/hypr/`.

As associações personalizadas e os scripts podem utilizar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado trata da gravação e da transcrição. Ao selecionar o Superwhisper, o seu atalho nativo para manter premido fica desativado e o seu atalho nativo de alternância passa a ser `Ctrl + Alt + Space`, o que o mantém separado das teclas de gravação do Omarchy. O Superwhisper exige pelo menos um atalho de gravação nativo, e o seu atalho de cancelamento continua disponível.

É possível integrar backends adicionais sem alterar o Omarchy. Forneça um executável com o nome `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e que responda prontamente, com um estado diferente de zero em caso de falha. O seu instalador configura o fornecedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isto interrompe o backend anterior e guarda a seleção de forma atómica; o `stop` tem de ter êxito quando o fornecedor está inativo ou indisponível. Os nomes dos backends utilizam letras minúsculas, algarismos e hífenes. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` inicia-o. Adicione uma entrada ao menu Defaults através de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com o ambiente de trabalho pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
