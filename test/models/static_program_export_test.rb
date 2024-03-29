require 'test_helper'

class StaticSchedule::ExportText < ActiveSupport::TestCase
  setup do
    @conference = create(:three_day_conference_with_events,
                        program_export_base_url: '/')
    @locale = 'en'
    @target_dir = Dir.mktmpdir('frab_static_export')
  end

  test 'static exporter can create a tarball' do
    FileUtils.mkdir_p File.join(@target_dir, @conference.acronym)
    exporter = StaticSchedule::Export.new(@conference, @locale, @target_dir)
    assert_equal exporter.create_tarball, File.join(@target_dir, @conference.acronym + '-en.tar.gz')
  end

  test 'static exporter can run export' do
    exporter = StaticSchedule::Export.new(@conference, @locale, @target_dir)
    exporter.run_export
    assert File.directory? File.join(@target_dir, @conference.acronym)
  end

  teardown do
    FileUtils.remove_entry_secure @target_dir if @target_dir
  end
end
