import { Controller } from "@hotwired/stimulus"

// Submits the form as filters change, waiting for a pause in typing.
export default class extends Controller {
  static targets = [ "button" ]
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    if (this.hasButtonTarget) this.buttonTarget.hidden = true
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  submit() {
    clearTimeout(this.timeout)
    this.element.requestSubmit()
  }

  // Leaves empty fields out of the URL, so a search reads /titles?q=ultima rather than listing every filter.
  omitBlankFields() {
    const blanks = [ ...this.element.elements ].filter((field) => field.name && !field.disabled && field.value === "")
    blanks.forEach((field) => field.disabled = true)
    setTimeout(() => blanks.forEach((field) => field.disabled = false))
  }

  submitLater() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }
}
