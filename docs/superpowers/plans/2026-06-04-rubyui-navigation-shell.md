# RubyUI Navigation Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers-ruby:subagent-driven-development (recommended) or superpowers-ruby:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrar o shell autenticado para RubyUI/Phlex, corrigindo a hierarquia do menu e movendo o comportamento de sidebar para Stimulus.

**Architecture:** O layout principal continua sendo o ponto de entrada do shell autenticado, mas passa a delegar a renderizacao do menu a um componente Phlex proprio. A navegacao nasce de uma definicao unica em Ruby, e o `sidebar_controller.js` passa a controlar drawer mobile e colapso desktop sem JavaScript inline.

**Tech Stack:** Rails 8, ERB, Phlex, RubyUI, Tailwind CSS, Stimulus, RSpec request specs.

---

### Task 1: Habilitar a base de testes para o shell autenticado

**Files:**
- Create: `spec/rails_helper.rb`
- Create: `spec/spec_helper.rb`
- Create: `.rspec`
- Modify: `spec/factories/users.rb`
- Test: `spec/requests/navigation_shell_spec.rb`

- [ ] **Step 1: Escrever o request spec em vermelho**

```ruby
require "rails_helper"

RSpec.describe "Navigation shell", type: :request do
  it "renders the global menu for a collaborator" do
    user = create(:user, role: "colaborador")
    sign_in user

    get dashboard_index_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Meu ponto")
    expect(response.body).not_to include("Calendário")
  end
end
```

- [ ] **Step 2: Rodar o spec e confirmar falha**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: FAIL carregando `rails_helper` ausente ou falha equivalente de infraestrutura.

- [ ] **Step 3: Adicionar a infraestrutura mínima de RSpec e a factory de usuário**

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "colaborador" }
  end
end
```

- [ ] **Step 4: Rodar o spec novamente**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: FAIL agora por comportamento/layout ainda antigo, nao por falta de infraestrutura.

- [ ] **Step 5: Commit**

```bash
git add .rspec spec/spec_helper.rb spec/rails_helper.rb spec/factories/users.rb spec/requests/navigation_shell_spec.rb
git commit -m "test: bootstrap navigation shell request specs"
```

### Task 2: Extrair a navegacao autenticada para componente Phlex

**Files:**
- Create: `app/components/navigation/shell_component.rb`
- Modify: `app/components/base.rb`
- Modify: `app/views/layouts/application.html.erb`
- Test: `spec/requests/navigation_shell_spec.rb`

- [ ] **Step 1: Expandir o spec com regras reais de menu**

```ruby
it "shows management links only for managers" do
  manager = create(:user, role: "gestor")
  sign_in manager

  get dashboard_index_path

  expect(response.body).to include("Aprovações")
  expect(response.body).to include("Gestão da equipe")
end
```

- [ ] **Step 2: Rodar o spec e confirmar falha**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: FAIL porque o menu ainda contem itens antigos e nao usa a nova composicao.

- [ ] **Step 3: Criar o componente Phlex do shell**

```ruby
class Navigation::ShellComponent < Components::Base
  Item = Data.define(:label, :path, :icon, :group, :visible, :active)

  def initialize(view_context:)
    @view_context = view_context
  end
end
```

- [ ] **Step 4: Fazer o layout renderizar o componente no lugar do menu duplicado**

```erb
<%= render Navigation::ShellComponent.new(view_context: self) %>
```

- [ ] **Step 5: Rodar o spec para validar a extracao**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: PASS para colaborador e gestor, sem `Calendário` e `Exportar` como itens globais.

- [ ] **Step 6: Commit**

```bash
git add app/components/base.rb app/components/navigation/shell_component.rb app/views/layouts/application.html.erb spec/requests/navigation_shell_spec.rb
git commit -m "feat: extract authenticated navigation shell"
```

### Task 3: Migrar o comportamento do menu para Stimulus

**Files:**
- Modify: `app/javascript/controllers/sidebar_controller.js`
- Modify: `app/views/layouts/application.html.erb`
- Test: `spec/requests/navigation_shell_spec.rb`

- [ ] **Step 1: Escrever a expectativa de remoção do script inline**

```ruby
it "does not embed sidebar control scripts in the layout" do
  user = create(:user)
  sign_in user

  get dashboard_index_path

  expect(response.body).not_to include("toggleDesktopSidebar")
  expect(response.body).not_to include("document.addEventListener('turbo:load'")
end
```

- [ ] **Step 2: Rodar o spec e confirmar falha**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: FAIL porque o layout ainda contem o script inline.

- [ ] **Step 3: Implementar o controller Stimulus com targets e actions**

```javascript
export default class extends Controller {
  static targets = ["desktopSidebar", "mobileMenu", "backdrop", "panel"]

  connect() {
    this.restoreDesktopState()
  }
}
```

- [ ] **Step 4: Remover o script inline do layout e ligar os data attributes**

```erb
<div data-controller="sidebar">
  <button data-action="sidebar#toggleDesktop"></button>
</div>
```

- [ ] **Step 5: Rodar o spec**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: PASS, sem JavaScript inline no HTML.

- [ ] **Step 6: Commit**

```bash
git add app/javascript/controllers/sidebar_controller.js app/views/layouts/application.html.erb spec/requests/navigation_shell_spec.rb
git commit -m "feat: move sidebar behavior to stimulus"
```

### Task 4: Verificacao final

**Files:**
- Modify: `spec/requests/navigation_shell_spec.rb`

- [ ] **Step 1: Rodar a suite focada**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb`
Expected: PASS

- [ ] **Step 2: Rodar os specs relacionados ao shell**

Run: `bundle exec rspec spec/requests/navigation_shell_spec.rb spec/requests/home_spec.rb`
Expected: PASS ou, se `home_spec.rb` estiver obsoleto, substituir por outro spec valido da navegacao.

- [ ] **Step 3: Revisar diff final**

Run: `git diff --stat`
Expected: mostra componente, layout, controller e specs alterados.

- [ ] **Step 4: Commit final da feature**

```bash
git add app/components/navigation/shell_component.rb app/views/layouts/application.html.erb app/javascript/controllers/sidebar_controller.js spec/requests/navigation_shell_spec.rb spec/factories/users.rb spec/rails_helper.rb spec/spec_helper.rb .rspec
git commit -m "feat: migrate navigation shell to RubyUI"
```
