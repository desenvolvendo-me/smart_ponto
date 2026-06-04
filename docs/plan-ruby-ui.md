# Plano de Migracao para RubyUI

## Objetivo

Documentar um plano de migracao RubyUI que sirva tanto como historico real do `smart_ponto` quanto como referencia transferivel para outro projeto Rails que queira medir a eficiencia do RubyUI com honestidade.

O foco deste documento nao e apenas “como instalar”, mas:

- onde RubyUI acelerou de verdade
- onde ele exigiu composicao local
- qual ordem de migracao foi mais eficiente
- quais partes nao devem ser usadas como benchmark universal

## Estado Atual do Projeto

### Stack efetivamente validada

- Rails `8.x`
- `importmap-rails`, `turbo-rails`, `stimulus-rails`
- `propshaft`
- `ruby_ui`
- `phlex-rails`
- `tailwind_merge`
- `tailwindcss-rails`
- Tailwind local em `app/assets/tailwind/application.css`
- componentes em `app/components/`
- componentes RubyUI em `app/components/ruby_ui`
- componentes compostos da aplicacao em `app/components/navigation`

### Estado funcional apos a migracao validada

- autenticacao Devise migrada
- dashboard migrado
- `time_entries/new`, `approvals/index`, `manager/team_members/index`, `time_sheets/index`, `time_sheets/calendar`, `time_sheets/export` e `user_preferences/edit` migrados
- shell autenticado extraido para componente Phlex proprio
- sidebar desktop/mobile com comportamento via Stimulus, sem script inline

### Telas ainda nao consolidadas no fluxo RubyUI

Pendencias identificadas nas views atuais:

- `devise/registrations/edit`
- `layouts/application`
- `layouts/_sidebar`
- `time_entries/index`
- `time_entries/show`
- `time_entries/_entry`
- `time_entries/create`
- `time_sheets/show`
- `time_sheets/pending_justifications`
- `time_sheets/approve`
- `justification_comments/index`
- `user_preferences/_form`
- `home/index`
- partials do Kaminari em `app/views/kaminari`

Leitura pratica:

- parte desse backlog sao telas reais ainda nao migradas
- parte sao shells/parciais compartilhados que precisam ser consolidados para fechar consistencia
- `user_preferences/edit` ja foi refinada, mas o partial `_form` continua devendo fechamento explicito no plano

Isso muda a leitura do plano:

- as fases abaixo nao sao mais hipotese pura
- elas refletem a ordem que de fato se mostrou eficiente aqui

### Superficies que mais expuseram limites e ganhos

Mais eficientes para benchmark:

1. autenticacao Devise
2. `time_entries/new`
3. `user_preferences/edit`
4. `approvals/index`

Eficiencia intermediaria:

1. `time_sheets/index`
2. `time_sheets/export`
3. `manager/team_members/index`
4. `dashboard/index`

Nao usar como benchmark simplista de “velocidade do RubyUI”:

1. `layouts/application` e shell autenticado
2. `time_sheets/calendar`

Motivo:

- shell mede mais arquitetura de interface do que primitive library
- calendario mede mais adaptacao estrutural do que produtividade basal de componente

## O que o RubyUI muda de fato

Segundo a documentacao oficial:

- RubyUI e baseado em `Phlex`, `TailwindCSS` e `Stimulus`
- o caminho oficial para este projeto e `Rails + Importmaps`
- o fluxo recomendado e instalar a gem, rodar o installer e adicionar componentes sob demanda

Impacto pratico para este projeto:

- a migracao nao e apenas cosmetica
- o projeto precisara introduzir `Phlex` e uma camada de componentes Ruby
- o Tailwind deve sair do CDN e passar para configuracao local, alinhada ao RubyUI
- varios blocos visuais atuais podem virar componentes reutilizaveis sem alterar controllers/servicos

Impacto observado na pratica:

- o ganho principal veio da combinacao `RubyUI + Phlex`, nao da gem isolada
- o RubyUI resolveu bem primitives
- a aplicacao continuou precisando de componentes compostos proprios para shell, estados e blocos especificos

Conclusao:

- medir “eficiencia do RubyUI” sem separar primitives de composicao gera conclusao errada

## Estrategia Recomendada

### Principios

- Migracao incremental, sem rewrite completo.
- Primeiro criar fundacao tecnica, depois componentes base, depois telas.
- Priorizar superficies com maior repeticao visual e menor risco funcional.
- Manter rotas, controllers, models e regras de negocio intactos sempre que possivel.
- Evitar migrar tudo para Phlex em uma vez; aceitar convivencia temporaria entre ERB legado e componentes RubyUI.

