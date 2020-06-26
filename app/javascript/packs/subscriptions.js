var addFieldToPaymentForm, stripeTokenHandler;

stripeTokenHandler = function(token) {
  var form, hiddenInput;
  form = document.getElementById('payment_form');
  hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);
  ['brand', 'exp_month', 'exp_year', 'last4'].forEach(function(field) {
    return addFieldToPaymentForm(form, token, field);
  });
  return form.submit();
};

addFieldToPaymentForm = function(form, token, field) {
  var hiddenInput;
  hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'card_' + field);
  hiddenInput.setAttribute('value', token.card[field]);
  return form.appendChild(hiddenInput);
};

document.addEventListener('turbolinks:load', function() {
  var card, elements, form, public_key, stripe, style;
  if (document.querySelector('#card-element') !== null) {
    public_key = document.querySelector('meta[name=\'stripe-public-key\']').content;
    stripe = Stripe(public_key);
    elements = stripe.elements();
    style = {
      base: {
        fontSize: '16px',
        color: '#32325d'
      }
    };
    card = elements.create('card', {
      style: style
    });
    card.mount('#card-element');
    card.addEventListener('change', function(event) {
      var displayError;
      displayError = document.getElementById('card-errors');
      if (event.error) {
        return displayError.textContent = event.error.message;
      } else {
        return displayError.textContent = '';
      }
    });
    form = document.getElementById('payment_form');
    return form.addEventListener('submit', function(event) {
      event.preventDefault();
      return stripe.createToken(card).then(function(result) {
        var errorElement;
        if (result.error) {
          errorElement = document.getElementById('card-errors');
          return errorElement.textContent = result.error.message;
        } else {
          return stripeTokenHandler(result.token);
        }
      });
    });
  }
});
