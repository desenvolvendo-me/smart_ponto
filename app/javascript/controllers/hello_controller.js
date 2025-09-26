// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "output" ]

    connect() {
        this.outputTarget.textContent = "hotwire works!!"
    }

    greet() {
        this.outputTarget.textContent = "Stimulus works!"
    }
}