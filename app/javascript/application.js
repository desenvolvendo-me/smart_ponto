// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:submit-end", (event) => {
    if (event.detail.success) {
      Turbo.visit(event.detail.fetchResponse.response.url)
    }
  })