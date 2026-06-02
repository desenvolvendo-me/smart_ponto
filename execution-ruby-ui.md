# Execution Guide: RubyUI

## Objetivo

Este arquivo documenta o processo padrao para migrar qualquer tela do `smart_ponto` para RubyUI com risco controlado, reaproveitando a base atual do projeto e usando o MCP do RubyUI quando isso reduzir tentativa e erro.

O objetivo futuro da skill e combinar:

- `https://rubyui.com/`
- `https://impeccable.style`

para criar, atualizar e refinar componentes RubyUI com qualidade visual mais alta, sem perder consistencia tecnica com Rails, Phlex, Tailwind e Stimulus.

O foco e:

- manter comportamento funcional
- reduzir HTML ERB repetido
- migrar por partes, sem rewrite global
- usar componentes RubyUI oficiais sempre que fizer sentido
- usar o Impeccable como criterio de refinamento visual e ergonomia de interface

## Quando usar este processo

Use este fluxo quando a tarefa for:

- migrar uma tela ERB para RubyUI
- padronizar formularios, cards, tabelas, tabs ou alerts
- extrair blocos visuais para componentes Phlex
- validar qual componente RubyUI usar antes de codar
- criar ou evoluir componentes RubyUI com apoio do `impeccable.style`

Nao use este fluxo inteiro quando a mudanca for:

- correcao textual pequena
- ajuste isolado de classe CSS
- bug de backend sem impacto visual

## Pre-requisitos do projeto

Antes de migrar telas, confirme que a base RubyUI esta ativa:

- `ruby_ui` no `Gemfile`
- `phlex-rails` no `Gemfile`
- `tailwind_merge` no `Gemfile`
- `tailwindcss-rails` no `Gemfile`
- [config/initializers/phlex.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/phlex.rb:1)
- [config/initializers/ruby_ui.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/ruby_ui.rb:1)
- [app/components/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/base.rb:1)
- [app/components/ruby_ui/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/ruby_ui/base.rb:1)
- [app/assets/tailwind/application.css](/home/marcodotcastro/RubymineProjects/smart_ponto/app/assets/tailwind/application.css:1)
- layouts usando `stylesheet_link_tag "tailwind"`

## Regra principal

Migrar tela em 3 niveis:

1. `foundation`
2. `screen primitives`
3. `screen composition`

E aplicar um quarto filtro continuo:

4. `impeccable refinement`

Traducao pratica:

1. garantir base Phlex/RubyUI/Tailwind
2. instalar os componentes oficiais necessarios
3. reescrever a tela usando esses componentes, sem alterar a regra de negocio
4. refinar hierarquia visual, espacamento, contraste, densidade e consistencia usando a mentalidade do Impeccable

## Fluxo padrao por tela

### Etapa 1 - Ler a tela real

Antes de tocar no codigo:

1. abrir a view atual
2. abrir o layout usado por ela
3. identificar:
   - formulario
   - cards
   - tabs
   - tabelas
   - badges
   - alerts
   - links e acoes
4. verificar se existem controllers Stimulus acoplados ao markup

Checklist rapido:

- qual layout a tela usa?
- a view depende de `form_for` ou `form_with`?
- existe `data-controller` acoplado ao HTML atual?
- a pagina tem estados condicionais importantes?
- existe lista/tabela/empty state?

### Etapa 2 - Mapear a tela para componentes RubyUI

Mapeie a view atual para primitives.

Mapa mais comum:

- botao -> `Button`
- container visual -> `Card`
- campo de texto -> `Input`
- checkbox -> `Checkbox`
- select -> `Select` ou `Native Select`
- hint/erro de formulario -> `FormFieldHint` e `FormFieldError`
- aviso -> `Alert`
- tabs -> `Tabs`
- tabela -> `Table`
- modal -> `Dialog`
- menu lateral -> `Sidebar` ou `Sheet`
- estado vazio -> composicao local usando `Card`, `Button`, `Typography`

Regra:

- primeiro preferir componente oficial RubyUI
- se nao existir encaixe bom, criar componente composto local em `app/components`
- ao criar componente composto local, usar o Impeccable para decidir:
  - hierarquia visual
  - densidade
  - espacamento
  - semantica visual
  - estados interativos

### Etapa 3 - Usar o MCP do RubyUI quando houver duvida

Arquivo local ja preparado:

- [.vscode/mcp.json](/home/marcodotcastro/RubymineProjects/smart_ponto/.vscode/mcp.json:1)

Servidor MCP:

- `https://rubyui.com/mcp`

Use MCP principalmente quando:

