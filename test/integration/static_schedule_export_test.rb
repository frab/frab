require 'test_helper'

class StaticScheduleExportTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers,
                         program_export_base_url: '/')
    @target_dir = Rails.root.join('tmp', 'static_export')
    @dir = Pathname.new(@target_dir).join(@conference.acronym)
  end

  test 'can run program export task' do
    StaticSchedule::Export.new(@conference, 'en', @target_dir).run_export

    assert File.directory? @dir
    assert File.readable? @dir.join('events.html')
    assert_includes File.read(@dir.join('index.html')), 'Day 3'
    assert_includes File.read(@dir.join('style.css')), '.cell-height1'
    assert_includes File.read(@dir.join('public_schedule.css')), 'article, '
    assert_includes File.read(@dir.join('events.html')), 'Introducing frap'
    assert_includes File.read(@dir.join('schedule/1.html')), 'Introducing frap'
    event = @conference.events.first
    assert_includes File.read(@dir.join("events/#{event.id}.html")), 'Introducing frap'
    speaker = event.speakers.first
    assert_includes File.read(@dir.join("speakers/#{speaker.id}.html")), 'Introducing frap'
  end

  test 'works for sub conference' do
    conference = @conference.subs.first
    conference.rooms << create(:room, conference: conference)
    conference.events << create(:event, conference: conference,
                                room: conference.rooms.first,
                                state: 'confirmed',
                                public: true,
                                start_time: conference.start_date)
    event = conference.events.last
    StaticSchedule::Export.new(@conference, 'en', @target_dir).run_export
    assert_includes File.read(@dir.join("events/#{event.id}.html")), 'Introducing frap'
  end

  teardown do
    FileUtils.remove_dir(@dir) if File.exist?(@dir)
  end
end
