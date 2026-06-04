# frozen_string_literal: true

module Components
  module Navigation
    class ShellComponent < Components::Base
    Item = Data.define(:label, :path, :icon, :group, :active)

    def initialize(current_user:, request_path:)
      @current_user = current_user
      @request_path = request_path
    end

    def view_template(&content)
      div(class: "flex h-screen overflow-hidden bg-background text-foreground", data: { controller: "sidebar" }) do
        desktop_sidebar
        mobile_sidebar

        div(class: "flex min-h-0 min-w-0 flex-1 flex-col") do
          mobile_header
          desktop_header

          main(class: "flex-1 overflow-y-auto px-4 py-5 sm:px-6 lg:px-8") do
            content.call if content
          end
        end
      end
    end

    private

    attr_reader :current_user, :request_path

    def desktop_sidebar
      aside(
        class: "hidden h-full border-r border-sidebar-border bg-sidebar text-sidebar-foreground md:flex md:w-72 md:flex-col",
        data: { sidebar_target: "desktopSidebar" }
      ) do
        sidebar_inner
      end
    end

    def mobile_sidebar
      div(
        class: "fixed inset-0 z-40 hidden md:hidden",
        data: { sidebar_target: "mobileMenu" },
        aria: { hidden: "true" }
      ) do
        button(
          type: "button",
          class: "absolute inset-0 bg-foreground/35 transition-opacity duration-200",
          data: { action: "sidebar#closeMobile", sidebar_target: "backdrop" },
          aria: { label: "Fechar menu" }
        )

        aside(
          class: "relative flex h-full w-[19rem] max-w-[86vw] -translate-x-full flex-col overflow-hidden border-r border-sidebar-border bg-sidebar text-sidebar-foreground shadow-[0_24px_60px_rgba(48,45,74,0.18)] transition-transform duration-200 ease-out",
          data: { sidebar_target: "mobilePanel" }
        ) do
          sidebar_inner(mobile: true)
        end
      end
    end

    def sidebar_inner(mobile: false)
      div(class: "flex h-full min-h-0 flex-col") do
        brand_block(mobile: mobile)

        div(class: "flex min-h-0 flex-1 flex-col px-3 py-4") do
          div(class: "min-h-0 flex-1 pr-1") do
            navigation_groups
          end

          user_panel
        end
      end
    end

    def brand_block(mobile: false)
      div(class: "flex items-center justify-between border-b border-sidebar-border px-4 py-4") do
        div(class: "flex items-center gap-3") do
          div(class: "flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/12 text-primary") do
            i(class: "fas fa-clock text-base")
          end

          div(class: "space-y-0.5") do
            p(class: "text-sm font-semibold tracking-tight text-sidebar-foreground") { "Smart Ponto" }
            p(class: "text-xs text-muted-foreground") { "Painel institucional ágil" }
          end
        end

        return unless mobile

        button(
          type: "button",
          class: "inline-flex h-9 w-9 items-center justify-center rounded-full text-muted-foreground transition hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          data: { action: "sidebar#closeMobile" },
          aria: { label: "Fechar menu" }
        ) do
          i(class: "fas fa-times text-sm")
        end
      end
    end

    def navigation_groups
      nav(class: "space-y-6", aria: { label: "Navegação principal" }) do
        grouped_items.each do |group, items|
          div(class: "space-y-1.5") do
            if group == :management
              p(class: "px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground") { "Gestão" }
            end

            items.each do |item|
              navigation_item(item)
            end
          end
        end
      end
    end

    def navigation_item(item)
      active = item.active.call(request_path)

      a(
        href: item.path,
        class: [
          "group flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium transition-colors",
          (active ? "bg-primary text-primary-foreground shadow-sm" : "text-sidebar-foreground hover:bg-accent hover:text-accent-foreground")
        ],
        aria: { current: ("page" if active) }
      ) do
        div(
          class: [
            "flex h-9 w-9 items-center justify-center rounded-xl transition-colors",
            (active ? "bg-white/15 text-primary-foreground" : "bg-secondary/70 text-secondary-foreground group-hover:bg-white")
          ]
        ) do
          i(class: "fas #{item.icon} text-sm")
        end

        span { item.label }

        if active
          span(class: "ml-auto text-[10px] font-semibold uppercase tracking-[0.16em] text-primary-foreground/80") { "Ativo" }
        end
      end
    end

    def user_panel
      render RubyUI::Card.new(class: "mt-6 border-sidebar-border bg-white/90 shadow-sm") do
        render RubyUI::CardContent.new(class: "space-y-4 p-4") do
          div(class: "flex items-center gap-3") do
            div(class: "flex h-11 w-11 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm") do
              i(class: "fas fa-user text-sm")
            end

            div(class: "min-w-0") do
              p(class: "truncate text-sm font-semibold text-foreground") { current_user.name }
              p(class: "truncate text-xs text-muted-foreground") { current_user.email }
            end
          end

          div(class: "space-y-2") do
            footer_link("Configurações", edit_user_preference_path, "fa-sliders-h")
            footer_link("Sair", destroy_user_session_path, "fa-sign-out-alt", data: { turbo_method: :delete })
          end
        end
      end
    end

    def footer_link(label, path, icon, data: {})
      a(
        href: path,
        class: "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-foreground transition hover:bg-accent hover:text-accent-foreground",
        data: data
      ) do
        i(class: "fas #{icon} w-4 text-center text-muted-foreground")
        span { label }
      end
    end

    def mobile_header
      div(class: "flex items-center justify-between border-b border-border bg-background/95 px-4 py-3 backdrop-blur md:hidden") do
        div(class: "flex items-center gap-3") do
          div(class: "flex h-10 w-10 items-center justify-center rounded-2xl bg-primary/12 text-primary") do
            i(class: "fas fa-clock text-sm")
          end

          div(class: "space-y-0.5") do
            p(class: "text-sm font-semibold tracking-tight text-foreground") { "Smart Ponto" }
            p(class: "text-xs text-muted-foreground") { "Painel institucional ágil" }
          end
        end

        icon_button("Abrir menu", "fa-bars", action: "sidebar#openMobile")
      end
    end

    def desktop_header
      div(class: "hidden items-center justify-between border-b border-border bg-background/95 px-5 py-4 backdrop-blur md:flex") do
        icon_button("Alternar menu", "fa-bars", action: "sidebar#toggleDesktop")
        div
      end
    end

    def icon_button(label, icon, action:)
      button(
        type: "button",
        class: "inline-flex h-10 w-10 items-center justify-center rounded-full border border-border bg-white text-muted-foreground shadow-sm transition hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        data: { action: action },
        aria: { label: label }
      ) do
        i(class: "fas #{icon} text-sm")
      end
    end

    def grouped_items
      navigation_items.group_by(&:group)
    end

    def navigation_items
      [
        Item.new(
          label: "Dashboard",
          path: dashboard_index_path,
          icon: "fa-house",
          group: :primary,
          active: ->(path) { path == dashboard_index_path || path == authenticated_root_path }
        ),
        Item.new(
          label: "Meu ponto",
          path: time_sheets_path,
          icon: "fa-clock",
          group: :primary,
          active: ->(path) { path.start_with?(time_sheets_path) }
        ),
        Item.new(
          label: "Aprovações",
          path: approvals_path,
          icon: "fa-clipboard-check",
          group: :management,
          active: ->(path) { path.start_with?(approvals_path) }
        ),
        Item.new(
          label: "Gestão da equipe",
          path: manager_team_members_path,
          icon: "fa-users",
          group: :management,
          active: ->(path) { path.start_with?(manager_team_members_path) }
        )
      ].select do |item|
        management_item?(item) ? manager? : true
      end
    end

    def management_item?(item)
      item.group == :management
    end

    def manager?
      current_user.role == "gestor"
    end
    end
  end
end