- nao estiver claro qual componente atende a tela
- precisar ver exemplos reais antes de instalar
- quiser instalar com o comando oficial correto
- precisar inspecionar dependencias do componente

Fluxo recomendado de MCP:

1. `get_project_registries`
2. `search_items_in_registries`
3. `view_items_in_registries`
4. `get_item_examples_from_registries`
5. `get_add_command_for_items`
6. `get_audit_checklist`

Prompts uteis para o MCP:

- `Search Ruby UI for login form components`
- `Show me examples of Card and Input`
- `Install Button, Card, Form and Input from Ruby UI`
- `Search Ruby UI for table with filters`
- `Audit my Ruby UI install`

Quando usar MCP e obrigatorio:

- `Tabs`
- `Table`
- `Dialog`
- `Sidebar`
- `Calendar`
- `Date Picker`

Porque nesses casos a chance de dependencia extra ou estrutura errada e maior.

### Etapa 3.1 - Usar o Impeccable como camada de design

Depois de descobrir os componentes corretos no RubyUI, usar o `https://impeccable.style` como referencia de execucao visual.

Objetivo pratico:

- nao apenas "trocar classes"
- melhorar a tela
- criar composicoes mais claras, densas e consistentes
- evitar UI genérica ou visualmente desorganizada

Perguntas que o agente deve responder ao usar Impeccable:

- a hierarquia visual da tela esta clara?
- os componentes RubyUI escolhidos sao suficientes ou falta um componente composto local?
- o espacamento esta consistente?
- o contraste e o foco visual estao adequados?
- a pagina parece um conjunto de blocos soltos ou um fluxo unico?

Regra:

- RubyUI define as primitives e a estrutura base
- Impeccable guia como organizar, polir e evoluir os componentes

### Etapa 4 - Instalar apenas os componentes necessarios

Evite instalar tudo.

Instale so o que a tela precisa.

Exemplos:

```bash
rtk bundle exec rails g ruby_ui:component Button
rtk bundle exec rails g ruby_ui:component Card
rtk bundle exec rails g ruby_ui:component Input
rtk bundle exec rails g ruby_ui:component Form
rtk bundle exec rails g ruby_ui:component Alert
```

Para cada tela, crie uma lista minima de componentes.

Exemplo para login:

- `Card`
- `Input`
- `Checkbox`
- `Button`
- `Form`

Exemplo para tabela administrativa:

- `Card`
- `Button`
- `Input`
- `Select`
- `Table`
- `Badge`

### Etapa 5 - Reescrever primeiro a estrutura visual

Ao migrar a view:

1. manter a mesma rota
2. manter os mesmos nomes de campos
3. manter os mesmos submits
4. manter os mesmos links
5. trocar primeiro o markup visual
6. so depois ajustar detalhes de comportamento

Prioridade:

- preservar backend
- preservar parametros do formulario
- preservar estados condicionais
- reduzir classes repetidas

Regra importante:

- nao reimplementar controller, model ou helper sem necessidade

### Etapa 6 - Lidar com formulários

Ao migrar formularios Devise ou CRUD:

1. manter `form_for` ou `form_with` existente
2. manter `name`, `id`, `value`, `autocomplete`, `required`
3. envolver campos com `RubyUI::FormField`
4. usar `RubyUI::FormFieldLabel` nos labels
5. usar `RubyUI::Input`, `Checkbox`, `Textarea`, `Select`

Exemplo de estrategia:

- manter helper Rails para submit e binding
- trocar somente a camada visual do campo

Sinais de quebra comum:

- checkbox sem `value: "1"`
- perda de `autocomplete`
- id/for nao batendo
- submit trocado por botao visual sem `type: :submit`

### Etapa 7 - Lidar com states complexos

Quando a tela tem muitos `if/else`:

1. nao converter tudo de uma vez
2. dividir em blocos
3. extrair blocos repetidos para componentes locais

Componentes locais comuns:

- `StatusBadge`
- `FilterBar`
- `EmptyStateCard`
- `MetricCard`
- `FormSection`

Regra:

- se o bloco usa 2 a 4 primitives RubyUI juntas e reaparece, extrair

### Etapa 8 - Revisar Stimulus

Se a tela usa Stimulus legado:

1. identificar se o componente RubyUI ja cobre esse comportamento
2. se sim, remover acoplamento antigo
3. se nao, manter controller atual enquanto a view muda

Nao mexer sem necessidade em:

- controllers que controlam fetch/preview
- logica de tabs customa se a migracao de `Tabs` nao foi feita ainda
- automacoes de exportacao

Exemplos do projeto que exigem cuidado:

