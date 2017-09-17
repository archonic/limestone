const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Get a pre-configured plugin
environment.plugins.get('ProvidePlugin')

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.set(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    'jquery': 'jquery',
    Popper: ['popper.js', 'default']
  })
)

module.exports = environment
