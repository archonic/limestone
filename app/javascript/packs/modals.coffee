# Modified from https://github.com/ifad/data-confirm-modal/blob/master/vendor/assets/javascripts/data-confirm-modal.js
$ ->
  ###*
  # Builds the markup for a [Bootstrap modal](http://twitter.github.io/bootstrap/javascript.html#modals)
  # for the given `element`. Uses the following `data-` parameters to
  # customize it:
  #
  #  * `data-confirm`: Contains the modal body text. HTML is allowed.
  #                    Separate multiple paragraphs using \n\n.
  #  * `data-commit`:  The 'confirm' button text. "Confirm" by default.
  #  * `data-cancel`:  The 'cancel' button text. "Cancel" by default.
  #  * `data-verify`:  Adds a text input in which the user has to input
  #                    the text in this attribute value for the 'confirm'
  #                    button to be clickable. Optional.
  #  * `data-verify-text`:  Adds a label for the data-verify input. Optional
  #  * `data-focus`:   Define focused input. Supported values are
  #                    'cancel' or 'commit', 'cancel' is default for
  #                    data-method DELETE, 'commit' for all others.
  #
  # You can set global setting using `dataConfirmModal.setDefaults`, for example:
  #
  #    dataConfirmModal.setDefaults({
  #      title: 'Confirm your action',
  #      commit: 'Continue',
  #      cancel: 'Cancel',
  #      fade:   false,
  #      verifyClass: 'form-control',
  #    });
  ###
  buildElementModal = undefined
  buildModal = undefined
  defaults = undefined
  getModal = undefined
  settings = undefined
  window_confirm = undefined
  defaults =
    title: 'Are you sure?'
    commit: 'Confirm'
    commitClass: 'btn-danger'
    cancel: 'Cancel'
    cancelClass: 'btn-light'
    fade: true
    verifyClass: 'form-control'
    elements: [
      'a[data-confirm]'
      'button[data-confirm]'
      'input[type=submit][data-confirm]'
    ]
    focus: 'commit'
    zIndex: 999
    modalClass: false
    show: true
    backdrop: 'static'
    keyboard: true
  settings = undefined
  window.dataConfirmModal =
    setDefaults: (newSettings) ->
      settings = $.extend(settings, newSettings)
    restoreDefaults: ->
      settings = $.extend({}, defaults)
    confirm: (options) ->
      modal = undefined
      modal = buildModal(options)
      modal.spawn()
      modal.on 'hidden.bs.modal', ->
        modal.remove()
      modal.find('.commit').on 'click', ->
        if options.onConfirm and options.onConfirm.call
          options.onConfirm.call()
        modal.modal 'hide'
      modal.find('.cancel').on 'click', ->
        if options.onCancel and options.onCancel.call
          options.onCancel.call()
        modal.modal 'hide'
  dataConfirmModal.restoreDefaults()
  buildElementModal = (element) ->
    modal = undefined
    options = undefined
    options =
      title: element.data('title') or element.attr('title') or element.data('original-title')
      text: element.data('confirm')
      focus: element.data('focus')
      method: element.data('method')
      modalClass: element.data('modal-class')
      commit: element.data('commit')
      commitClass: element.data('commit-class')
      cancel: element.data('cancel')
      cancelClass: element.data('cancel-class')
      remote: element.data('remote')
      verify: element.data('verify')
      verifyRegexp: element.data('verify-regexp')
      verifyLabel: element.data('verify-text')
      verifyRegexpCaseInsensitive: element.data('verify-regexp-caseinsensitive')
      backdrop: element.data('backdrop') or defaults.backdrop
      keyboard: element.data('keyboard') or defaults.keyboard
      show: element.data('show') or defaults.show
    modal = buildModal(options)
    modal.find('.commit').on 'click', ->
      element.get(0).click()
      modal.modal 'hide'
    modal

  buildModal = (options) ->
    body = undefined
    cancel = undefined
    caseInsensitive = undefined
    commit = undefined
    current = undefined
    fade = undefined
    focus_element = undefined
    id = undefined
    isMatch = undefined
    modal = undefined
    modalClass = undefined
    modalClose = undefined
    modalHeader = undefined
    modalTitle = undefined
    re = undefined
    regexp = undefined
    verification = undefined
    id = 'confirm-modal-' + String(Math.random()).slice(2, -1)
    fade = if settings.fade then 'fade' else ''
    modalClass = if options.modalClass then options.modalClass else settings.modalClass
    modalTitle = '<h5 id="' + id + 'Label" class="modal-title"></h5>'
    modalClose = '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>'
    modalHeader = undefined
    modalHeader = modalTitle + modalClose
    modal = $('<div id="' + id + '" class="modal ' + modalClass + ' ' + fade + '" tabindex="-1" role="dialog" aria-labelledby="' + id + 'Label" aria-hidden="true">' + '<div class="modal-dialog" role="document">' + '<div class="modal-content">' + '<div class="modal-header">' + modalHeader + '</div>' + '<div class="modal-body"></div>' + '<div class="modal-footer">' + '<button class="btn cancel" data-dismiss="modal" aria-hidden="true"></button>' + '<button class="btn commit"></button>' + '</div>' + '</div>' + '</div>' + '</div>')
    modal.css 'z-index', settings.zIndex
    modal.find('.modal-title').text options.title or settings.title
    body = modal.find('.modal-body')
    $.each (options.text or '').split(/\n{2}/), (i, piece) ->
      body.append $('<p/>').html(piece)
    commit = modal.find('.commit')
    commit.text options.commit or settings.commit
    commit.addClass options.commitClass or settings.commitClass
    cancel = modal.find('.cancel')
    cancel.text options.cancel or settings.cancel
    cancel.addClass options.cancelClass or settings.cancelClass
    if options.remote
      commit.attr 'data-dismiss', 'modal'
    if options.verify or options.verifyRegexp
      commit.prop 'disabled', true
      isMatch = undefined
      if options.verifyRegexp
        caseInsensitive = options.verifyRegexpCaseInsensitive
        regexp = options.verifyRegexp
        re = new RegExp(regexp, if caseInsensitive then 'i' else '')
        isMatch = (input) ->
          input.match re
      else
        isMatch = (input) ->
          options.verify == input
      verification = $('<input/>',
        'type': 'text'
        'class': settings.verifyClass).on('keyup', ->
        commit.prop 'disabled', !isMatch($(this).val())
      )
      modal.on 'shown.bs.modal', ->
        verification.focus()
      modal.on 'hidden.bs.modal', ->
        verification.val('').trigger 'keyup'
      if options.verifyLabel
        body.append $('<p>', text: options.verifyLabel)
      body.append verification
    focus_element = undefined
    if options.focus
      focus_element = options.focus
    else if options.method == 'delete'
      focus_element = 'cancel'
    else
      focus_element = settings.focus
    focus_element = modal.find('.' + focus_element)
    modal.on 'shown.bs.modal', ->
      focus_element.focus()
    $('body').append modal

    modal.spawn = ->
      modal.modal $.extend({},
        backdrop: options.backdrop or defaults.backdrop
        keyboard: options.keyboard or defaults.keyboard
        show: options.show or defaults.show)
    modal

  ###*
  # Returns a modal already built for the given element or builds a new one,
  # caching it into the element's `confirm-modal` data attribute.
  ###
  getModal = (element) ->
    modal = undefined
    modal = element.data('confirm-modal')
    if !modal
      modal = buildElementModal(element)
      element.data 'confirm-modal', modal
    modal

  $.fn.confirmModal = ->
    modal = undefined
    modal = getModal($(this))
    modal.spawn()
    modal

  if window.Rails or $.rails
    ###*
    # Attaches to Rails' UJS adapter's 'confirm' event, triggered on elements
    # having a `data-confirm` attribute set.
    # If the modal is not visible, then it is spawned and the default Rails
    # confirmation dialog is canceled.
    # If the modal is visible, it means the handler is being called by the
    # modal commit button click handler, as such the user has successfully
    # clicked on the confirm button. In this case Rails' confirm function
    # is briefly overriden, and afterwards reset when the modal is closed.
    ###
    window_confirm = window.confirm
    return $(document).delegate(settings.elements.join(', '), 'confirm', ->
      element = undefined
      modal = undefined
      element = $(this)
      modal = getModal(element)
      if !modal.is(':visible')
        modal.spawn()
        false
      else
        window.confirm = ->
          true
        modal.one 'hidden.bs.modal', ->
          window.confirm = window_confirm
        true
    )