### Abordagem alvo

1. Instalar RubyUI no modo `Rails + Importmaps`.
2. Criar infraestrutura `app/components/` com `Phlex`.
3. Substituir primitives repetidas da UI atual por componentes RubyUI.
4. Extrair blocos de pagina grandes para componentes compostos locais.
5. Migrar pagina a pagina, mantendo comportamento atual.

### Regra de benchmark para outro projeto

Se este plano for usado em outro projeto para entender eficiencia:

- medir tempo e atrito por categoria:
  - setup/foundation
  - primitives
  - formularios
  - listagens/tabelas
  - dashboards
  - shell/navegacao
- nao consolidar tudo em um unico numero
- registrar separadamente:
  - tempo de setup
  - tempo de migracao
  - retrabalho de UX
  - bugs funcionais encontrados durante a migracao

## Fases do Plano

### Fase 0 - Bootstrap tecnico

Objetivo: deixar o projeto apto a receber RubyUI sem tocar nas telas principais.

Tarefas:

1. Adicionar gem:
   - `bundle add ruby_ui --group development --require false`
2. Rodar installer oficial:
   - `bin/rails g ruby_ui:install`
3. Validar o que o installer gerou ou, se necessario, completar manualmente:
   - `phlex-rails`
   - `tailwind_merge`
   - inicializador `config/initializers/ruby_ui.rb`
   - `app/components/base.rb`
   - `app/components/ruby_ui/base.rb`
4. Migrar Tailwind do CDN para configuracao local no padrao RubyUI:
   - remover `<script src="https://cdn.tailwindcss.com"></script>` dos layouts
   - criar/adotar `app/assets/tailwind/application.css`
   - incluir tokens, `@plugin "@tailwindcss/forms"` e `@plugin "@tailwindcss/typography"`
   - pin de `tw-animate-css` via importmap
5. Confirmar compatibilidade com `propshaft` e pipeline atual.
6. Definir convencao de nomes para componentes locais:
   - `Components::`
   - `RubyUI::`
   - `UI::` ou `SmartPonto::UI::` para componentes compostos da aplicacao

Saida esperada:

- RubyUI instalado
- Phlex operacional
- Tailwind local funcionando
- sem alterar comportamento das telas

Status no `smart_ponto`:

- concluida

### Fase 1 - Fundacao visual

Objetivo: eliminar repeticao das primitives mais comuns.

Extrair primeiro:

- `Button`
- `Card`
- `Badge`
- `Input`
- `Textarea`
- `Select` ou `Native Select`
- `Checkbox`
- `Radio Button`
- `Table`
- `Alert`
- `Toast` ou manter flash com `Alert` na primeira etapa
- `Tabs`
- `Sidebar` apenas se encaixar de verdade no produto
- `Dialog` ou `Sheet` onde houver menu mobile ou confirmacoes futuras

Mapeamento inicial com a UI atual:

- flash atual -> `Alert` ou `Toast`
- abas em configuracoes e aprovacoes -> `Tabs`
- menu lateral -> `Sidebar` apenas como referencia de primitive, nao como garantia de shell pronto
- cards do dashboard -> `Card`, `Badge`, `Progress`
- tabelas de exportacao, aprovacoes e gestao de equipe -> `Table`
- filtros e formularios -> `Form`, `Input`, `Select`, `Checkbox`, `Radio Button`

Saida esperada:

- biblioteca base reutilizavel pronta
- classes Tailwind inline reduzidas nos elementos repetidos

Status no `smart_ponto`:

- concluida de forma suficiente para migrar as principais telas
- o projeto nao precisou transformar toda primitive em componente proprio para seguir

### Fase 2 - Layouts e shells

Objetivo: migrar a estrutura global antes das telas de negocio.

Ordem sugerida:

1. [app/views/layouts/devise.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/devise.html.erb:1)
2. [app/views/layouts/application.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/application.html.erb:1)
3. [app/views/shared/_flash.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/shared/_flash.html.erb:1)

Objetivos tecnicos:

- encapsular sidebar desktop/mobile em componente
- padronizar topbar
- padronizar area de `flash`
- reduzir duplicacao de markup de autenticacao

Possiveis componentes:

- `AppShell`
- `AppSidebar`
- `Topbar`
- `FlashMessage`
- `AuthCard`

Resultado real no `smart_ponto`:

