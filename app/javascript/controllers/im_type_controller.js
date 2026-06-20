import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="im-type"
export default class extends Controller {
  static targets = ["select", "other", "hidden"]
  static values = { otherValue: { type: String, default: "other" } }

  connect() {
    this.sync()
  }

  sync() {
    const isOther = this.selectTarget.value === this.otherValueValue
    this.otherTarget.style.display = isOther ? "" : "none"
    this.hiddenTarget.value = isOther ? this.otherTarget.value : this.selectTarget.value
  }
}
