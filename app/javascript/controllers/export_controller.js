import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "previewTbody", "csvRadio", "excelRadio"]
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
      // Limpar a tabela atual
      this.previewTbodyTarget.innerHTML = ''

      // Adicionar os novos dados
      if (data.preview_data && data.preview_data.length > 0) {
        data.preview_data.forEach(sheet => {
          const row = document.createElement('tr')
          row.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${sheet.date}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${sheet.times[0]}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${sheet.times[1]}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${sheet.times[2]}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${sheet.times[3]}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${sheet.total_hours}</td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${sheet.approval_status_class}">
                ${sheet.approval_status_label}
              </span>
            </td>
          `
          this.previewTbodyTarget.appendChild(row)
        })
      } else {
        // Mostrar mensagem quando não há dados
        const row = document.createElement('tr')
        row.innerHTML = `
          <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
            Nenhum registro encontrado para os filtros selecionados
          </td>
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