import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "label", "description"]

  async toggle(event) {
    const checkbox = event.currentTarget
    const label = this.labelTargets.find((element) => element.dataset.userId === checkbox.dataset.userId)
    const description = this.descriptionTargets.find((element) => element.dataset.userId === checkbox.dataset.userId)
    const toggleUrl = checkbox.dataset.toggleUrl

    try {
      const response = await fetch(toggleUrl, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })

      const data = await response.json()

      if (!response.ok || !data.success) {
        throw new Error(data.message || "Erro ao atualizar permissão")
      }

      if (label) {
        label.textContent = data.status ? "Habilitado" : "Desabilitado"
      }

      if (description) {
        description.textContent = data.status
          ? "Pode registrar ponto e ajustes no fim de semana."
          : "Nao pode registrar ponto no fim de semana."
      }

      this.showNotice(data.message, "success")
    } catch (error) {
      checkbox.checked = !checkbox.checked
      this.showNotice(error.message || "Erro ao atualizar permissão. Tente novamente.", "error")
    }
  }

  showNotice(message, type) {
    const notice = document.createElement("div")
    const tone = type === "success"
      ? "border-green-200 bg-green-50 text-green-700"
      : "border-red-200 bg-red-50 text-red-700"
    const icon = type === "success" ? "fa-check-circle" : "fa-exclamation-circle"

    notice.className = `fixed right-4 top-4 z-50 rounded-xl border px-4 py-3 shadow-lg transition-opacity duration-300 ${tone}`
    notice.innerHTML = `
      <div class="flex items-center gap-2 text-sm font-medium">
        <i class="fas ${icon}"></i>
        <span>${message}</span>
      </div>
    `

    document.body.appendChild(notice)

    setTimeout(() => {
      notice.classList.add("opacity-0")
      setTimeout(() => notice.remove(), 300)
    }, 3000)
  }
}
