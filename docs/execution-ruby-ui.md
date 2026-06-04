# Execution Guide: RubyUI + Impeccable

## Objetivo

Este arquivo documenta o processo padrao para migrar qualquer tela do `smart_ponto` para RubyUI com risco controlado, reaproveitando a base atual do projeto e usando o MCP do RubyUI quando isso reduzir tentativa e erro.

O objetivo da skill e combinar:

- `https://rubyui.com/`
- `https://impeccable.style`

para criar, atualizar e refinar componentes RubyUI com qualidade visual mais alta, sem perder consistencia tecnica com Rails, Phlex, Tailwind e Stimulus.

O foco e:

- manter comportamento funcional
- reduzir HTML ERB repetido
- migrar por partes, sem rewrite global
- usar componentes RubyUI oficiais sempre que fizer sentido
- usar o Impeccable como criterio de refinamento visual e ergonomia de interface

O processo abaixo ja foi validado neste projeto na migracao de:

- autenticacao Devise
- `time_entries/new`
- `approvals/index`
- `manager/team_members/index`
- `time_sheets/index`
- `time_sheets/calendar`
- `dashboard/index`
- `user_preferences/edit`
- `time_sheets/export`

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
- componentes RubyUI gerados em `app/components/ruby_ui`
- controllers RubyUI em `app/javascript/controllers/ruby_ui`
- MCP configurado em [.vscode/mcp.json](/home/marcodotcastro/RubymineProjects/smart_ponto/.vscode/mcp.json:1)

Contexto visual do Impeccable ja definido no projeto:

- [PRODUCT.md](/home/marcodotcastro/RubymineProjects/smart_ponto/PRODUCT.md:1)
- [DESIGN.md](/home/marcodotcastro/RubymineProjects/smart_ponto/DESIGN.md:1)
- [.impeccable/design.json](/home/marcodotcastro/RubymineProjects/smart_ponto/.impeccable/design.json:1)

Direcao visual vigente:

- north star: `painel institucional agil`
- personalidade: `clara, confiavel, humana`
- efeito: `agilidade e transparencia`
- anti-referencias: `burocratica`, `sistema legado`, `ERP generico`
- componente: `leve e amigavel`

Observacao pratica:

- o projeto usa Tailwind local
- o Tailwind CDN foi removido dos layouts
- a dependencia `tw-animate-css` foi resolvida via `@import` no CSS, porque o pin via importmap falhou no setup inicial

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

## Aprendizados validados no projeto

### 1. A melhor ordem de migracao nao e por importancia de negocio

A ordem que mais funcionou foi:

1. telas simples de autenticacao
2. tela isolada de formulario real
3. listas operacionais medias
4. calendario
5. dashboard por recorte

Motivo:

- reduz risco tecnico
- valida setup RubyUI em casos reais antes das telas mais densas
- evita começar por shell ou dashboard cedo demais

Sequencia real que funcionou:

- `devise/sessions/new`
- lote Devise restante
- `time_entries/new`
- `approvals/index`
- `manager/team_members/index`
- `time_sheets/index`
- `time_sheets/calendar`
- `dashboard/index`
- `user_preferences/edit`
- `time_sheets/export`

### 2. Migrar tela nao e trocar classes

O padrao que mais evitou retrabalho foi:

1. preservar comportamento
2. reorganizar hierarquia visual
3. reduzir repeticao
4. comprimir estados resolvidos
5. destacar estados com atencao

Quando a migracao foi tratada como simples troca de classes, o resultado ficou:

- mais pesado do que deveria
- com excesso de texto
- com cards grandes demais
- com pouca diferenca entre estados importantes

### 3. Mobile precisa ser tratado como composicao propria

Aprendizado forte do projeto:

- algumas telas nao devem apenas "encolher"
- elas precisam de outra composicao no mobile

Casos reais:

- `manager/team_members/index`: trocar tabela por lista em cards
- `time_sheets/calendar`: trocar grade do calendario por lista diaria no mobile
- `time_sheets/export`: trocar tabela crua por lista responsiva com rolagem controlada

Regra pratica:

- se o desktop depende de grade densa, tabela ou calendario, considerar uma estrutura propria para mobile
- nao insistir em manter o mesmo layout so com `grid-cols` responsivo

### 4. Estados resolvidos devem ser menores que estados com atencao

Esse foi um dos aprendizados mais consistentes.

