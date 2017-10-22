require 'test_helper'

class StaticProgramExportJobTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @conference = create(:three_day_conference_with_events_and_speakers,
                         program_export_base_url: '/')
  end

  test 'exports conference as tarball' do
    StaticProgramExportJob.new.perform(@conference, 'en')
    assert_equal 1, ConferenceExport.count
    assert ConferenceExport.last.tarball.size > 45
  end
end
