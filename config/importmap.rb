# Pin npm packages by running ./bin/importmap

# Core dependencies - available to all layouts
pin "jquery", to: "jquery-3.7.1.slim.js", preload: ['application']
pin "bootstrap", to: "bootstrap.bundle.js", preload: ['application']

# Layout-specific entry points
pin "application", preload: ['application']
pin "public_schedule", to: "public_schedule.js", preload: ['public_schedule']

# Conference/Cfp management dependencies
pin "@nathanvda/cocoon", to: "@nathanvda--cocoon.js", preload: ['application']
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: ['application']
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: ['application']
pin "moment", to: "moment.js", preload: false
pin "range-slider-element", to: "range-slider-element.js", preload: false

# Conference-only chart/rating dependencies
pin_all_from 'vendor/javascript/flot', under: 'flot', to: 'flot', preload: false


# Stimulus controllers - only for conference
pin_all_from "app/javascript/controllers", under: "controllers", preload: ['application']
