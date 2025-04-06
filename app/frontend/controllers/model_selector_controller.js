import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modelSelect", "textModels", "imageModels"]

  connect() {
    this.updateModelOptions("text")
  }

  toggleModels(event) {
    const chatType = event.target.value
    this.updateModelOptions(chatType)
  }

  updateModelOptions(chatType) {
    const select = this.modelSelectTarget
    select.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.text = "Select the AI model"
    placeholder.value = ""
    select.add(placeholder)

    const options = chatType === "text" ?
      this.textModelsTarget.content.children :
      this.imageModelsTarget.content.children

    Array.from(options).forEach(option => {
      select.add(option.cloneNode(true))
    })
  }
}