import { Controller } from "@hotwired/stimulus"

// Dark mode toggle controller
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.updateUI()
  }

  toggle(event) {
    event.preventDefault()
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'
    this.setTheme(newTheme)
    this.updateUI()
  }

  getCurrentTheme() {
    // Check localStorage first, then data attribute, then system preference, then default to light
    const savedTheme = localStorage.getItem('frab-theme')
    if (savedTheme) return savedTheme
    
    const currentTheme = document.documentElement.getAttribute('data-bs-theme')
    if (currentTheme) return currentTheme
    
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    return systemPrefersDark ? 'dark' : 'light'
  }

  setTheme(theme) {
    // Set theme on document element
    document.documentElement.setAttribute('data-bs-theme', theme)

    // Persist theme preference
    localStorage.setItem('frab-theme', theme)

    // Dispatch custom event for other components that might need to react
    window.dispatchEvent(new CustomEvent('theme-changed', {
      detail: { theme: theme }
    }))
  }

  updateUI() {
    const currentTheme = this.getCurrentTheme()
    const isDark = currentTheme === 'dark'

    // Update icon
    if (this.hasIconTarget) {
      this.iconTarget.className = `bi ${isDark ? 'bi-sun-fill' : 'bi-moon-fill'}`
    }

    // Update button title
    this.element.title = isDark ? 'Switch to light mode' : 'Switch to dark mode'
  }
}
