import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submit-on-enter"
export default class extends Controller {
  connect() {
    console.log('form', this.element.form)
    this.element.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      // We block the default behavior by pressing enter (add a new line)
      event.preventDefault()

      // Check if the textarea is empty
      if (this.element.value.trim() === "") {
        return
      }

      // Fire the submit
      Turbo.navigator.submitForm(this.element.form)
    }
  }
}