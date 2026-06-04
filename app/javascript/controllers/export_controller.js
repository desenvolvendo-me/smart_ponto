import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "previewTbody",
    "csvRadio",
    "excelRadio",
    "summary",
    "previewCount",
    "previewHint",
    "previewStateBadge",
    "submitButton",
    "formMessage",
    "startDate",
    "endDate"
  ]
  static values = { previewUrl: String }

  connect() {
    this.previewRowCount = this.previewTbodyTarget.children.length
    this.updateSubmitState()
    this.updatePreview()
  }

  // Atualizar prévia quando filtros mudarem
  filterChanged() {
    this.updatePreview()
  }

  applyCurrentMonth(updatePreview = true) {
    const today = new Date()
    this.startDateTarget.value = this.formatDate(new Date(today.getFullYear(), today.getMonth(), 1))
    this.endDateTarget.value = this.formatDate(today)
    if (updatePreview) this.updatePreview()
  }

  applyPreviousMonth() {
    const today = new Date()
    const firstDay = new Date(today.getFullYear(), today.getMonth() - 1, 1)
    const lastDay = new Date(today.getFullYear(), today.getMonth(), 0)
    this.startDateTarget.value = this.formatDate(firstDay)
    this.endDateTarget.value = this.formatDate(lastDay)
    this.updatePreview()
  }

  applyLast7Days() {
    const today = new Date()
    const start = new Date(today)
    start.setDate(today.getDate() - 6)
    this.startDateTarget.value = this.formatDate(start)
    this.endDateTarget.value = this.formatDate(today)
    this.updatePreview()
  }

  resetFilters() {
    this.applyCurrentMonth(false)
    const statusField = this.formTarget.querySelector("[name='status']")
    const completeField = this.formTarget.querySelector("[name='complete']")

    if (statusField) statusField.value = ""
    if (completeField) completeField.value = ""
    if (this.hasCsvRadioTarget) this.csvRadioTarget.checked = true

    this.clearMessage()
    this.updatePreview()
  }

  // Função para atualizar a prévia
  updatePreview() {
    if (!this.hasFormTarget || !this.hasPreviewTbodyTarget) return
    if (!this.validDateRange()) return

    this.setLoadingState()

    const formData = new FormData(this.formTarget)
    const params = new URLSearchParams()

    // Adicionar todos os parâmetros do formulário, exceto o formato
    for (const [key, value] of formData.entries()) {
      if (key !== 'format') {
        params.append(key, value)
      }
    }

    // Fazer requisição para obter a prévia
    fetch(`${this.previewUrlValue}?${params.toString()}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      this.previewTbodyTarget.innerHTML = ''
      const previewData = data.preview_data || []
      this.previewRowCount = previewData.length

      if (this.hasSummaryTarget) {
        this.summaryTarget.textContent = `${previewData.length} registros no recorte atual`
      }

      if (this.hasPreviewCountTarget) {
        this.previewCountTarget.textContent = `${previewData.length} linhas`
      }

      if (previewData.length > 0) {
        this.setReadyState()

        if (this.hasPreviewHintTarget) {
          this.previewHintTarget.textContent = "Confira alguns registros antes de baixar o arquivo final."
        }

        previewData.forEach(sheet => {
          const row = document.createElement('div')
          row.className = 'grid gap-3 px-4 py-4 lg:grid-cols-[1.2fr_repeat(4,minmax(0,0.8fr))_0.8fr_1fr] lg:items-center'
          row.innerHTML = `
            <div>
              <p class="text-sm font-medium text-slate-900">${sheet.date}</p>
              <p class="mt-1 text-xs text-slate-500 lg:hidden">Referência do registro</p>
            </div>
            <div class="grid grid-cols-2 gap-3 text-sm text-slate-600 lg:contents">
              <div>
                <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Entrada 1</p>
                <p>${sheet.times[0]}</p>
              </div>
              <div>
                <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Saída 1</p>
                <p>${sheet.times[1]}</p>
              </div>
              <div>
                <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Entrada 2</p>
                <p>${sheet.times[2]}</p>
              </div>
              <div>
                <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Saída 2</p>
                <p>${sheet.times[3]}</p>
              </div>
            </div>
            <div>
              <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Total</p>
              <p class="text-sm font-medium text-slate-700">${sheet.total_hours}</p>
            </div>
            <div>
              <p class="text-[11px] font-medium uppercase tracking-[0.14em] text-slate-400 lg:hidden">Status</p>
              <span class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${sheet.approval_status_class}">
                ${sheet.approval_status_label}
              </span>
            </div>
          `
          this.previewTbodyTarget.appendChild(row)
        })
      } else {
        this.setEmptyState()

        if (this.hasPreviewHintTarget) {
          this.previewHintTarget.textContent = "Nenhum registro encontrado. Revise período, status ou completude."
        }

        const row = document.createElement('div')
        row.innerHTML = `
          <div class="px-4 py-8 text-center text-sm text-slate-500">
            Nenhum registro encontrado para os filtros selecionados.
          </div>
        `
        this.previewTbodyTarget.appendChild(row)
      }

      this.updateSubmitState()
    })
    .catch(error => {
      console.error('Erro ao atualizar prévia:', error)
      this.previewRowCount = 0
      this.setErrorState()
      this.previewTbodyTarget.innerHTML = `
        <div class="px-4 py-8 text-center text-sm text-slate-500">
          Não foi possível atualizar a prévia agora. Revise a conexão e tente novamente.
        </div>
      `
      this.showMessage("Nao foi possivel atualizar a previa. Tente novamente em alguns segundos.")
      this.updateSubmitState()
    })
  }

  // Manipular envio do formulário
  submit(event) {
    // Prevenir o envio padrão do formulário
    event.preventDefault()
    if (!this.validDateRange()) return
    if (this.previewRowCount === 0) {
      this.showMessage("Ajuste os filtros antes de exportar. O recorte atual nao possui registros.")
      this.updateSubmitState()
      return
    }

    // Determinar o formato selecionado
    let format = 'csv' // Formato padrão
    if (this.hasExcelRadioTarget && this.excelRadioTarget.checked) {
      format = 'xlsx'
    }

    // Construir a URL com o formato correto
    const formData = new FormData(this.formTarget)
    const params = new URLSearchParams()

    // Adicionar todos os parâmetros do formulário
    for (const [key, value] of formData.entries()) {
      if (key !== 'format') { // Ignorar o campo format, pois será adicionado à extensão da URL
        params.append(key, value)
      }
    }

    // Construir a URL final
    let url = this.formTarget.action
    if (params.toString()) {
      url += '?' + params.toString()
    }

    // Adicionar a extensão do formato
    if (!url.includes('.')) {
      url += '.' + format
    }

    // Redirecionar para a URL construída
    window.location.href = url
  }

  validDateRange() {
    if (!this.hasStartDateTarget || !this.hasEndDateTarget) return true

    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value

    if (!startDate || !endDate) {
      this.showMessage("Informe a data inicial e a data final para gerar a previa.")
      this.previewRowCount = 0
      this.updateSubmitState()
      return false
    }

    if (startDate > endDate) {
      this.showMessage("A data inicial nao pode ser maior que a data final.")
      this.previewRowCount = 0
      this.setInvalidState()
      this.updateSubmitState()
      return false
    }

    this.clearMessage()
    return true
  }

  updateSubmitState() {
    if (!this.hasSubmitButtonTarget) return
    this.submitButtonTarget.disabled = this.previewRowCount === 0
  }

  setLoadingState() {
    this.clearMessage()
    if (this.hasPreviewStateBadgeTarget) {
      this.previewStateBadgeTarget.textContent = "Atualizando previa"
    }
    if (this.hasPreviewHintTarget) {
      this.previewHintTarget.textContent = "Atualizando o recorte com os filtros escolhidos."
    }
    this.previewTbodyTarget.innerHTML = `
      <div class="space-y-3 px-4 py-4">
        <div class="h-16 animate-pulse rounded-2xl bg-slate-100"></div>
        <div class="h-16 animate-pulse rounded-2xl bg-slate-100"></div>
        <div class="h-16 animate-pulse rounded-2xl bg-slate-100"></div>
      </div>
    `
  }

  setReadyState() {
    if (this.hasPreviewStateBadgeTarget) {
      this.previewStateBadgeTarget.textContent = "Pronta para revisar"
    }
  }

  setEmptyState() {
    if (this.hasPreviewStateBadgeTarget) {
      this.previewStateBadgeTarget.textContent = "Recorte vazio"
    }
  }

  setErrorState() {
    if (this.hasPreviewStateBadgeTarget) {
      this.previewStateBadgeTarget.textContent = "Falha na previa"
    }
    if (this.hasPreviewHintTarget) {
      this.previewHintTarget.textContent = "Nao foi possivel carregar os dados agora."
    }
  }

  setInvalidState() {
    if (this.hasPreviewStateBadgeTarget) {
      this.previewStateBadgeTarget.textContent = "Periodo invalido"
    }
    if (this.hasPreviewHintTarget) {
      this.previewHintTarget.textContent = "Corrija o periodo para atualizar a previa."
    }
  }

  showMessage(message) {
    if (!this.hasFormMessageTarget) return
    this.formMessageTarget.textContent = message
    this.formMessageTarget.classList.remove("hidden")
  }

  clearMessage() {
    if (!this.hasFormMessageTarget) return
    this.formMessageTarget.textContent = ""
    this.formMessageTarget.classList.add("hidden")
  }

  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
