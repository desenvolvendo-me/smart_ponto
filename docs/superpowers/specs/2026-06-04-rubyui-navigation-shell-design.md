# RubyUI Navigation Shell Design

## Context

O `smart_ponto` ja migrou varias telas para RubyUI, Phlex e Tailwind com um visual claro, institucional e leve. O shell autenticado ainda ficou para tras: a navegacao principal vive em um bloco grande dentro do layout, duplica markup entre desktop e mobile, usa JavaScript inline para controlar abertura e colapso, e ainda preserva uma hierarquia de informacao mais antiga do que a adotada nas telas migradas.

O objetivo desta etapa e migrar o menu tambem para RubyUI, aproveitando a mesma linguagem visual do restante do produto e corrigindo a estrutura da navegacao para refletir melhor a organizacao real do sistema.

## Problem Summary

Hoje o shell autenticado tem cinco problemas principais:

1. O menu esta acoplado ao layout principal e duplicado entre desktop e mobile.
2. O comportamento do menu fica em um script inline grande, enquanto o `sidebar_controller.js` praticamente nao participa.
3. A navegacao principal mistura secoes de produto com variacoes internas da tela, como `Calendario`, e com acoes utilitarias, como `Exportar`.
4. O visual da sidebar ainda segue um padrao escuro e pesado que nao conversa com o design system atual.
5. Existe pelo menos um item de navegacao sem destino real (`Usuarios` com `#`), o que reduz confianca e clareza.

## Goals

- Migrar o shell autenticado para uma composicao baseada em RubyUI e Phlex.
- Eliminar a duplicacao do menu entre desktop e mobile.
- Reorganizar a hierarquia da navegacao principal.
- Remover o JavaScript inline do layout e mover o comportamento para Stimulus.
- Alinhar o menu ao design system claro e institucional ja usado no restante da aplicacao.

## Non-Goals

- Nao redesenhar todas as telas internas nesta etapa.
- Nao criar novas funcionalidades de permissao ou novas rotas.
- Nao introduzir um sistema generico de navegacao para todo o app alem do shell autenticado.
- Nao inventar um componente RubyUI oficial novo se a necessidade puder ser resolvida com composicao de componentes existentes e Phlex.

## User Intent

### Colaborador

Precisa entrar no sistema e encontrar rapidamente os caminhos principais para acompanhar o proprio ponto, sem confundir secoes principais com modos de visualizacao secundarios.

### Gestor

Precisa alternar entre o proprio acompanhamento e tarefas operacionais da equipe, como aprovacoes e gestao da equipe, com separacao clara entre trabalho pessoal e responsabilidades de gestao.

## Information Architecture

### Navegacao principal

Itens globais do shell:

- `Dashboard`
- `Meu ponto`
- `Aprovacoes` somente para `gestor`
- `Gestao da equipe` somente para `gestor`

### Navegacao contextual

Itens que deixam de aparecer como secoes globais:

- `Calendario`: permanece como navegacao secundaria dentro da area `Meu ponto`
- `Exportar`: permanece como acao contextual dentro de `Meu ponto`

### Rodape da navegacao

- resumo do usuario autenticado
- atalho para `Configuracoes`
- acao de `Sair`

## Visual Direction

O shell deve seguir a direcao ja consolidada no projeto:

- superficies claras
- bordas suaves
- acento indigo para estado ativo, foco e CTA
- contraste institucional, leve e previsivel
- menos cara de painel escuro generico e mais cara de ferramenta operacional confiavel

### Implicacoes visuais

- sidebar clara usando tokens de `sidebar` e `border`
- estado ativo mais evidente por fundo, texto e icone, sem depender de uma bolinha lateral
- grupo de gestao separado por heading discreto, nao por bloco pesado
- drawer mobile com overlay suave e painel coerente com a sidebar desktop
- header desktop mais simples, servindo apenas como abrigo do toggle e continuidade do layout

## Technical Design

### Layout structure

O layout autenticado continua em `app/views/layouts/application.html.erb`, mas deixa de conter a arvore completa do menu.

O layout passa a:

- montar o shell geral
- renderizar o componente de navegacao
- expor hooks de Stimulus para mobile drawer e estado de colapso
- manter `flash` e `yield` no conteudo principal

### Navigation component

Criar um componente Phlex proprio para a navegacao autenticada. Ele sera responsavel por:

