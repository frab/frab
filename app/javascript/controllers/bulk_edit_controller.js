import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk-edit"
export default class extends Controller {
  static targets = ["selector", "editable", "personId", "eventRole", "submitButton"]

  connect() {
    this.updateSubmitButton()
  }

  // Action triggered when the edit selector changes
  selectorChanged() {
    // Hide all editable sections
    this.editableTargets.forEach(editable => {
      editable.style.display = 'none'
    })

    // Show the selected section
    const selectedValue = this.selectorTarget.value
    if (selectedValue) {
      const targetSection = this.element.querySelector(`div.${selectedValue}`)
      if (targetSection) {
        targetSection.style.display = 'block'
      }
    }
  }

  // Action triggered when person selection changes
  personChanged() {
    this.updateSubmitButton()
  }

  // Action triggered when role selection changes
  roleChanged() {
    this.updateSubmitButton()
  }

  // Update the submit button state based on form validity
  updateSubmitButton() {
    if (!this.hasSubmitButtonTarget) return

    const hasPersonId = this.hasPersonIdTarget && this.personIdTarget.value
    const hasEventRole = this.hasEventRoleTarget && this.eventRoleTarget.value

    const isValid = hasPersonId && hasEventRole
    this.submitButtonTarget.disabled = !isValid
  }
}
