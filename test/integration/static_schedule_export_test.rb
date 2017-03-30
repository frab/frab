require 'test_helper'

class StaticScheduleExportTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @target_dir = Rails.root.join('tmp', 'static_export')
  end

  test 'can run program export task' do
    locale = 'en'
    StaticSchedule::Export.new(@conference, locale, @target_dir).run_export

    dir = Pathname.new(@target_dir).join(@conference.acronym)
    assert File.directory? dir
    assert File.readable? dir.join('events.html')
    assert_includes File.read(dir.join('index.html')), 'Day 3'
    assert_includes File.read(dir.join('style.css')), '.cell-height1'
    assert_includes File.read(dir.join('events.html')), 'Introducing frap'
    assert_includes File.read(dir.join('schedule/1.html')), 'Introducing frap'
    assert_includes File.read(dir.join('events/1.html')), 'Introducing frap'
    assert_includes File.read(dir.join('speakers/1.html')), 'Introducing frap'
  end

  teardown do
    dir = File.join(@target_dir, @conference.acronym)
    FileUtils.remove_dir(dir) if File.exist?(dir)
  end
end
