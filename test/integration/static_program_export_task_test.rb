require 'test_helper'

class StaticProgramExportTask < ActionDispatch::IntegrationTest

  setup do
    @conference = create(:three_day_conference)
    @target_dir = File.join(Rails.root, 'tmp', 'static_export', @conference.acronym)
  end

  test "can run program export task" do
    locale = 'en'
    
    load File.join(Rails.root, 'lib', 'tasks', 'static_program_export.rake')
    Rake::Task.define_task(:environment)
    ENV['CONFERENCE'] = @conference.acronym
    ENV['CONFERENCE_LOCALE'] = locale
    ENV['RAILS_ENV'] = Rails.env
    Rake.application.invoke_task "frab:static_program_export"

    assert File.directory? @target_dir
  end

  teardown do
    FileUtils.remove_dir @target_dir
  end
end