- autenticacao e shell foram migrados
- o shell principal nao foi resolvido por um `Sidebar` oficial pronto
- a solucao eficiente foi um componente local com RubyUI nas primitives
- ainda falta consolidar a cobertura em `application.html.erb` e `_sidebar.html.erb` como parte do backlog remanescente

Licao transferivel:

- shell raramente e bom benchmark de produtividade pura do RubyUI
- ele mede muito mais:
  - IA
  - responsividade
  - comportamento de produto
  - integracao entre layout e navegacao

### Fase 3 - Telas de baixo risco

Objetivo: ganhar velocidade antes de entrar nas paginas mais densas.

Ordem sugerida:

1. telas Devise:
   - sessoes
   - cadastro
   - reset de senha
2. [app/views/time_entries/new.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_entries/new.html.erb:1)
3. [app/views/user_preferences/_form.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/user_preferences/_form.html.erb:1)

Justificativa:

- formularios menores
- estrutura repetitiva
- pouco impacto em listagens complexas

Status no `smart_ponto`:

- concluida
- resta `devise/registrations/edit` como tela irma nao fechada nesse grupo

Licao:

- essa fase foi onde o RubyUI mostrou melhor relacao entre esforco e ganho
- use essa fase como benchmark principal se o outro projeto quiser validar viabilidade

### Fase 4 - Telas medias

Objetivo: consolidar padrao em paginas com filtros, tabelas e tabs.

Ordem sugerida:

1. [app/views/approvals/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/approvals/index.html.erb:1)
2. [app/views/approvals/_approval_item.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/approvals/_approval_item.html.erb:1)
3. [app/views/time_sheets/export.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/export.html.erb:1)
4. [app/views/manager/team_members/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/manager/team_members/index.html.erb:1)
5. [app/views/justification_comments/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/justification_comments/index.html.erb:1)

Aqui vale extrair componentes compostos como:

- `FilterBar`
- `DataTable`
- `StatusBadge`
- `EmptyState`
- `ApprovalActions`

Status no `smart_ponto`:

- concluida

Licao:

- aqui o RubyUI continuou eficiente, mas o gargalo passou a ser composicao e densidade
- o tempo economizado em primitive foi parcialmente reinvestido em hierarquia e responsividade

Backlog remanescente mais proximo desta fase:

1. `justification_comments/index`
2. partials do Kaminari
3. `time_entries/index`
4. `time_entries/show`
5. `time_entries/_entry`

### Fase 5 - Telas de alta complexidade

Objetivo: migrar as paginas maiores com base ja estabilizada.

Ordem sugerida:

1. [app/views/dashboard/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/dashboard/index.html.erb:1)
2. [app/views/time_sheets/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/index.html.erb:1)
3. [app/views/time_sheets/show.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/show.html.erb:1)
4. [app/views/time_sheets/pending_justifications.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/pending_justifications.html.erb:1)
5. [app/views/time_sheets/calendar.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/calendar.html.erb:1)

Observacao:

- `calendar.html.erb` deve ser a ultima entre as paginas principais, porque tende a exigir mais adaptacao estrutural e possivel uso de componentes `Calendar`, `Popover`, `Dialog`, `Badge` e `Button`.

Status no `smart_ponto`:

- concluida com maior atrito

Licao:

- dashboards e calendarios nao devem ser usados sozinhos como prova de que RubyUI e rapido ou lento
- eles sofrem muito mais influencia de UX local do produto

Backlog remanescente desta fase:

1. `time_sheets/show`
2. `time_sheets/pending_justifications`
3. `time_sheets/approve`

## Como usar o MCP do RubyUI a favor da migracao

Documentacao analisada:

- home: `https://www.rubyui.com/`
- MCP: `https://www.rubyui.com/docs/mcp`
- install `Rails + Importmaps`: `https://www.rubyui.com/docs/installation/rails_importmaps`
- componentes: `https://www.rubyui.com/docs/components`

### O que o MCP entrega

Ferramentas expostas pelo servidor:

- `get_project_registries`
- `list_items_in_registries`
- `search_items_in_registries`
- `view_items_in_registries`
- `get_item_examples_from_registries`
- `get_add_command_for_items`
- `get_audit_checklist`
- `get_install_command_for_project`

Leitura pratica depois da execucao real:

- o MCP foi mais util no setup inicial e em componentes estruturais
- ele foi menos relevante depois que a stack base ja estava dominada
- em outro projeto, usar MCP como acelerador, nao como ritual obrigatorio

### Como configurar

Exemplo para VS Code em `.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "ruby-ui": { "url": "https://rubyui.com/mcp" }
  }
}
```

