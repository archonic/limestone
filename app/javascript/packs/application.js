/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'jquery'
window.$ = window.jQuery = require('jquery');

import 'bootstrap'

import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
Rails.start();
Turbolinks.start();

import * as ActiveStorage from "activestorage"
ActiveStorage.start()

import 'data-confirm-modal'

// Does not process requires when imported like this
import '../../assets/javascripts/application'
import '../packs/src/subscriptions'
console.log('Hello World from Webpacker')
