---
name: Smart Ponto
description: Sistema de ponto institucional, agil e humano para registro, aprovacao e auditoria.
colors:
  indigo-primary: "#6055F6"
  indigo-primary-foreground: "#F9F8FF"
  surface-background: "#F8F8FC"
  surface-card: "#FFFFFF"
  text-foreground: "#302D4A"
  text-muted: "#756C93"
  surface-secondary: "#EDEAF9"
  surface-accent: "#EAE5FA"
  border-soft: "#DDD8EC"
  ring-focus: "#7A6AF7"
  destructive: "#D95062"
  warning: "#F5A623"
  success: "#5FB300"
typography:
  display:
    fontFamily: "-apple-system, BlinkMacSystemFont, \"Segoe UI\", system-ui, sans-serif"
    fontSize: "2rem"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "-apple-system, BlinkMacSystemFont, \"Segoe UI\", system-ui, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.01em"
  title:
    fontFamily: "-apple-system, BlinkMacSystemFont, \"Segoe UI\", system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 600
    lineHeight: 1.35
    letterSpacing: "-0.01em"
  body:
    fontFamily: "-apple-system, BlinkMacSystemFont, \"Segoe UI\", system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "normal"
  label:
    fontFamily: "-apple-system, BlinkMacSystemFont, \"Segoe UI\", system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: "normal"
rounded:
  sm: "6px"
  md: "8px"
  lg: "10px"
  xl: "14px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.indigo-primary}"
    textColor: "{colors.indigo-primary-foreground}"
    rounded: "{rounded.md}"
    padding: "0 16px"
    height: "36px"
  button-primary-hover:
    backgroundColor: "{colors.indigo-primary}"
    textColor: "{colors.indigo-primary-foreground}"
    rounded: "{rounded.md}"
    padding: "0 16px"
    height: "36px"
  card-default:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.text-foreground}"
    rounded: "{rounded.xl}"
    padding: "24px"
  input-default:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.text-foreground}"
    rounded: "{rounded.md}"
    padding: "0 12px"
    height: "36px"
  alert-destructive:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.destructive}"
    rounded: "{rounded.lg}"
    padding: "16px"
---

# Design System: Smart Ponto

## 1. Overview

**Creative North Star: "Painel Institucional Agil"**

O Smart Ponto deve parecer um sistema corporativo confiavel, mas nunca pesado ou hostil. A referencia nao e um ERP duro nem uma ferramenta fria de backoffice, e sim um painel institucional claro, fluido e acolhedor, onde cada tela ajuda o usuario a concluir uma tarefa sem precisar decifrar a interface. A sensacao precisa ser de ordem, transparencia e ritmo operacional.

Visualmente, isso se traduz em superfícies claras, contrastes limpos, acento indigo consistente e componentes com peso leve. O sistema precisa parecer organizado e serio o suficiente para aprovacoes e auditorias, mas humano o suficiente para o colaborador usar todos os dias sem desgaste cognitivo. A linguagem visual serve a tarefa e reduz atrito, em vez de disputar atencao com ela.

O sistema rejeita explicitamente qualquer direcao burocratica, com cara de sistema legado ou generica de ERP. Tambem rejeita densidade sem hierarquia, excesso de caixas concorrendo entre si e qualquer visual que pareca exigir treinamento previo para tarefas simples.

**Key Characteristics:**

- institucional sem ser frio
- claro antes de sofisticado
- humano e acessivel
- leve nos componentes, firme nas acoes
- previsivel para pessoas menos fluentes digitalmente

## 2. Colors

A paleta e um indigo institucional suavizado por neutros frios e luminosos, com intencao acolhedora em vez de corporativa rigida.

### Primary
- **Indigo de Confianca** (`#6055F6`): cor de acao principal, foco, selecao e pontos de orientacao visual. Deve aparecer em CTAs, links ativos, foco e iconografia de destaque.

### Secondary
- **Neblina Indigo** (`#EDEAF9`): superficie secundaria para agrupamentos leves, estados suaves e areas de apoio sem competir com o conteudo principal.

### Tertiary
- **Lavanda Operacional** (`#EAE5FA`): acento de apoio para hover, fundos discretos e reforcos de navegacao, especialmente quando for necessario destacar sem usar o primario pleno.

### Neutral
- **Branco Administrativo** (`#FFFFFF`): superficies de card, campos e overlays principais.
- **Cinza Papel Frio** (`#F8F8FC`): fundo global e base de leitura calma.
- **Ameixa de Leitura** (`#302D4A`): texto principal, titulos e elementos de maior autoridade.
- **Ameixa Suave** (`#756C93`): texto auxiliar, descricoes e links secundários.
- **Borda Institucional Suave** (`#DDD8EC`): divisores, bordas de input e separacoes sutis.

### Named Rules
**The Friendly Institution Rule.** O indigo primario lidera a interface, mas sempre apoiado por fundos claros e neutros suaves. O sistema nunca deve parecer escuro, pesado ou saturado demais.

## 3. Typography

**Display Font:** `-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif`
**Body Font:** `-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif`
**Label/Mono Font:** o mesmo stack do sistema