- declarar os itens do menu em um unico lugar
- calcular estado ativo com base em helpers de rota e no caminho atual
- aplicar regras de visibilidade por papel
- renderizar tanto a navegacao principal quanto o rodape do usuario

Esse componente nao precisa virar uma abstracao ampla demais. O foco e centralizar a navegacao autenticada atual com limites claros.

### Shared menu definition

Os itens do menu devem nascer de uma unica definicao em Ruby, contendo pelo menos:

- rotulo
- rota
- icone
- regra de visibilidade
- regra de ativo
- agrupamento, quando aplicavel

Isso evita repeticao entre variantes desktop e mobile e reduz fragilidade de `request.path.include?` espalhado no template.

### Responsive composition

Deve existir uma unica fonte de markup para os itens de navegacao. O shell pode renderizar wrappers diferentes para desktop e mobile, mas a lista de itens e o card de usuario devem vir da mesma composicao.

Desktop e mobile devem diferir em:

- posicionamento
- largura
- animacao de entrada
- overlay

Nao devem diferir em:

- estrutura da lista
- ordem dos itens
- regras de ativo
- visibilidade por papel

### Stimulus behavior

`sidebar_controller.js` passa a controlar:

- abrir e fechar o drawer mobile
- abrir e fechar pelo overlay
- colapsar e expandir a sidebar desktop
- persistir o estado de colapso no `localStorage`
- aplicar classes e atributos sem JavaScript inline no layout

O controller deve parar de usar `console.log` de depuracao e adotar targets e actions do Stimulus.

## Accessibility

O shell deve melhorar o comportamento acessivel atual:

- botoes com `aria-label` quando so houver icone
- indicacao clara de foco visivel
- drawer mobile fechavel por overlay e botao dedicado
- estado ativo nao dependente apenas de cor
- sem remover affordance de foco por `outline-none` sem substituicao adequada

## Route and behavior expectations

- `Dashboard` continua apontando para `dashboard_index_path`
- `Meu ponto` continua apontando para `time_sheets_path`
- `Aprovacoes` continua apontando para `approvals_path` para gestores
- `Gestao da equipe` continua apontando para `manager_team_members_path` para gestores
- `Configuracoes` continua apontando para `edit_user_preference_path`
- `Sair` continua usando `destroy_user_session_path`

O item `Usuarios` com destino `#` deve ser removido nesta etapa, porque nao representa uma rota navegavel real.

## Testing Strategy

### View/component coverage

Adicionar cobertura para garantir:

- itens corretos para colaborador
- itens corretos para gestor
- estados ativos corretos das secoes principais
- ausencia de `Calendario` e `Exportar` como itens globais do shell

### Request/integration coverage

Garantir ao menos uma verificacao de renderizacao do shell autenticado nas rotas principais, cobrindo:

- usuario comum vendo `Dashboard` e `Meu ponto`
- gestor vendo tambem `Aprovacoes` e `Gestao da equipe`

### JavaScript behavior

Se a base atual nao tiver infraestrutura de teste JS adequada para Stimulus, a etapa pode se limitar a manter o controller pequeno e verificavel por comportamento manual. Ainda assim, a logica deve ficar simples o bastante para nao depender de seletores fragilizados.

## Risks and Mitigations

### Risco: mexer demais no layout principal

Mitigacao: manter a mudanca focada no shell autenticado, sem refatorar areas nao relacionadas.

### Risco: quebrar estado ativo de rotas

Mitigacao: concentrar a logica de ativo em um unico lugar e cobrir com testes de renderizacao.

### Risco: divergencia entre desktop e mobile

Mitigacao: usar uma unica definicao de itens e uma composicao compartilhada para a lista.

### Risco: regressao de usabilidade no mobile

Mitigacao: manter drawer simples, com overlay, close explicito e transicoes curtas.

## Success Criteria

- O shell autenticado usa composicao RubyUI/Phlex em vez de duplicar markup bruto no layout.
- O JavaScript inline do layout foi removido.
- `sidebar_controller.js` controla o estado do menu com Stimulus.
- `Calendario` e `Exportar` deixam de aparecer como secoes globais do menu.
- O item sem rota real foi removido.
- O menu visualmente conversa com as telas RubyUI ja migradas.
- O comportamento por papel continua correto.
