// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Auto-dismiss flash messages after 5 seconds
        setTimeout(() => {
            this.dismiss()
        }, 5000)
    }

    dismiss() {
        this.element.classList.add('opacity-0', 'transition-opacity', 'duration-500')
        setTimeout(() => {
            this.element.remove()
        }, 500)
    }
}