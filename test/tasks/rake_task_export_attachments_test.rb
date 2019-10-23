require 'test_helper'
require 'rake'

class RakeTaskExportAttachmentsTest < ActiveSupport::TestCase

  describe 'frab:conference_export_attachments' do

    def setup
      # Create a conference with an attachment
      @conference = create :three_day_conference_with_events
      @conference.update_attributes(attachment_title_is_freeform: false)

      @event=@conference.events.first
      
      upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'textfile.txt'), 'text/plain')
      @event.update_attributes( event_attachments_attributes: { 'xx' => { 'title' => 'proposal', 'attachment' => upload } })

      # Run frab:conference_export_attachments
      Frab::Application.load_tasks if Rake::Task.tasks.empty?
      ENV['CONFERENCE']=@conference.acronym
      Rake::Task["frab:conference_export_attachments"].invoke

    end
    
    def teardown
      @conference.destroy
    end

    it "should export attachments" do
      assert File.file?("tmp/attachments/#{@conference.acronym}/trackless_proposal.tgz")
    end

  end
end
