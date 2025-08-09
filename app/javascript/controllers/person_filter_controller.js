import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="person-filter"
export default class extends Controller {
  static targets = ["filter", "select", "display", "hidden"]
  static values = { url: String }

  connect() {
    console.log("Person filter controller connected")
    this.uniqueId = Math.random().toString(36).substr(2)
    this.updateFilter()
    this.setupEventListeners()
  }

  setupEventListeners() {
    this.filterTarget.addEventListener('input', this.handleFilterInput.bind(this))
    this.selectTarget.addEventListener('change', this.handleSelectChange.bind(this))
  }

  handleFilterInput(event) {
    this.updateFilter(event.target.value)
  }

  handleSelectChange(event) {
    const selectedValue = event.target.value
    this.hiddenTarget.value = selectedValue
    this.hiddenTarget.dispatchEvent(new Event('change'))

    // If a person was selected, clear the search and show the selected person
    if (selectedValue) {
      this.filterTarget.value = ''
      const selectedOption = event.target.selectedOptions[0]
      this.displayTarget.textContent = selectedOption.textContent
      this.displayTarget.style.display = 'block'
      this.selectTarget.parentElement.style.display = 'none'
      this.displayTarget.classList.add("accepted")
    }
  }

  updateFilter(term = "") {
    const url = `${this.urlValue}.json?cachetag=${this.uniqueId}&term=${term}`

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'cache'
      }
    })
    .then(response => response.json())
    .then(data => {
      // Don't replace a name with a "too many" message
      // unless triggered explicitly
      if (data.too_many && !this.filterTarget.value && this.displayTarget.textContent) {
        console.log("skipping")
        return
      }

      // Update selection box
      this.selectTarget.innerHTML = ''

      if (data.msg || data.too_many) {
        const option = document.createElement('option')
        option.value = ""
        option.textContent = data.msg || data.too_many
        this.selectTarget.appendChild(option)
      }

      if (data.people) {
        data.people.forEach(person => {
          const option = document.createElement('option')
          option.value = person.id
          option.textContent = person.text
          this.selectTarget.appendChild(option)
        })
      }

      // Pre-select the existing person if possible
      const previouslySelectedId = this.hiddenTarget.value
      if (previouslySelectedId) {
        const existingOption = this.selectTarget.querySelector(`option[value="${previouslySelectedId}"]`)
        if (existingOption) {
          existingOption.selected = true
        }
      }

      // Update the hidden person_id
      const selectedOption = this.selectTarget.querySelector("option:checked")
      const selectedId = selectedOption ? selectedOption.value : ""
      this.hiddenTarget.value = selectedId
      this.hiddenTarget.dispatchEvent(new Event('change'))

      // Show results based on whether we have search results or a selected person
      const hasResults = this.selectTarget.children.length > 0
      const hasSearchTerm = this.filterTarget.value.length > 0
      const hasSelectedPerson = selectedId && selectedId !== ""

      if (hasSearchTerm && hasResults) {
        // Show dropdown when user is searching and there are results
        this.displayTarget.style.display = 'none'
        this.selectTarget.parentElement.style.display = 'block'
      } else if (hasSelectedPerson && !hasSearchTerm) {
        // Show selected person when no search term and person is selected
        const selectedOption = this.selectTarget.querySelector(`option[value="${selectedId}"]`)
        this.displayTarget.textContent = selectedOption ? selectedOption.textContent : ''
        this.displayTarget.style.display = 'block'
        this.selectTarget.parentElement.style.display = 'none'
        this.displayTarget.classList.add("accepted")
      } else {
        // Default state - show display area
        this.displayTarget.style.display = 'block'
        this.selectTarget.parentElement.style.display = 'none'
        this.displayTarget.classList.remove("accepted")
      }
    })
    .catch(error => {
      console.error('Person filter error:', error)
      this.hiddenTarget.value = ""
      this.hiddenTarget.dispatchEvent(new Event('change'))
      this.displayTarget.style.display = 'none'
      this.selectTarget.parentElement.style.display = 'none'
    })
  }
}
