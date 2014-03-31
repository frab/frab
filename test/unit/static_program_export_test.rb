require 'test_helper'

class StaticProgramExportTest < ActiveSupport::TestCase
  setup do
    @conference = create(:three_day_conference)
    @locale = 'en'
    @target_dir = File.join(Rails.root, 'tmp', 'static_export', @conference.acronym)
  end

  test "static exporter can create a tarball" do
    exporter = StaticProgramExport.new(@conference, @locale)
    FileUtils.mkdir_p File.join(StaticProgramExport::EXPORT_PATH, @conference.acronym)
    assert_equal exporter.create_tarball, File.join(Rails.root, 'tmp', 'static_export', @conference.acronym + '-en.tar.gz')
  end

  test "static exporter can run export" do
    exporter = StaticProgramExport.new(@conference, @locale)
    exporter.run_export
    assert File.directory? @target_dir
  end

  teardown do
    FileUtils.remove_dir @target_dir
  end
end
