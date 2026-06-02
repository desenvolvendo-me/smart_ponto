# Plano de Migracao para RubyUI

## Objetivo

Migrar a UI atual do `smart_ponto` para RubyUI de forma incremental, reduzindo markup ERB repetido, padronizando componentes visuais e preservando os fluxos atuais de autenticacao, dashboard, ponto, aprovacoes e configuracoes.

## Estado Atual do Projeto

### Stack identificada

- Rails `8.0.2`
- `importmap-rails`, `turbo-rails`, `stimulus-rails`
- `propshaft`
- Tailwind carregado por CDN em [app/views/layouts/application.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/application.html.erb:12) e [app/views/layouts/devise.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/devise.html.erb:11)
- Nao existe `app/components/`
- Nao existe pipeline local de Tailwind 4 configurada em `app/assets/tailwind/application.css`

### Caracteristicas da UI atual

- UI feita majoritariamente em ERB com classes Tailwind inline.
- Layout principal muito grande e duplicado entre sidebar desktop/mobile:
  - [app/views/layouts/application.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/application.html.erb:1)
- Layout de autenticacao separado, tambem com markup manual:
  - [app/views/layouts/devise.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/devise.html.erb:1)
- Controllers Stimulus simples, mas fortemente acoplados ao HTML atual:
  - [app/javascript/controllers/tabs_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/tabs_controller.js:1)
  - [app/javascript/controllers/export_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/export_controller.js:1)
  - [app/javascript/controllers/flash_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/flash_controller.js:1)
- Estilos CSS locais quase inexistentes; o comportamento visual depende de classes inline.

### Views mais custosas para migrar

Por volume e concentracao de UI:

1. [app/views/dashboard/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/dashboard/index.html.erb:1) com 557 linhas
2. [app/views/layouts/application.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/application.html.erb:1) com 499 linhas
3. [app/views/time_sheets/calendar.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/calendar.html.erb:1) com 376 linhas
4. [app/views/manager/team_members/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/manager/team_members/index.html.erb:1) com 286 linhas
5. [app/views/user_preferences/edit.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/user_preferences/edit.html.erb:1) com 283 linhas
6. [app/views/time_sheets/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/index.html.erb:1) com 251 linhas
7. [app/views/time_sheets/export.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/time_sheets/export.html.erb:1) com 204 linhas
8. [app/views/approvals/index.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/approvals/index.html.erb:1) com 197 linhas

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
- `Sidebar`
- `Dialog` ou `Sheet` onde houver menu mobile ou confirmacoes futuras

Mapeamento inicial com a UI atual:

- flash atual -> `Alert` ou `Toast`
- abas em configuracoes e aprovacoes -> `Tabs`
- menu lateral -> `Sidebar`
- cards do dashboard -> `Card`, `Badge`, `Progress`
- tabelas de exportacao, aprovacoes e gestao de equipe -> `Table`
- filtros e formularios -> `Form`, `Input`, `Select`, `Checkbox`, `Radio Button`

Saida esperada:

- biblioteca base reutilizavel pronta
- classes Tailwind inline reduzidas nos elementos repetidos

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

## Riscos e cuidados

### 1. RubyUI assume Tailwind 4 local

Risco:

- a aplicacao hoje usa Tailwind via CDN, o que foge do setup alvo

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

## Backlog tecnico sugerido

1. Instalar RubyUI no projeto com `Rails + Importmaps`
2. Criar infraestrutura `app/components`
3. Remover Tailwind CDN e subir Tailwind local
4. Migrar `flash` para componente base
5. Migrar layout Devise
6. Migrar shell principal com sidebar/topbar
7. Migrar formularios pequenos
8. Migrar telas com tabs e tabelas
9. Migrar dashboard
10. Migrar calendario e telas finais

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

Nao recomendo migracao "page by page" sem antes instalar a fundacao RubyUI/Phlex/Tailwind local. O caminho mais seguro para este projeto e:

1. bootstrap tecnico
2. primitives globais
3. layouts
4. formularios pequenos
5. tabelas e tabs
6. dashboard e calendario por ultimo

Se quisermos executar isso na sequencia correta, o proximo passo pratico e abrir uma primeira entrega focada apenas na Fase 0: instalar RubyUI, sair do Tailwind CDN e criar a base `app/components`.
