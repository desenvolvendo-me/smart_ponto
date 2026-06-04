import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "previewTbody", "csvRadio", "excelRadio", "summary", "previewCount", "previewHint"]
  static values = { previewUrl: String }

  connect() {
    this.updatePreview()
  }

  // Atualizar prévia quando filtros mudarem
  filterChanged() {
    this.updatePreview()
  }

  // Função para atualizar a prévia
  updatePreview() {
    if (!this.hasFormTarget || !this.hasPreviewTbodyTarget) return

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

      if (this.hasSummaryTarget) {
        this.summaryTarget.textContent = `${previewData.length} registros no recorte atual`
      }

      if (this.hasPreviewCountTarget) {
        this.previewCountTarget.textContent = `${previewData.length} linhas`
      }

      if (previewData.length > 0) {
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
    })
    .catch(error => {
      console.error('Erro ao atualizar prévia:', error)
    })
  }

  // Manipular envio do formulário
  submit(event) {
    // Prevenir o envio padrão do formulário
    event.preventDefault()

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
}