### Fluxo recomendado de uso durante a migracao

1. Pedir ao agente para chamar `get_project_registries`.
2. Procurar o componente pelo caso de uso:
   - `search_items_in_registries` para "sidebar", "data table", "tabs", "form", "date picker", "toast"
3. Inspecionar implementacao real:
   - `view_items_in_registries`
4. Puxar exemplos de uso antes de codar:
   - `get_item_examples_from_registries`
5. Gerar comando oficial de instalacao do componente:
   - `get_add_command_for_items`
6. Depois da adocao base, validar checklist:
   - `get_audit_checklist`

### Como isso ajuda neste projeto

- evita escolher componente errado por nome
- permite ver dependencias reais de cada componente antes de instalar
- reduz tentativa e erro ao gerar `rails g ruby_ui:component ...`
- acelera extracao de componentes equivalentes ao HTML atual
- melhora consistencia entre componentes instalados e exemplos oficiais

### Uso pratico por tela

- Layout principal:
  - buscar `sidebar`, `sheet`, `dropdown menu`, `avatar`, `button`
- Dashboard:
  - buscar `card`, `badge`, `progress`, `table`
- Configuracoes:
  - buscar `tabs`, `form`, `input`, `native select`, `switch`, `radio button`
- Aprovacoes e gestao:
  - buscar `table`, `badge`, `button`, `tabs`, `checkbox`
- Calendario/exportacao:
  - buscar `calendar`, `date picker`, `popover`, `table`

## Plano objetivo para fechar as telas faltantes

### Prioridade 1 - Fechar irmas e compartilhados de baixo risco

1. `devise/registrations/edit`
2. `user_preferences/_form`
3. partials do Kaminari em `app/views/kaminari`

Motivo:

- baixo risco funcional
- fecha consistencia visual do que ja foi migrado
- reduz retrabalho em telas que dependem desses blocos

### Prioridade 2 - Consolidar shell autenticado e navegacao

1. `layouts/application`
2. `layouts/_sidebar`
3. `home/index`, se ainda fizer parte do fluxo navegavel do produto

Motivo:

- melhora consistencia transversal
- garante que telas novas nao herdem markup legado na moldura principal
- evita que a UX varie demais entre paginas ja migradas e nao migradas

### Prioridade 3 - Fechar modulo de registros

1. `time_entries/index`
2. `time_entries/show`
3. `time_entries/_entry`
4. `time_entries/create`, se de fato for view utilizada

Motivo:

- fecha uma area funcional que ja comecou em `time_entries/new`
- permite medir consistencia de formularios, listas e detalhes dentro do mesmo modulo

### Prioridade 4 - Fechar modulo de espelho e aprovacoes finais

1. `time_sheets/show`
2. `time_sheets/pending_justifications`
3. `time_sheets/approve`
4. `justification_comments/index`

Motivo:

- sao telas ligadas a estados, auditoria e fluxo de aprovacao
- dependem do padrao ja consolidado nas listagens e na exportacao

## Plano de acesso das telas para testes manuais

### Pre-condicoes

Antes dos testes:

1. subir a app Rails
2. autenticar com um usuario de colaborador
3. autenticar com um usuario de gestor para cobrir aprovacoes
4. garantir massa de dados minima:
   - registros de ponto em datas diferentes
   - pelo menos um espelho com justificativa pendente
   - pelo menos um espelho aprovado e um rejeitado

### Rotas principais para navegar

Autenticacao:

- `/users/sign_in`
- `/users/sign_up`
- `/users/password/new`
- `/users/password/edit?reset_password_token=TOKEN`
- `/users/edit`

Dashboard e shell:

- `/`
- validar menu lateral e shell em qualquer rota autenticada

Registros:

- `/registros`
- `/registros/new`
- `/registros/:id`

Espelho de ponto:

- `/meu-ponto`
- `/meu-ponto/calendar`
- `/meu-ponto/export_form`
- `/meu-ponto/pending_justifications`
- `/meu-ponto/:id`

Gestao e aprovacao:

- `/approvals`
- `/manager/gestao-equipe`
- `/meu-ponto/:time_sheet_id/comentarios`

Preferencias:

- `/user_preference/edit`

### Como acessar telas dependentes de ID

Para testes manuais, usar um registro existente do banco:

1. abrir `/meu-ponto`
2. copiar um `id` valido de um espelho listado
3. testar:
   - `/meu-ponto/:id`
   - `/meu-ponto/:id/comentarios`
