import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Sidebar controller connected - hotwire-spark should work now!")
  }
}