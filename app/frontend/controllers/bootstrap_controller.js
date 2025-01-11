import { Controller } from "@hotwired/stimulus"
import { Tooltip } from 'bootstrap';

// Connects to data-controller="bootstrap"
export default class extends Controller {
  connect() {
    let tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    let tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new Tooltip(tooltipTriggerEl)
    })
  }

  remove() {
    document.querySelectorAll('div[role=tooltip].tooltip').forEach((tooltip) => tooltip.remove())
  }
}