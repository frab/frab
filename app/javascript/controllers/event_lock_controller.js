import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { eventId: String, conferenceAcronym: String }

  async toggle(event) {
    const checkbox = event.target

    // Construct URL with proper encoding
    const url = `/${encodeURIComponent(this.conferenceAcronymValue)}/events/${encodeURIComponent(this.eventIdValue)}/toggle_locked`

    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').getAttribute('content')
        }
      })

      if (!response.ok) {
        throw new Error('Failed to toggle lock status')
      }

      const data = await response.json()

      // Update the checkbox to reflect the server state
      checkbox.checked = data.locked

      // Optional: Show a brief success indicator
      this.showFeedback(checkbox, data.locked)

    } catch (error) {
      console.error('Error toggling lock:', error)

      // Revert the checkbox state on error
      checkbox.checked = !checkbox.checked

      // Show error feedback
      this.showError(checkbox)
    }
  }

  showFeedback(checkbox, isLocked) {
    const label = checkbox.nextElementSibling
    if (label) {
      label.style.transition = 'color 0.3s ease'
      label.style.color = isLocked ? '#dc3545' : '#28a745'

      setTimeout(() => {
        label.style.color = ''
      }, 1500)
    }
  }

  showError(checkbox) {
    checkbox.style.transition = 'box-shadow 0.3s ease'
    checkbox.style.boxShadow = '0 0 0 0.2rem rgba(220, 53, 69, 0.25)'

    setTimeout(() => {
      checkbox.style.boxShadow = ''
    }, 2000)
  }
}
