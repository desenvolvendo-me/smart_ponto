import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    const urlParams = new URLSearchParams(window.location.search)
    const tabParam = urlParams.get("tab")

    this.activateTab(tabParam === "history" ? "history" : "pending")
  }

  switch(event) {
    event.preventDefault()

    const tab = event.currentTarget.dataset.tab
    this.activateTab(tab)

    const url = new URL(window.location.href)
    if (tab === "history") {
      url.searchParams.set("tab", "history")
    } else {
      url.searchParams.delete("tab")
    }

    history.pushState({}, "", url)
  }

  activateTab(tab) {
    this.tabTargets.forEach((element) => {
      const isActive = element.dataset.tab === tab

      element.classList.toggle("bg-white", isActive)
      element.classList.toggle("text-foreground", isActive)
      element.classList.toggle("shadow-sm", isActive)
      element.classList.toggle("ring-1", isActive)
      element.classList.toggle("ring-border/70", isActive)

      element.classList.toggle("text-muted-foreground", !isActive)
      element.classList.toggle("hover:bg-white/70", !isActive)
      element.classList.toggle("hover:text-foreground", !isActive)
    })

    this.contentTargets.forEach((element) => {
      element.classList.toggle("hidden", element.dataset.tab !== tab)
    })
  }
}
