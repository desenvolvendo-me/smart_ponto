import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton"]
  
  initialize() {
    if (this.hasFormTarget) {
      this.updateCurrentTime()
      this.timeInterval = setInterval(() => {
        this.updateCurrentTime()
      }, 60000) // Atualiza a cada minuto
    }
  }
  
  disconnect() {
    if (this.timeInterval) {
      clearInterval(this.timeInterval)
    }
  }
  
  updateCurrentTime() {
    const now = new Date()
    const hours = now.getHours().toString().padStart(2, '0')
    const minutes = now.getMinutes().toString().padStart(2, '0')
    
    const timeInput = this.formTarget.querySelector('input[type="time"]')
    if (timeInput) {
      timeInput.value = `${hours}:${minutes}`
    }
  }
  
  loading() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Registrando...'
    }
  }
}