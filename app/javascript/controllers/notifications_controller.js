import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = ["select", "acceptSubject", "acceptBody", "rejectSubject", "rejectBody", "scheduleSubject", "scheduleBody"]
  static values = { url: String }

  connect() {
    console.log("Notifications controller connected")
  }

  // Action triggered by the "Default Text" button
  loadDefaults(event) {
    event.preventDefault()

    // Check if a language is selected
    const code = this.selectTarget.value
    if (!code || code.trim() === '') {
      alert('Please select a language first before loading default text.')
      return
    }

    this.fetchDefaults(code)
  }

  fetchDefaults(code) {
    const url = `${this.urlValue}?code=${encodeURIComponent(code)}`

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(result => {
      const texts = result.notification

      // Fill in the form fields using Stimulus targets
      if (this.hasAcceptSubjectTarget) this.acceptSubjectTarget.value = texts.accept_subject || ''
      if (this.hasAcceptBodyTarget) this.acceptBodyTarget.value = texts.accept_body || ''
      if (this.hasRejectSubjectTarget) this.rejectSubjectTarget.value = texts.reject_subject || ''
      if (this.hasRejectBodyTarget) this.rejectBodyTarget.value = texts.reject_body || ''
      if (this.hasScheduleSubjectTarget) this.scheduleSubjectTarget.value = texts.schedule_subject || ''
      if (this.hasScheduleBodyTarget) this.scheduleBodyTarget.value = texts.schedule_body || ''
    })
    .catch(error => {
      console.error('Error fetching notification defaults:', error)
      alert('Failed to load default notification text. Please try again.')
    })
  }
}