**Character:** tipografia de sistema, direta e confiavel. A escolha prioriza familiaridade, leitura e velocidade de entendimento em uma superficie de produto operacional.

### Hierarchy
- **Display** (600, `2rem`, 1.2): usado em titulos principais de telas de autenticacao e pontos de entrada de fluxo.
- **Headline** (600, `1.5rem`, 1.25): usado em cabecalhos de pagina, secoes relevantes e agrupamentos mais importantes.
- **Title** (600, `1rem`, 1.35): usado em titulos de cards, blocos e grupos de formulario.
- **Body** (400, `0.875rem`, 1.5): usado em formularios, textos auxiliares, listas e fluxo geral de leitura.
- **Label** (500, `0.875rem`, 1.4): usado em labels de campos, links secundarios e acoes menores.

### Named Rules
**The Immediate Reading Rule.** Todo texto funcional deve ser entendivel no primeiro olhar. Nunca usar contraste baixo, pesos frágeis demais ou hierarquia exagerada que complique a leitura operacional.

## 4. Elevation

O sistema usa elevacao leve, com sombras suaves e difusas para separar superficies importantes do fundo sem criar dramatizacao visual. Profundidade aqui serve a legibilidade e a organizacao, nao a decoracao. Quando possivel, a hierarquia deve vir primeiro de espacamento, borda e cor, com sombra como reforco.

### Shadow Vocabulary
- **Card Lift** (`0 4px 12px rgba(0, 0, 0, 0.08)`): usado em cards principais, containers de formulario e blocos de destaque.
- **Shell Lift** (`0 12px 32px rgba(48, 45, 74, 0.12)`): usado em painéis centrais de autenticacao e momentos mais concentrados de fluxo.
- **Soft Hover** (`0 2px 8px rgba(96, 85, 246, 0.12)`): usado em micro realces de hover quando a interacao precisa parecer ativa, mas calma.

### Named Rules
**The Calm Depth Rule.** Nenhuma sombra deve fazer o sistema parecer pesado, vidrado ou decorativo. Profundidade deve parecer funcional e leve.

## 5. Components

### Buttons
- **Shape:** cantos medios, arredondamento consistente (`8px`).
- **Primary:** fundo indigo primario, texto claro, altura compacta (`36px`) e largura expandida quando a acao for dominante.
- **Hover / Focus:** hover com leve reducao de opacidade e focus ring indigo visivel, sem glow agressivo.
- **Secondary / Ghost / Tertiary:** usam fundos claros ou transparentes, sempre mantendo leitura clara e affordance previsivel.

### Cards / Containers
- **Corner Style:** arredondamento generoso, mas controlado (`14px` nos containers principais).
- **Background:** branco principal sobre fundo cinza frio.
- **Shadow Strategy:** sombra leve e difusa para separar do fundo.
- **Border:** borda sutil com `border-soft` quando a superficie precisar de contencao adicional.
- **Internal Padding:** `24px` como base para formularios, shells de autenticacao e blocos institucionais.

### Inputs / Fields
- **Style:** fundos brancos, borda suave, raio medio (`8px`) e altura previsivel (`36px`).
- **Focus:** ring indigo claro e borda reforcada, com resposta nitida mas amigavel.
- **Error / Disabled:** erro com destrutivo controlado e disabled com opacidade reduzida, nunca com contraste tão baixo que comprometa entendimento.

### Alerts
- **Style:** fundo claro, ring sutil, icone simples e espacamento interno confortável.
- **States:** sucesso e erro devem ser imediatos de entender, mas sem parecer alarmistas. O sistema informa, nao assusta.

### Navigation
- **Style:** navegacao deve parecer institucional e clara, com estado ativo visivel, contraste suficiente e agrupamento previsivel.
- **Behavior:** o item ativo deve ser encontrado rapidamente por cor, fundo e micro contraste, sem depender apenas de icone.

### Auth Shell
- **Character:** centro de fluxo limpo, acolhedor e focado na tarefa.
- **Composition:** card central com header simples, icone circular, titulo direto e formulario em pilha unica.
- **Purpose:** reduzir ansiedade de entrada e tornar autenticacao e recuperacao de senha tarefas obvias.

## 6. Do's and Don'ts

### Do:
- **Do** usar o indigo como ancora institucional principal, sempre apoiado por fundos claros e neutros suaves.
- **Do** manter labels explicitos, textos objetivos e fluxo de leitura linear.
- **Do** usar arredondamento medio e sombras leves para tornar o sistema mais humano e menos rigido.
- **Do** destacar CTA principal com clareza, especialmente em formularios e fluxos de aprovacao.
- **Do** favorecer entendimento imediato para usuarios menos fluentes digitalmente.

### Don't:
- **Don't** deixar a interface parecer burocratica.
- **Don't** deixar a interface com cara de sistema legado.
- **Don't** deixar a interface generica de ERP.
- **Don't** empilhar cards, caixas e bordas sem uma hierarquia visual clara.
- **Don't** usar contrastes fracos, labels ambíguos ou estruturas que exijam “aprender o sistema” para executar tarefas simples.
