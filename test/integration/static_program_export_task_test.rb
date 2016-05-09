require 'test_helper'

class StaticProgramExportTask < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @target_dir = File.join(Rails.root, 'tmp', 'static_export')
  end

  test 'can run program export task' do
    locale = 'en'

    load File.join(Rails.root, 'lib', 'tasks', 'static_program_export.rake')
    Rake::Task.define_task(:environment)
    ENV['CONFERENCE'] = @conference.acronym
    ENV['CONFERENCE_LOCALE'] = locale
    ENV['CONFERENCE_DIR'] = @target_dir
    ENV['RAILS_ENV'] = Rails.env
    Rake.application.invoke_task 'frab:static_program_export'

    assert File.directory? File.join(@target_dir, @conference.acronym)
  end

  teardown do
    FileUtils.remove_dir File.join(@target_dir, @conference.acronym)
  end
end
