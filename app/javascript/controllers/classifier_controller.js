import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="classifier"
export default class extends Controller {
  static targets = ["checkbox", "output"]

  connect() {
    console.log("Classifier controller connected")
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Listen for checkbox changes
    document.querySelectorAll('.classifier-checkbox').forEach(checkbox => {
      checkbox.addEventListener('change', this.handleCheckboxChange.bind(this))
    })

    // Listen for range input changes
    document.addEventListener('input', (event) => {
      if (event.target.classList.contains('form-range')) {
        this.handleRangeChange(event)
      }
    })

    // Listen for cocoon events
    document.addEventListener('cocoon:after-insert', (event) => {
      this.handleFieldAdded(event)
    })
  }

  handleCheckboxChange(event) {
    const box = event.currentTarget
    const classifier_id = box.name.replace(/^classifier-checkbox-/, '')
    const classifier_remove_link = document.getElementById(`remove_classifier_${classifier_id}`)

    // If unchecked, remove the classifier
    if (!box.checked) {
      if (classifier_remove_link) {
        classifier_remove_link.click()
      }
      return
    }

    // If checked, show existing or add new classifier
    const exists = document.querySelector(`.classifier-block-${classifier_id}`)
    if (exists) {
      exists.style.display = 'block'
      const hiddenInput = classifier_remove_link?.previousElementSibling
      if (hiddenInput && hiddenInput.type === 'hidden') {
        hiddenInput.value = 'false'
      }
    } else {
      // Find the add_fields link and trigger it
      const addLink = box.previousElementSibling
      if (addLink && addLink.classList.contains('add_fields')) {
        addLink.click()
      }
    }
  }

  handleRangeChange(event) {
    const category = event.target.getAttribute('category')
    const output = document.querySelector(`.category-output-${category}`)
    if (output) {
      output.innerHTML = event.target.value + ' %'
    }
  }

  handleFieldAdded(event) {
    // When a new field is added via cocoon, make sure range inputs work
    const insertedItem = event.detail.insertedItem
    const rangeInputs = insertedItem.querySelectorAll('input[type="range"]')
    rangeInputs.forEach(input => {
      input.addEventListener('input', this.handleRangeChange.bind(this))
    })
  }
}
