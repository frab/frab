require 'test_helper'

class ConferenceExportTest < ActiveSupport::TestCase
  test 'can create a conference export' do
    conference_export = FactoryGirl.create :conference_export
    assert_not_nil conference_export.tarball
    assert File.readable? conference_export.tarball.path
    assert_not_nil conference_export.conference
    assert_not_nil conference_export.id
  end

  test 'can update a conference export attachment' do
    file = File.open(File.join(Rails.root, 'test', 'fixtures', 'tarball.tar.gz'))
    conference_export = FactoryGirl.create :conference_export, tarball: file
    conference_export.save
    assert File.readable? conference_export.tarball.path
  end

  test 'can update conference export with tarball' do
    conference = FactoryGirl.create(:three_day_conference)
    locale = 'en'
    file = File.join(Rails.root, 'test', 'fixtures', 'tarball.tar.gz')

    assert_difference 'ConferenceExport.count' do
      conference_export = ConferenceExport.where(conference_id: conference.id, locale: locale).first_or_create
      conference_export.update_attributes tarball: File.open(file)
    end
    conference_export = ConferenceExport.where(conference_id: conference.id, locale: locale).first
    assert_not_nil conference_export.tarball
  end
end
