import { Controller } from "@hotwired/stimulus"

// Drag-and-drop upload for one side of a box: previews the chosen photo,
// checks its type and size before upload, and shows direct upload progress.
export default class extends Controller {
  static targets = [ "input", "image", "hint", "error", "progress" ]
  static values = { maxBytes: Number, types: String }

  connect() {
    this.element.addEventListener("direct-upload:progress", this.#showProgress)
    this.element.addEventListener("direct-upload:error", this.#showUploadError)
  }

  disconnect() {
    this.element.removeEventListener("direct-upload:progress", this.#showProgress)
    this.element.removeEventListener("direct-upload:error", this.#showUploadError)
    this.#revokePreview()
  }

  dragOver(event) {
    event.preventDefault()
    this.element.classList.add("face-upload--dragging")
  }

  dragLeave() {
    this.element.classList.remove("face-upload--dragging")
  }

  drop(event) {
    event.preventDefault()
    this.dragLeave()

    const [ file ] = event.dataTransfer.files
    if (!file) return

    const files = new DataTransfer()
    files.items.add(file)
    this.inputTarget.files = files.files
    this.preview()
  }

  preview() {
    const [ file ] = this.inputTarget.files
    if (!file) return

    const problem = this.#problemWith(file)
    if (problem) {
      this.inputTarget.value = ""
      this.#showError(problem)
      return
    }

    this.#showError(null)
    this.#revokePreview()
    this.previewUrl = URL.createObjectURL(file)
    this.imageTarget.src = this.previewUrl
    this.imageTarget.alt = `Preview of ${file.name}`
    this.imageTarget.hidden = false
    if (this.hasHintTarget) this.hintTarget.hidden = true
  }

  #problemWith(file) {
    const types = this.typesValue.split(",")
    if (!types.includes(file.type)) return "Choose a JPEG, PNG or WebP image."
    if (file.size > this.maxBytesValue) return `Choose a file smaller than ${Math.round(this.maxBytesValue / 1048576)} MB.`
    return null
  }

  #showError(message) {
    this.errorTarget.textContent = message || ""
    this.errorTarget.hidden = !message
    this.element.classList.toggle("face-upload--invalid", Boolean(message))
  }

  #showProgress = (event) => {
    if (!this.hasProgressTarget) return
    this.progressTarget.hidden = false
    this.progressTarget.value = event.detail.progress
  }

  #showUploadError = (event) => {
    event.preventDefault()
    this.#showError(`Upload failed: ${event.detail.error}`)
  }

  #revokePreview() {
    if (this.previewUrl) URL.revokeObjectURL(this.previewUrl)
    this.previewUrl = null
  }
}
