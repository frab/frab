import { Controller } from "@hotwired/stimulus"
import "flot/jquery.flot"
import "flot/jquery.flot.pie"

// Connects to data-controller="statistics"
export default class extends Controller {
  static targets = ["eventsGraph", "languageGraph", "genderGraph"]
  static values = {
    eventsUrl: String,
    languageUrl: String,
    genderUrl: String
  }

  connect() {
    console.log("Statistics controller connected")
    console.log("Available targets:", {
      eventsGraph: this.hasEventsGraphTarget,
      languageGraph: this.hasLanguageGraphTarget,
      genderGraph: this.hasGenderGraphTarget
    })
    console.log("URL values:", {
      eventsUrl: this.eventsUrlValue,
      languageUrl: this.languageUrlValue,
      genderUrl: this.genderUrlValue
    })

    // Initialize charts on page load
    this.updateEventsBreakdown()
    this.updateLanguagesBreakdown()
    this.updateGenderBreakdown()
  }

  // Event breakdown filters
  filterAllEvents(event) {
    event.preventDefault()
    this.updateEventsBreakdown()
  }

  filterLecturesOnly(event) {
    event.preventDefault()
    this.updateEventsBreakdown("lectures")
  }

  filterWorkshopsOnly(event) {
    event.preventDefault()
    this.updateEventsBreakdown("workshops")
  }

  filterOthersOnly(event) {
    event.preventDefault()
    this.updateEventsBreakdown("others")
  }

  // Language breakdown filters
  filterAllLanguages(event) {
    event.preventDefault()
    this.updateLanguagesBreakdown()
  }

  filterAcceptedLanguages(event) {
    event.preventDefault()
    this.updateLanguagesBreakdown(true)
  }

  // Gender breakdown filters
  filterAllGenders(event) {
    event.preventDefault()
    this.updateGenderBreakdown()
  }

  filterAcceptedGenders(event) {
    event.preventDefault()
    this.updateGenderBreakdown(true)
  }

  // Private methods
  updateEventsBreakdown(type = "") {
    if (!this.hasEventsGraphTarget) return

    const params = new URLSearchParams()
    if (type) {
      params.append('type', type)
    }

    fetch(`${this.eventsUrlValue}?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (typeof $ !== 'undefined' && $.plot) {
        $.plot($(this.eventsGraphTarget), data, {
          series: {
            bars: { show: true, barWidth: 1 }
          },
          xaxis: {
            ticks: [[0.5, "undecided"], [1.5,"accepted"], [2.5, "rejected"], [3.5, "withdrawn/canceled"]]
          }
        })
      }
    })
    .catch(error => console.error('Error updating events breakdown:', error))
  }

  updateLanguagesBreakdown(acceptedOnly = false) {
    if (!this.hasLanguageGraphTarget) {
      console.log("Language graph target not found - chart container may not be rendered")
      return
    }

    const params = new URLSearchParams()
    if (acceptedOnly) {
      params.append('accepted_only', '1')
    }

    console.log(`Fetching language breakdown: ${this.languageUrlValue}?${params.toString()}`)

    fetch(`${this.languageUrlValue}?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(response => {
      console.log('Language breakdown response:', response.status)
      return response.json()
    })
    .then(data => {
      console.log('Language breakdown data:', data)
      if (typeof $ !== 'undefined' && $.plot) {
        $.plot($(this.languageGraphTarget), data, {series: {pie: {show: true}}})
      }
    })
    .catch(error => console.error('Error updating language breakdown:', error))
  }

  updateGenderBreakdown(acceptedOnly = false) {
    if (!this.hasGenderGraphTarget) {
      console.log("Gender graph target not found - chart container may not be rendered")
      return
    }

    const params = new URLSearchParams()
    if (acceptedOnly) {
      params.append('accepted_only', '1')
    }

    console.log(`Fetching gender breakdown: ${this.genderUrlValue}?${params.toString()}`)

    fetch(`${this.genderUrlValue}?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(response => {
      console.log('Gender breakdown response:', response.status)
      return response.json()
    })
    .then(data => {
      console.log('Gender breakdown data:', data)
      if (typeof $ !== 'undefined' && $.plot) {
        $.plot($(this.genderGraphTarget), data, {series: {pie: {show: true}}})
      }
    })
    .catch(error => console.error('Error updating gender breakdown:', error))
  }
}
