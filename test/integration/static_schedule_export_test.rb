require 'test_helper'
require 'tmpdir'

class StaticScheduleExportTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers,
                         program_export_base_url: '/')
    @target_dir = Dir.mktmpdir('frab_static_export')
    @dir = Pathname.new(@target_dir).join(@conference.acronym)
  end

  test 'can run program export task' do
    StaticSchedule::Export.new(@conference, 'en', @target_dir).run_export

    assert File.directory? @dir
    assert File.readable? @dir.join('events.html')
    index_content = File.read(@dir.join('index.html'))
    # Check that we have content for the third day by looking for day sections
    assert index_content.scan(/id="day-\d+"/).length >= 3, "Should have at least 3 day sections"
    assert_includes File.read(@dir.join('style.css')), '--conference-color'
    assert_includes File.read(@dir.join('events.html')), 'Introducing frap'
    assert_includes File.read(@dir.join('schedule/1.html')), 'Introducing frap'
    event = @conference.events.first
    assert_includes File.read(@dir.join("events/#{event.id}.html")), 'Introducing frap'
    speaker = event.speakers.first
    assert_includes File.read(@dir.join("speakers/#{speaker.id}.html")), 'Introducing frap'
  end

  test 'exports localized schedule' do
    StaticSchedule::Export.new(@conference, 'de', @target_dir).run_export
    index_content = File.read(@dir.join('index.html'))
    # Check that we have content for the third day by looking for day sections
    assert index_content.scan(/id="day-\d+"/).length >= 3, "Should have at least 3 day sections in German"
    assert_includes File.read(@dir.join('events.html')), 'ReferentInnen'
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

  test 'rewrites absolute asset urls in css' do
    export = StaticSchedule::Export.new(@conference, 'en', @target_dir)
    css = '@font-face{src:url(/assets/icons-abc123.woff2) format("woff2"),' \
          'url("/assets/icons-abc123.woff") format("woff")}'

    rewritten, referenced = export.send(:rewrite_css_urls, css)

    assert_equal '@font-face{src:url(icons-abc123.woff2) format("woff2"),' \
                 'url("icons-abc123.woff") format("woff")}', rewritten
    assert_equal %w[assets/icons-abc123.woff2 assets/icons-abc123.woff], referenced
  end

  test 'copies assets referenced by css and makes their urls relative' do
    assets_dir = Rails.root.join('public', 'assets')
    FileUtils.mkdir_p(assets_dir)
    css_file = assets_dir.join('frab-test-export.css')
    font_file = assets_dir.join('frab-test-export.woff2')
    File.write(css_file, 'src:url(/assets/frab-test-export.woff2)')
    File.write(font_file, 'fake font')

    export = StaticSchedule::Export.new(@conference, 'en', @target_dir)
    export.instance_variable_set(:@base_directory, @dir.to_s)
    export.instance_variable_set(:@asset_paths, ['assets/frab-test-export.css'])
    export.send(:copy_stripped_assets)

    assert_equal 'src:url(frab-test-export.woff2)',
                 File.read(@dir.join('assets/frab-test-export.css'))
    assert File.exist?(@dir.join('assets/frab-test-export.woff2'))
  ensure
    FileUtils.rm_f([css_file, font_file].compact)
  end

  teardown do
    FileUtils.remove_entry_secure @target_dir if @target_dir
  end
end