Em listas operacionais:

- itens resolvidos devem ficar mais compactos
- itens com pendencia devem ganhar mais area, contraste e explicacao

Aplicado com sucesso em:

- `time_sheets/index`
- `approvals/index`

Regra:

- nunca dar o mesmo peso visual para `ok`, `aguardando`, `pendente` e `problema`

### 5. A primeira implementacao quase sempre fica explicativa demais

Padrao repetido no projeto:

- primeira versao tende a colocar contexto demais
- depois a critica do Impeccable aponta excesso de blocos e texto

Correcao que funcionou:

- remover colunas laterais desnecessarias
- trocar explicacao repetida por uma unica regra contextual
- reduzir blocos auxiliares
- concentrar a tensao visual no formulario ou na decisao principal

### 6. O Impeccable foi mais util para densidade e hierarquia do que para “embelezar”

Uso real mais valioso:

- reduzir espaco morto
- diferenciar estados
- tirar cara de ERP
- aproximar acao da informacao
- eliminar repeticao estrutural

Nao usar Impeccable so para:

- inventar layout novo sem necessidade
- adicionar decoracao
- deixar a tela mais chamativa sem melhorar o fluxo

### 7. Paginacao precisa ser resolvida na origem

Aprendizado importante:

- nao corrigir UI de paginacao tela por tela
- personalizar os partials do Kaminari em `app/views/kaminari`

Beneficio:

- melhora global
- consistencia visual
- menos duplicacao

Regra:

- quando o problema e componente compartilhado, corrigir na origem do sistema, nao localmente na tela

### 8. MCP do RubyUI nao foi o gargalo principal nas telas medias

No projeto, o MCP foi mais valioso em:

- setup inicial
- consulta de primitives estruturais
- casos com maior chance de dependencia indireta

Nas telas medias ja validadas, o gargalo principal passou a ser:

- composicao
- densidade
- mobile
- hierarquia visual

Entao:

- usar MCP quando houver duvida real de primitive
- nao transformar o MCP em etapa burocratica para telas que ja repetem stack conhecida

### 9. Bugs funcionais aparecem durante a migracao visual

Durante a migracao surgiram bugs reais que nao eram apenas visuais:

- redirect usando `root_path` inexistente
- tabs com estado ativo quebrado
- paginacao lendo params diferentes dos enviados
- CTA indevido em estado `enviado`
- render inicial de preview diferente do endpoint dinamico

Regra:

- tratar bug funcional encontrado no fluxo da tela como parte da entrega
- mas separar o commit se o ajuste merecer isolamento

### 10. Artefatos de review visual nao devem ir para commit

Durante a execucao foram gerados:

- screenshots
- snapshots markdown
- arquivos de critica local

Regra final:

- antes de commitar, limpar artefatos temporarios
- manter no commit apenas codigo, docs e contexto que realmente fazem parte do produto

### 11. Dashboard grande deve ser tratado como triagem

Aprendizado do `dashboard/index`:

- a primeira migracao tende a ficar correta, mas alta demais
- blocos vazios disputam espaco com estados reais
- cards de resumo podem parecer vitrine em vez de painel de decisao

Correcao que funcionou:

- comprimir hero
- reduzir o peso de estados vazios
- aproximar historico recente da area util
- tratar a tela como painel de decisao de 30 segundos

Regra:

- dashboard nao deve parecer pagina de showcase
- se o usuario rola demais antes de decidir algo, a composicao ainda esta frouxa

### 12. Nem toda tela com secoes precisa de tabs

Aprendizado do `user_preferences/edit`:

- tabs escondiam configuracoes simples
- a tela ficou melhor como formulario linear
- o ganho veio mais de previsibilidade do que de “navegacao”

Correcao que funcionou:

- remover tabs quebradas
- organizar por secoes lineares
- encurtar microcopy
- compactar opcoes pequenas, como tema e assinatura

Regra:

- se a tela cabe em um scroll razoavel, preferir secoes lineares
- tabs so valem quando reduzem carga cognitiva de verdade

### 13. Render inicial e fetch dinamico precisam usar a mesma consulta

Aprendizado do `time_sheets/export`:

- a view inicial mostrava mais dados do que a previa dinamica
- o Stimulus atualizava a lista com menos itens logo depois
- isso gera flicker e perda de confianca

Correcao que funcionou:

