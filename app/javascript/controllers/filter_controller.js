import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = ["form", "valuesSelect", "range", "numInput"]
  static values = { qname: String }

  connect() {
    console.log("Filter controller connected")
  }

  // Action triggered by the "Apply Filter" button
  applyFilter(event) {
    event.preventDefault()

    const qname = this.qnameValue
    if (!qname) return

    let newValue = ''

    // Handle checkbox filters
    if (this.hasValuesSelectTarget) {
      const selectedVals = []
      const checkedInputs = this.valuesSelectTarget.querySelectorAll('input:checked')
      checkedInputs.forEach(input => selectedVals.push(input.value))
      newValue = selectedVals.join('|')
    }

    // Handle range filters
    if (this.hasRangeTarget && this.rangeTarget.querySelectorAll('input').length) {
      const checkedOp = this.rangeTarget.querySelector('input:checked')
      const op = checkedOp ? checkedOp.value : null
      const refval = this.hasNumInputTarget ? parseFloat(this.numInputTarget.value) : NaN
      if (op && !isNaN(refval)) {
        newValue = op + refval
      }
    }

    // Update URL with new filter value
    const url = new URL(location.href)

    if (newValue && newValue.length > 0) {
      url.searchParams.set(qname, newValue)
    } else {
      url.searchParams.delete(qname)
    }

    // Hide modal first
    this.hideModal()

    // Navigate to filtered URL
    window.location.href = url.toString()
  }

  // Action triggered by the "Clear Filter" button
  clearFilter(event) {
    event.preventDefault()

    const qname = this.qnameValue
    if (!qname) return

    // Remove filter from URL
    const url = new URL(location.href)
    url.searchParams.delete(qname)

    // Hide modal first
    this.hideModal()

    // Navigate to unfiltered URL
    window.location.href = url.toString()
  }

  // Hide the modal after action
  hideModal() {
    const modal = bootstrap.Modal.getInstance(document.getElementById('events-modal'))
    if (modal) modal.hide()
  }
}
