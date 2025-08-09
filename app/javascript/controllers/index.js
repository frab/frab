import { application } from "controllers/application"

// Lazy load all controllers defined in the import map under controllers/**/*_controller
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers", application)
