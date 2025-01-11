// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import RemovalsController from "./removals_controller"
application.register("removals", RemovalsController)

import GenericFormController from "./generic_form_controller"
application.register("generic-form", GenericFormController)

import BootstrapController from "./bootstrap_controller"
application.register("bootstrap", BootstrapController)

import SubmitOnEnterController from "./submit_on_enter_controller"
application.register("submit-on-enter", SubmitOnEnterController)