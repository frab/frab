import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="duration"
export default class extends Controller {
  static targets = ["timeslotSelect", "defaultTimeslotsSelect", "maxTimeslotsSelect", "csvInput", "checkboxContainer"]

  connect() {
    console.log("Duration controller connected")
    this.setupEventListeners()
    this.renderDurationCheckboxes()
  }

  setupEventListeners() {
    this.timeslotSelectTarget.addEventListener('change', this.renderDurationCheckboxes.bind(this))
    this.defaultTimeslotsSelectTarget.addEventListener('change', this.renderDurationCheckboxes.bind(this))
    this.maxTimeslotsSelectTarget.addEventListener('change', this.renderDurationCheckboxes.bind(this))
  }

  durationToTime(minutes) {
    const twoDigits = (n) => n < 10 ? "0" + n : "" + n
    return twoDigits(Math.floor(minutes / 60)) + ':' + twoDigits(minutes % 60)
  }

  renderDurationCheckboxes() {
    const minutesPerSlot = parseInt(this.timeslotSelectTarget.options[this.timeslotSelectTarget.selectedIndex].value)
    const defaultSubmissionInMinutes = parseInt(this.defaultTimeslotsSelectTarget.options[this.defaultTimeslotsSelectTarget.selectedIndex].value) * minutesPerSlot
    const maxTimeslots = parseInt(this.maxTimeslotsSelectTarget.options[this.maxTimeslotsSelectTarget.selectedIndex].value)
    const checkedItems = this.csvInputTarget.value.split(',')
    const ul = this.checkboxContainerTarget.querySelector('ul')

    ul.innerHTML = ''

    for (let slots = 1; slots <= maxTimeslots; slots++) {
      const minutes = slots * minutesPerSlot
      const isChecked = checkedItems.includes(minutes.toString()) || minutes === defaultSubmissionInMinutes
      const isDisabled = minutes === defaultSubmissionInMinutes

      const item = document.createElement('input')
      item.className = 'accepted-duration-checkbox'
      item.type = 'checkbox'
      item.value = minutes
      item.checked = isChecked
      item.disabled = isDisabled

      item.addEventListener('change', this.updateCsv.bind(this))

      ul.appendChild(item)
      ul.appendChild(document.createTextNode(this.durationToTime(minutes)))
      ul.appendChild(document.createElement('br'))
    }
  }

  updateCsv() {
    const checkedBoxes = Array.from(this.checkboxContainerTarget.querySelectorAll("input.accepted-duration-checkbox:checked"))
    const csv = checkedBoxes.map(b => b.value).join(',')
    this.csvInputTarget.value = csv
  }
}
