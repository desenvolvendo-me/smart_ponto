// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "output" ]

    connect() {
        console.log("Stimulus controller connected!")
    }

    greet() {
        this.outputTarget.textContent = "Stimulus works!"
    }
}