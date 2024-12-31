import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="generic-form"
export default class extends Controller {
  connect() {
    // Add this debug to check this controller is loaded...
    console.log('generic form controller connected', this.element)
  }
  reset() {
    this.element.reset()
  }
}