4. abrir `/registros`
5. copiar um `id` valido de registro
6. testar:
   - `/registros/:id`

### Matriz minima de teste por perfil

Colaborador:

1. login
2. dashboard
3. `/registros/new`
4. `/registros`
5. `/meu-ponto`
6. `/meu-ponto/export_form`
7. `/user_preference/edit`
8. `/users/edit`

Gestor:

1. login
2. `/approvals`
3. `/manager/gestao-equipe`
4. `/meu-ponto/pending_justifications`
5. abrir um `/meu-ponto/:id/comentarios`

### Checklist manual por tela migrada ou pendente

Em cada tela:

1. validar desktop
2. validar mobile
3. validar estado vazio, se existir
4. validar loading ou resposta assincrona, se existir
5. validar CTA principal
6. validar navegacao de retorno
7. validar mensagens de sucesso/erro
8. validar se o shell compartilhado ficou consistente com as outras telas

## Riscos e cuidados

### 1. RubyUI assume Tailwind 4 local

Risco:

- em projetos que ainda usam Tailwind via CDN, o setup alvo do RubyUI nao encaixa direto

Mitigacao:

- tratar a mudanca de Tailwind como pre-requisito de infraestrutura
- nao iniciar migracao de telas antes disso

### 2. Stimulus atual pode conflitar com componentes novos

Risco:

- `tabs_controller.js`, `flash_controller.js` e `export_controller.js` dependem de markup especifico

Mitigacao:

- migrar por tela
- remover ou adaptar controllers apenas quando o componente RubyUI equivalente assumir o papel

### 3. Mistura temporaria ERB + Phlex

Risco:

- inconsistencia de padrao durante a transicao

Mitigacao:

- definir regra clara:
  - novas abstrações em `Phlex`
  - ERB legado so recebe ajustes pequenos ate sua migracao

### 4. Views grandes demais para conversao direta

Risco:

- tentar converter `dashboard`, `layout` ou `calendar` de uma vez aumenta regressao

Mitigacao:

- primeiro extrair blocos internos
- depois migrar o template raiz

### 5. Shell pode distorcer a percepcao de eficiencia

Risco:

- concluir que RubyUI e lento porque o shell deu mais trabalho

Mitigacao:

- avaliar shell como categoria separada
- medir produtividade de primitives e telas comuns isoladamente

### 6. Dashboard pode distorcer a percepcao de valor

Risco:

- concluir que RubyUI resolve UX sozinho porque a tela ficou mais bonita

Mitigacao:

- separar ganho de primitive do ganho de composicao
- documentar o que veio de RubyUI e o que veio de refinamento de layout

## Backlog tecnico sugerido

1. Fechar `devise/registrations/edit`
2. Consolidar `user_preferences/_form`
3. Migrar partials do Kaminari
4. Consolidar `layouts/application` e `layouts/_sidebar`
5. Fechar `time_entries/index`, `show` e `_entry`
6. Fechar `time_sheets/show`
7. Fechar `time_sheets/pending_justifications`
8. Validar se `time_sheets/approve` e `time_entries/create` ainda sao views ativas, migrar ou remover do backlog
9. Fechar `justification_comments/index`
10. Executar rodada manual completa por perfil e dispositivo

## Criterios de aceite por fase

### Bootstrap

- app sobe sem CDN de Tailwind
- RubyUI consegue instalar componentes no projeto
- componentes Phlex renderizam normalmente

### Layouts

- autenticacao e shell principal usam componentes reutilizaveis
- sidebar e flash deixam de depender de markup duplicado

### Telas

- nenhuma regressao funcional em formularios, filtros, exportacao e aprovacao
- classes inline relevantes diminuem
- novos trechos de UI passam a nascer como componentes

## Recomendacao final

Nao recomendo medir RubyUI por impressao geral ou por uma unica tela. O caminho mais seguro, aqui e em outro projeto Rails, e:

1. bootstrap tecnico
2. primitives globais
3. layouts
4. formularios pequenos
5. tabelas e tabs
6. dashboard e calendario por ultimo

Se o objetivo for benchmarking em outro projeto, a recomendacao e registrar no minimo:

- tempo de setup inicial
- tempo medio por formulario pequeno
- tempo medio por tela media com tabela/filtro
- atrito especifico de shell
- atrito especifico de dashboard/calendario

Conclusao sintetica do `smart_ponto`:

- RubyUI foi eficiente como fundacao e acelerador de consistencia
- `Phlex` foi essencial para composicao de produto
- shell e telas densas nao devem ser usados como benchmark unico
