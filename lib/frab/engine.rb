module Frab
  class Engine < Rails::Engine
    engine_name "frab"

    initializer "frab.precompile_assets" do
      Rails.application.config.assets.precompile += ['frab.css', 'frab.js', 'admin.css', 'admin.js', 'schedule.js', 'public_schedule.css', 'public_schedule_print.css', 'public_schedule.js']
    end
  end
end
