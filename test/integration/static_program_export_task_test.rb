require 'test_helper'

class StaticProgramExportTask < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @target_dir = File.join(Rails.root, 'tmp', 'static_export')
  end

  test 'can run program export task' do
    skip("defining rake task does not work. need to rewrite export task anyways.")
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
    dir = File.join(@target_dir, @conference.acronym)
    FileUtils.remove_dir(dir) if File.exist?(dir)
  end
end
