// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery"
import "controllers"
import "bootstrap"
import "@nathanvda/cocoon"
import "./theme_init"

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
