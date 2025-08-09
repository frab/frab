import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="conference-import"
export default class extends Controller {
  static targets = [
    "form", "importBtn", "progressSection", "progressBar",
    "progressText", "statusMessage", "errorAlert", "errorMessage", "retryBtn"
  ]

  static values = {
    createImportUrl: String,
    importProgressUrl: String,
    conferenceIndexUrl: String
  }

  connect() {
    this.progressInterval = null
    console.log("Import controller connected")
  }

  disconnect() {
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
    }
  }

  // Action triggered when form is submitted
  submitImport(event) {
    event.preventDefault()

    const formData = new FormData(this.formTarget)

    // Disable form and show progress
    this.importBtnTarget.disabled = true
    this.importBtnTarget.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Uploading...'
    this.progressSectionTarget.style.display = 'block'

    // Upload file
    fetch(this.createImportUrlValue, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => {
      if (response.ok) {
        // Start polling for progress
        this.startProgressPolling()
      } else {
        throw new Error('Upload failed')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.resetForm()
      this.progressSectionTarget.style.display = 'none'
      alert('Upload failed. Please try again.')
    })
  }

  // Action triggered when retry button is clicked
  retry() {
    this.errorAlertTarget.style.display = 'none'
    this.progressSectionTarget.style.display = 'none'
    this.resetForm()
  }

  // Private methods
  startProgressPolling() {
    this.progressInterval = setInterval(() => {
      fetch(this.importProgressUrlValue)
        .then(response => response.json())
        .then(data => {
          this.updateProgress(data.progress, data.message, data.status)

          if (data.status === 'completed' || data.status === 'error') {
            clearInterval(this.progressInterval)
            this.resetForm()

            if (data.status === 'completed') {
              setTimeout(() => {
                window.location.href = this.conferenceIndexUrlValue
              }, 2000)
            } else if (data.status === 'error') {
              this.showErrorAlert(data.message)
            }
          }
        })
        .catch(error => {
          console.error('Progress polling error:', error)
          clearInterval(this.progressInterval)
          this.resetForm()
        })
    }, 2000) // Poll every 2 seconds
  }

  updateProgress(progress, message, status) {
    this.progressBarTarget.style.width = progress + '%'
    this.progressBarTarget.setAttribute('aria-valuenow', progress)
    this.progressTextTarget.textContent = Math.round(progress) + '%'
    this.statusMessageTarget.textContent = message

    // Update progress bar color based on status
    this.progressBarTarget.className = 'progress-bar progress-bar-striped'
    if (status === 'completed') {
      this.progressBarTarget.classList.add('bg-success')
      this.progressBarTarget.classList.remove('progress-bar-animated')
    } else if (status === 'error') {
      this.progressBarTarget.classList.add('bg-danger')
      this.progressBarTarget.classList.remove('progress-bar-animated')
    } else {
      this.progressBarTarget.classList.add('progress-bar-animated')
    }
  }

  showErrorAlert(message) {
    this.errorMessageTarget.textContent = message
    this.errorAlertTarget.style.display = 'block'

    // Hide progress bar on error
    this.progressBarTarget.style.width = '0%'
    this.progressTextTarget.textContent = '0%'
  }

  resetForm() {
    this.importBtnTarget.disabled = false
    this.importBtnTarget.innerHTML = 'Start Import'
  }
}
