// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// register flash controller
import { Application } from "@hotwired/stimulus"
import FlashController from "./flash_controller"

window.Stimulus = window.Stimulus || Application.start()
Stimulus.register("flash", FlashController)
