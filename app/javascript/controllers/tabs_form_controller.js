import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabContent", "submitButton"]

  connect() {
    // Initialize the form
    console.log("Tabs form controller connected")
  }

  submitWithLoading(event) {
    // Prevent the default form submission to handle it manually
    event.preventDefault()

    // Show loading state on the submit button
    const button = this.submitButtonTarget
    const originalContent = button.innerHTML

    // Store original content for potential error recovery
    button.dataset.originalContent = originalContent

    // Disable the button to prevent multiple submissions
    button.disabled = true

    // Since the controller is now attached directly to the form element,
    // we can use this.element directly instead of looking for the closest form
    const form = this.element
    form.submit()
  }

  cancel(event) {
    event.preventDefault()

    // Get the current URL
    const currentUrl = window.location.href

    // If we have a previous page to go back to, use history.back()
    // Otherwise, redirect to the dashboard or another appropriate page
    if (document.referrer && document.referrer.includes(window.location.host)) {
      window.history.back()
    } else {
      // Redirect to the dashboard or another appropriate page
      window.location.href = '/'
    }
  }
}
