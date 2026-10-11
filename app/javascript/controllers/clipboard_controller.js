import { Controller } from "@hotwired/stimulus"

// Copies the source target's text and announces the result to screen readers.
export default class extends Controller {
  static targets = ["source", "status"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.textContent.trim())
      this.announce("Copied to clipboard")
      this.element.classList.add("is-copied")
      clearTimeout(this.resetTimer)
      this.resetTimer = setTimeout(() => this.element.classList.remove("is-copied"), 1600)
    } catch {
      this.announce("Copy failed. Select the command and copy it manually.")
    }
  }

  disconnect() {
    clearTimeout(this.resetTimer)
  }

  announce(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }
}
