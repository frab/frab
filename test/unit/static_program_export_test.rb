require 'test_helper'

class StaticProgramExportTest < ActiveSupport::TestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @locale = 'en'
    @target_dir = File.join(Rails.root, 'tmp', 'static_export')
  end

  test "static exporter can create a tarball" do
    FileUtils.mkdir_p File.join(@target_dir, @conference.acronym)
    exporter = StaticProgramExport.new(@conference, @locale, @target_dir)
    assert_equal exporter.create_tarball, File.join(@target_dir, @conference.acronym + '-en.tar.gz')
  end

  test "static exporter can run export" do
    exporter = StaticProgramExport.new(@conference, @locale, @target_dir)
    exporter.run_export
    assert File.directory? File.join(@target_dir, @conference.acronym)
  end

  teardown do
    FileUtils.remove_dir File.join(@target_dir, @conference.acronym)
  end
end
