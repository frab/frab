# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images', 'colorpicker')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images', 'icons')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images', 'images')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images', 'raty')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += [
  'admin.css', 'admin.js', 'schedule.js', 'person_filter.js' , 'public_schedule.css', 'public_schedule_print.css', 'moment.min.js', 
  /\.(?:jpg|png|gif)/
]