- extrair consulta compartilhada no controller
- usar a mesma logica em `export_form`, `export_preview` e `export`
- render inicial da view deve usar a mesma colecao do endpoint dinamico

Regra:

- sempre comparar dataset inicial vs dataset do fetch dinamico
- se houver divergencia, corrigir isso antes do polimento visual

### 14. Preview ajuda, mas nao deve dominar a tela

Aprendizado da exportacao:

- a previa e util para confianca
- mas nao pode competir com a acao principal

Correcao que funcionou:

- rebaixar contexto auxiliar
- resumir o recorte perto do CTA
- deixar a previa rolavel e responsiva
- tratar preview como confirmacao contextual, nao como protagonista

Regra:

- em telas de exportacao, a acao principal continua sendo exportar
- preview serve a decisao, nao lidera a pagina

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
- existe dataset inicial que depois e substituido por fetch/Stimulus?

Aprendizado adicional:

- abrir a rota real cedo economiza muito retrabalho
- em especial nas telas responsivas
- em telas com preview dinamico, observar o primeiro segundo da tela ajuda a achar divergencias de consulta

Sempre que possivel:

1. abrir a rota no browser
2. revisar desktop
3. revisar mobile
4. so depois editar

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

Heuristica validada no projeto:

- `Card`, `Button`, `Input`, `Alert` e helpers locais resolveram boa parte das telas
- nem todo bloco precisa virar componente Phlex novo
- em muitos casos, helper + ERB organizado foi suficiente

### Etapa 3 - Usar o MCP do RubyUI quando houver duvida ou dependencia estrutural

Arquivo local ja preparado:

- [.vscode/mcp.json](/home/marcodotcastro/RubymineProjects/smart_ponto/.vscode/mcp.json:1)

Servidor MCP:

- `https://rubyui.com/mcp`

Use MCP principalmente quando:

- nao estiver claro qual componente atende a tela
- precisar ver exemplos reais antes de instalar
- quiser instalar com o comando oficial correto
- precisar inspecionar dependencias do componente
- precisar confirmar se a primitive existe oficialmente antes de compor localmente

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

Quando nao precisa usar MCP:

- tela simples com stack ja validada no projeto
- evolucao visual de telas que ja usam `Card`, `Input`, `Button`, `Alert`, `Checkbox`
- refinamento de copy, densidade, hierarquia e shell

Aprendizado pratico:

- depois da base estar pronta, a maior parte do trabalho passa a ser layout e UX
- nao atrasar a migracao esperando consulta de MCP para elementos ja dominados no projeto

### Etapa 3.1 - Usar o Impeccable como camada de design e consistencia

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
- `PRODUCT.md` define o comportamento de marca do produto
- `DESIGN.md` define tokens, linguagem visual e criterio de composicao

Perguntas extras obrigatorias no contexto deste projeto:

- a tela parece institucional sem ficar fria?
- a composicao parece clara para pessoas menos fluentes digitalmente?
- o CTA principal esta obvio?
- a pagina comunica o proximo passo sem depender de interpretacao?

Checklist de critica que mais gerou melhoria real:

- os cards estao grandes demais?
- estados resolvidos ocupam espaco demais?
- a acao principal aparece tarde demais no mobile?
- a pagina esta explicando demais antes de deixar agir?
- desktop e mobile parecem duas experiencias coerentes entre si?

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

Aprendizado:

- em varias telas medias, instalar novos componentes nao foi o passo principal
- o ganho veio mais de helpers e composicao do que de novos componentes oficiais

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

### Passo 0.1 - Confirmar o contexto do Impeccable

Antes de refinar visualmente qualquer tela, confirme se estes arquivos existem:

- `PRODUCT.md`
- `DESIGN.md`
- `.impeccable/design.json`

Se nao existirem:

1. inicializar o fluxo do Impeccable
2. documentar produto
3. documentar design
4. voltar para a tela

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
- comparar a tela com `PRODUCT.md` e `DESIGN.md`

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
6. revisar shell, headline e texto de apoio
7. revisar se o fluxo parece um bloco unico e nao uma soma de cards soltos

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

Observacao:

- `erb` compilado fora do contexto do Rails nem sempre valida bem views com helpers/blocos do RubyUI
- neste projeto, o sinal confiavel foi `bundle exec rails runner 'puts :boot_ok'`

### Passo 6 - Revisar o diff e separar commits

