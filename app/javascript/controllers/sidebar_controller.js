import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["desktopSidebar", "mobileMenu", "mobilePanel", "backdrop"]

  connect() {
    this.restoreDesktopState()
    this.closeMobile({ preserveHiddenState: true })
  }

  openMobile() {
    if (!this.hasMobileMenuTarget || !this.hasMobilePanelTarget) return

    this.mobileMenuTarget.classList.remove("hidden")
    this.mobileMenuTarget.setAttribute("aria-hidden", "false")

    requestAnimationFrame(() => {
      this.backdropTarget?.classList.add("opacity-100")
      this.mobilePanelTarget.classList.remove("-translate-x-full")
    })
  }

  closeMobile(eventOrOptions = {}) {
    const options = eventOrOptions?.preserveHiddenState ? eventOrOptions : {}

    if (!this.hasMobileMenuTarget || !this.hasMobilePanelTarget) return

    this.backdropTarget?.classList.remove("opacity-100")
    this.mobilePanelTarget.classList.add("-translate-x-full")
    this.mobileMenuTarget.setAttribute("aria-hidden", "true")

    const hideMenu = () => {
      this.mobileMenuTarget.classList.add("hidden")
    }

    if (options.preserveHiddenState) {
      hideMenu()
      return
    }

    window.setTimeout(hideMenu, 200)
  }

  toggleDesktop() {
    if (!this.hasDesktopSidebarTarget) return

    const collapsed = this.desktopSidebarTarget.classList.toggle("md:hidden")
    localStorage.setItem("sidebarCollapsed", collapsed ? "true" : "false")
  }

  restoreDesktopState() {
    if (!this.hasDesktopSidebarTarget) return

    const collapsed = localStorage.getItem("sidebarCollapsed") === "true"
    this.desktopSidebarTarget.classList.toggle("md:hidden", collapsed)
  }
}
