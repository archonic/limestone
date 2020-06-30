// Modified from https://github.com/ifad/data-confirm-modal/blob/master/vendor/assets/javascripts/data-confirm-modal.js
$(function() {

  /**
   * Builds the markup for a [Bootstrap modal](http://twitter.github.io/bootstrap/javascript.html#modals)
   * for the given `element`. Uses the following `data-` parameters to
   * customize it:
  #
   *  * `data-confirm`: Contains the modal body text. HTML is allowed.
   *                    Separate multiple paragraphs using \n\n.
   *  * `data-commit`:  The 'confirm' button text. "Confirm" by default.
   *  * `data-cancel`:  The 'cancel' button text. "Cancel" by default.
   *  * `data-verify`:  Adds a text input in which the user has to input
   *                    the text in this attribute value for the 'confirm'
   *                    button to be clickable. Optional.
   *  * `data-verify-text`:  Adds a label for the data-verify input. Optional
   *  * `data-focus`:   Define focused input. Supported values are
   *                    'cancel' or 'commit', 'cancel' is default for
   *                    data-method DELETE, 'commit' for all others.
  #
   * You can set global setting using `dataConfirmModal.setDefaults`, for example:
  #
   *    dataConfirmModal.setDefaults({
   *      title: 'Confirm your action',
   *      commit: 'Continue',
   *      cancel: 'Cancel',
   *      fade:   false,
   *      verifyClass: 'form-control',
   *    });
   */
  var buildElementModal, buildModal, defaults, getModal, settings, window_confirm;
  buildElementModal = void 0;
  buildModal = void 0;
  defaults = void 0;
  getModal = void 0;
  settings = void 0;
  window_confirm = void 0;
  defaults = {
    title: 'Are you sure?',
    commit: 'Confirm',
    commitClass: 'btn-danger',
    cancel: 'Cancel',
    cancelClass: 'btn-light',
    fade: true,
    verifyClass: 'form-control',
    elements: ['a[data-confirm]', 'button[data-confirm]', 'input[type=submit][data-confirm]'],
    focus: 'commit',
    zIndex: 999,
    modalClass: false,
    show: true,
    backdrop: 'static',
    keyboard: true
  };
  settings = void 0;
  window.dataConfirmModal = {
    setDefaults: function(newSettings) {
      return settings = $.extend(settings, newSettings);
    },
    restoreDefaults: function() {
      return settings = $.extend({}, defaults);
    },
    confirm: function(options) {
      var modal;
      modal = void 0;
      modal = buildModal(options);
      modal.spawn();
      modal.on('hidden.bs.modal', function() {
        return modal.remove();
      });
      modal.find('.commit').on('click', function() {
        if (options.onConfirm && options.onConfirm.call) {
          options.onConfirm.call();
        }
        return modal.modal('hide');
      });
      return modal.find('.cancel').on('click', function() {
        if (options.onCancel && options.onCancel.call) {
          options.onCancel.call();
        }
        return modal.modal('hide');
      });
    }
  };
  dataConfirmModal.restoreDefaults();
  buildElementModal = function(element) {
    var modal, options;
    modal = void 0;
    options = void 0;
    options = {
      title: element.data('title') || element.attr('title') || element.data('original-title'),
      text: element.data('confirm'),
      focus: element.data('focus'),
      method: element.data('method'),
      modalClass: element.data('modal-class'),
      commit: element.data('commit'),
      commitClass: element.data('commit-class'),
      cancel: element.data('cancel'),
      cancelClass: element.data('cancel-class'),
      remote: element.data('remote'),
      verify: element.data('verify'),
      verifyRegexp: element.data('verify-regexp'),
      verifyLabel: element.data('verify-text'),
      verifyRegexpCaseInsensitive: element.data('verify-regexp-caseinsensitive'),
      backdrop: element.data('backdrop') || defaults.backdrop,
      keyboard: element.data('keyboard') || defaults.keyboard,
      show: element.data('show') || defaults.show
    };
    modal = buildModal(options);
    modal.find('.commit').on('click', function() {
      element.get(0).click();
      return modal.modal('hide');
    });
    return modal;
  };
  buildModal = function(options) {
    var body, cancel, caseInsensitive, commit, current, fade, focus_element, id, isMatch, modal, modalClass, modalClose, modalHeader, modalTitle, re, regexp, verification;
    body = void 0;
    cancel = void 0;
    caseInsensitive = void 0;
    commit = void 0;
    current = void 0;
    fade = void 0;
    focus_element = void 0;
    id = void 0;
    isMatch = void 0;
    modal = void 0;
    modalClass = void 0;
    modalClose = void 0;
    modalHeader = void 0;
    modalTitle = void 0;
    re = void 0;
    regexp = void 0;
    verification = void 0;
    id = 'confirm-modal-' + String(Math.random()).slice(2, -1);
    fade = settings.fade ? 'fade' : '';
    modalClass = options.modalClass ? options.modalClass : settings.modalClass;
    modalTitle = '<h5 id="' + id + 'Label" class="modal-title"></h5>';
    modalClose = '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>';
    modalHeader = void 0;
    modalHeader = modalTitle + modalClose;
    modal = $('<div id="' + id + '" class="modal ' + modalClass + ' ' + fade + '" tabindex="-1" role="dialog" aria-labelledby="' + id + 'Label" aria-hidden="true">' + '<div class="modal-dialog" role="document">' + '<div class="modal-content">' + '<div class="modal-header">' + modalHeader + '</div>' + '<div class="modal-body"></div>' + '<div class="modal-footer">' + '<button class="btn cancel" data-dismiss="modal" aria-hidden="true"></button>' + '<button class="btn commit"></button>' + '</div>' + '</div>' + '</div>' + '</div>');
    modal.css('z-index', settings.zIndex);
    modal.find('.modal-title').text(options.title || settings.title);
    body = modal.find('.modal-body');
    $.each((options.text || '').split(/\n{2}/), function(i, piece) {
      return body.append($('<p/>').html(piece));
    });
    commit = modal.find('.commit');
    commit.text(options.commit || settings.commit);
    commit.addClass(options.commitClass || settings.commitClass);
    cancel = modal.find('.cancel');
    cancel.text(options.cancel || settings.cancel);
    cancel.addClass(options.cancelClass || settings.cancelClass);
    if (options.remote) {
      commit.attr('data-dismiss', 'modal');
    }
    if (options.verify || options.verifyRegexp) {
      commit.prop('disabled', true);
      isMatch = void 0;
      if (options.verifyRegexp) {
        caseInsensitive = options.verifyRegexpCaseInsensitive;
        regexp = options.verifyRegexp;
        re = new RegExp(regexp, caseInsensitive ? 'i' : '');
        isMatch = function(input) {
          return input.match(re);
        };
      } else {
        isMatch = function(input) {
          return options.verify === input;
        };
      }
      verification = $('<input/>', {
        'type': 'text',
        'class': settings.verifyClass
      }).on('keyup', function() {
        return commit.prop('disabled', !isMatch($(this).val()));
      });
      modal.on('shown.bs.modal', function() {
        return verification.focus();
      });
      modal.on('hidden.bs.modal', function() {
        return verification.val('').trigger('keyup');
      });
      if (options.verifyLabel) {
        body.append($('<p>', {
          text: options.verifyLabel
        }));
      }
      body.append(verification);
    }
    focus_element = void 0;
    if (options.focus) {
      focus_element = options.focus;
    } else if (options.method === 'delete') {
      focus_element = 'cancel';
    } else {
      focus_element = settings.focus;
    }
    focus_element = modal.find('.' + focus_element);
    modal.on('shown.bs.modal', function() {
      return focus_element.focus();
    });
    $('body').append(modal);
    modal.spawn = function() {
      return modal.modal($.extend({}, {
        backdrop: options.backdrop || defaults.backdrop,
        keyboard: options.keyboard || defaults.keyboard,
        show: options.show || defaults.show
      }));
    };
    return modal;
  };

  /**
   * Returns a modal already built for the given element or builds a new one,
   * caching it into the element's `confirm-modal` data attribute.
   */
  getModal = function(element) {
    var modal;
    modal = void 0;
    modal = element.data('confirm-modal');
    if (!modal) {
      modal = buildElementModal(element);
      element.data('confirm-modal', modal);
    }
    return modal;
  };
  $.fn.confirmModal = function() {
    var modal;
    modal = void 0;
    modal = getModal($(this));
    modal.spawn();
    return modal;
  };
  if (window.Rails || $.rails) {

    /**
     * Attaches to Rails' UJS adapter's 'confirm' event, triggered on elements
     * having a `data-confirm` attribute set.
     * If the modal is not visible, then it is spawned and the default Rails
     * confirmation dialog is canceled.
     * If the modal is visible, it means the handler is being called by the
     * modal commit button click handler, as such the user has successfully
     * clicked on the confirm button. In this case Rails' confirm function
     * is briefly overriden, and afterwards reset when the modal is closed.
     */
    window_confirm = window.confirm;
    return $(document).delegate(settings.elements.join(', '), 'confirm', function() {
      var element, modal;
      element = void 0;
      modal = void 0;
      element = $(this);
      modal = getModal(element);
      if (!modal.is(':visible')) {
        modal.spawn();
        return false;
      } else {
        window.confirm = function() {
          return true;
        };
        modal.one('hidden.bs.modal', function() {
          return window.confirm = window_confirm;
        });
        return true;
      }
    });
  }
});