- [app/javascript/controllers/tabs_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/tabs_controller.js:1)
- [app/javascript/controllers/export_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/export_controller.js:1)
- [app/javascript/controllers/flash_controller.js](/home/marcodotcastro/RubymineProjects/smart_ponto/app/javascript/controllers/flash_controller.js:1)

## Processo detalhado de execucao

### Passo 0 - Sanidade inicial

Rodar:

```bash
rtk git status --short
rtk bundle exec rails runner 'puts :boot_ok'
```

Se o app nao bootar, nao migrar tela ainda.

### Passo 1 - Ler a tela alvo

Rodar:

```bash
rtk sed -n '1,260p' app/views/devise/sessions/new.html.erb
rtk sed -n '1,160p' app/views/layouts/devise.html.erb
```

Substitua os caminhos conforme a tela.

### Passo 2 - Descobrir os componentes

Se ja souber:

- instalar diretamente

Se nao souber:

- usar MCP RubyUI

### Passo 3 - Gerar os componentes

Rodar somente o necessario:

```bash
rtk bundle exec rails g ruby_ui:component Button
rtk bundle exec rails g ruby_ui:component Card
rtk bundle exec rails g ruby_ui:component Input
rtk bundle exec rails g ruby_ui:component Form
```

### Passo 4 - Reescrever a view

Trocar a view por etapas:

1. container
2. header da tela
3. campos
4. acoes
5. links secundarios
6. alerts/flash

Depois disso, aplicar um passe de refinamento com lente Impeccable:

1. simplificar excesso visual
2. alinhar pesos e tamanhos
3. revisar densidade da interface
4. reforcar CTA principal
5. revisar estados vazios, secundarios e links auxiliares

### Passo 5 - Compilar e validar

Rodar:

```bash
rtk bundle exec rails tailwindcss:build
rtk bundle exec rails runner 'puts :boot_ok'
```

Opcional:

```bash
rtk ruby -c app/components/base.rb app/components/ruby_ui/base.rb
```

## Heuristica de escolha da proxima tela

Ordem recomendada:

1. tela pequena com formulario simples
2. shell/layout da area relacionada
3. telas irmas com o mesmo padrao
4. telas com tabs/tabelas
5. dashboards
6. calendario

Para este projeto, a ordem segura e:

1. `devise/sessions/new`
2. `layouts/devise`
3. `devise/registrations/new`
4. `devise/passwords/new`
5. `time_entries/new`
6. `approvals/index`
7. `dashboard/index`
8. `time_sheets/calendar`

## Boas praticas

- instalar componentes sob demanda
- manter nomes e parametros originais dos campos
- validar o boot apos cada lote pequeno
- preferir migracao parcial a troca total de tela densa
- extrair componentes locais so depois de enxergar repeticao real
- usar o MCP para evitar instalar componente errado
- usar o Impeccable para refinar a composicao final, nao para ignorar a base tecnica do RubyUI
- criar componentes compostos locais quando a primitive RubyUI pura nao resolver bem a UX

## Antipadroes

- migrar layout, comportamento e regra de negocio no mesmo passo
- trocar `form_for` por estrutura manual sem necessidade
- instalar dezenas de componentes antes de saber se a tela precisa
- remover Stimulus legado cedo demais
- converter dashboard/calendario antes de validar o processo numa tela pequena

## Template de execucao por tela

Use este roteiro curto:

1. Ler a view e o layout.
2. Identificar primitives da tela.
3. Consultar MCP se houver duvida.
4. Instalar componentes RubyUI necessarios.
5. Reescrever apenas a camada visual.
6. Preservar backend e parametros do formulario.
7. Compilar Tailwind.
8. Validar boot do app.
9. Revisar diff e so entao partir para a proxima tela.

## Exemplo real ja validado

Tela migrada com esse processo:

- [app/views/devise/sessions/new.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/sessions/new.html.erb:1)

Base criada para suportar a migracao:

- [app/assets/tailwind/application.css](/home/marcodotcastro/RubymineProjects/smart_ponto/app/assets/tailwind/application.css:1)
- [config/initializers/phlex.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/phlex.rb:1)
- [config/initializers/ruby_ui.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/ruby_ui.rb:1)
- [app/components/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/base.rb:1)
- [app/components/ruby_ui/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/ruby_ui/base.rb:1)

## Proximo uso deste documento

Este arquivo ja esta estruturado para virar base de um skill de agentes.

Quando formos transformar em skill, a divisao natural e:

- ativacao:
  - sanity check
  - leitura da tela
- descoberta:
  - mapeamento de componentes
  - uso de MCP
- design:
  - refinamento com `impeccable.style`
- execucao:
  - geracao dos componentes
  - migracao da view
- verificacao:
  - build
  - boot
  - diff review
