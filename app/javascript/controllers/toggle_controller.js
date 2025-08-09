import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = { target: String }

  toggle() {
    const target = this.targetValue || this.data.get("target")
    if (target) {
      const element = document.querySelector(target)
      if (element) {
        if (element.style.display === "none") {
          element.style.display = "block"
        } else {
          element.style.display = "none"
        }
      }
    }
  }
}