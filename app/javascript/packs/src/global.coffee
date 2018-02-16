# Application wide JS

document.addEventListener 'turbolinks:load', ->
  $('[data-toggle="tooltip"]').tooltip()