Separar as entregas reduz risco e ajuda a reusar o processo depois.

Sequencia validada neste projeto:

1. commit de `foundation`
2. commit da primeira tela
3. commit do lote de telas irmas
4. commit de refinamento visual com Impeccable
5. commit de contexto de design do Impeccable

Modelo de cortes:

- `build`: setup RubyUI, Phlex, Tailwind local, initializers, MCP
- `feat`: migracao funcional da tela
- `feat`: refinamento visual do shell e das telas irmas
- `docs`: contexto de produto e design

## Heuristica de escolha da proxima tela

Ordem recomendada:

1. tela pequena com formulario simples
2. shell/layout da area relacionada
3. telas irmas com o mesmo padrao
4. telas com tabs/tabelas
5. dashboards
6. calendario

Para este projeto, a ordem segura validada ficou assim:

1. `devise/sessions/new`
2. `devise/registrations/new`
3. `devise/passwords/new`
4. `devise/passwords/edit`
5. `layouts/devise`
6. `devise/shared/_error_messages`
7. `devise/shared/_links`
8. `shared/_flash`
9. `time_entries/new`
10. `approvals/index`
11. `dashboard/index`
12. `time_sheets/calendar`

Motivo:

- primeiro validar primitives
- depois fechar telas irmas
- depois consolidar o shell compartilhado
- so entao partir para telas de negocio

## Boas praticas

- instalar componentes sob demanda
- manter nomes e parametros originais dos campos
- validar o boot apos cada lote pequeno
- preferir migracao parcial a troca total de tela densa
- extrair componentes locais so depois de enxergar repeticao real
- usar o MCP para evitar instalar componente errado
- usar o Impeccable para refinar a composicao final, nao para ignorar a base tecnica do RubyUI
- criar componentes compostos locais quando a primitive RubyUI pura nao resolver bem a UX
- separar setup, migracao funcional e refinamento visual em commits diferentes
- usar `PRODUCT.md` e `DESIGN.md` como criterio de consistencia, nao como documento ornamental

## Antipadroes

- migrar layout, comportamento e regra de negocio no mesmo passo
- trocar `form_for` por estrutura manual sem necessidade
- instalar dezenas de componentes antes de saber se a tela precisa
- remover Stimulus legado cedo demais
- converter dashboard/calendario antes de validar o processo numa tela pequena
- pular o shell compartilhado e refinar apenas views isoladas
- fazer polimento visual sem antes estabilizar a tela funcionalmente

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

Telas migradas com esse processo:

- [app/views/devise/sessions/new.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/sessions/new.html.erb:1)
- [app/views/devise/registrations/new.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/registrations/new.html.erb:1)
- [app/views/devise/passwords/new.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/passwords/new.html.erb:1)
- [app/views/devise/passwords/edit.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/passwords/edit.html.erb:1)

Shell e compartilhados refinados:

- [app/views/layouts/devise.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/layouts/devise.html.erb:1)
- [app/views/devise/shared/_error_messages.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/shared/_error_messages.html.erb:1)
- [app/views/devise/shared/_links.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/devise/shared/_links.html.erb:1)
- [app/views/shared/_flash.html.erb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/views/shared/_flash.html.erb:1)

Base criada para suportar a migracao:

- [app/assets/tailwind/application.css](/home/marcodotcastro/RubymineProjects/smart_ponto/app/assets/tailwind/application.css:1)
- [config/initializers/phlex.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/phlex.rb:1)
- [config/initializers/ruby_ui.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/config/initializers/ruby_ui.rb:1)
- [app/components/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/base.rb:1)
- [app/components/ruby_ui/base.rb](/home/marcodotcastro/RubymineProjects/smart_ponto/app/components/ruby_ui/base.rb:1)

Commits que materializaram o processo:

- `a0620ac build: setup RubyUI foundation`
- `c778909 feat: migrate login screen to RubyUI`
- `3c679a6 feat: migrate devise auth screens to RubyUI`
- `70de047 feat: refine devise screens with impeccable theme`
- `ffc9981 docs: add impeccable product and design context`

## Fluxo resumido ja validado

1. preparar a base RubyUI
2. migrar a menor tela com formulario simples
3. reaplicar o padrao nas telas irmas
4. consolidar layout e parciais compartilhados
5. documentar produto e design no Impeccable
6. refinar shell, hierarquia, copy e estados
7. so depois partir para telas de negocio

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
