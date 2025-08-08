// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery"
import "controllers"
import "bootstrap"
import "@nathanvda/cocoon"

// Initialize theme on page load (before DOM content loads to prevent flashing)
(function() {
  // Get saved theme, system preference, or default to light
  const savedTheme = localStorage.getItem('frab-theme')
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  const initialTheme = savedTheme || (systemPrefersDark ? 'dark' : 'light')

  // Apply theme immediately to prevent flash of wrong theme
  document.documentElement.setAttribute('data-bs-theme', initialTheme)
})();

// Initialize Bootstrap tooltips and popovers if needed
document.addEventListener('DOMContentLoaded', function() {
  // Enable Bootstrap dropdowns
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle')
  const dropdownList = [...dropdownElementList].map(dropdownToggleEl => new bootstrap.Dropdown(dropdownToggleEl))

  // Enable Bootstrap popovers for action buttons with hints
  const popoverElementList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverElementList].map(popoverEl => {
    return new bootstrap.Popover(popoverEl, {
      trigger: 'hover focus',
      html: true
    })
  })

  // Enable Bootstrap tooltips
  const tooltipElementList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipElementList].map(tooltipEl => new bootstrap.Tooltip(tooltipEl))
})
