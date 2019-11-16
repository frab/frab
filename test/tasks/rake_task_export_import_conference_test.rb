require 'test_helper'
require 'rake'

class RakeTaskExportImportConferenceTest < ActiveSupport::TestCase

  describe 'frab:conference_export_import' do

    NEW_ACRONYM = 'imported'.freeze
    
    def setup
      # Create a conference with an attachment
      @conf = create :three_day_conference_with_events
      @conf.update_attributes(attachment_title_is_freeform: false)
    
      @event=@conf.events.first
    
      upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'textfile.txt'), 'text/plain')
      @event.update_attributes( event_attachments_attributes: { 'xx' => { 'title' => 'proposal', 'attachment' => upload } })
    
      FileUtils.rm_rf('tmp/frab_export')
    
      # Run frab:conference_export
      Frab::Application.load_tasks if Rake::Task.tasks.empty?
      ENV['CONFERENCE']=@conf.acronym
      Rake::Task["frab:conference_export"].invoke
    
      # Edit the export file to use a different acronym and title
      # otherwise it would not import
      data = YAML.load_file "tmp/frab_export/conference.yaml"
      data["acronym"] = NEW_ACRONYM
      data["title"] = "NewTitle"
      File.open("tmp/frab_export/conference.yaml", 'w') { |f| YAML.dump(data, f) }
    
      # Run frab:conference_import
      Rake::Task["frab:conference_import"].invoke
    end
    
    def teardown
      @conf.destroy
      @new_conf.destroy
    end
    
    it "should export and import correctly" do
      @new_conf = Conference.find_by(acronym: NEW_ACRONYM)
      assert @new_conf, "imported successfully"
    
      assert @new_conf.events.count == @conf.events.count, "all events restored"
    
      assert( @conf.events.joins(:event_attachments).pluck(:title, :attachment_file_name, :attachment_file_size) ==
              @new_conf.events.joins(:event_attachments).pluck(:title, :attachment_file_name, :attachment_file_size) ,
              "all event attachments restored" )
    
      conf_attrs = @conf.attributes
      new_conf_attrs = @new_conf.attributes
    
      attributes_to_compare = conf_attrs.keys
      attributes_to_compare -= [ "id" ] # Updated during re-import
      attributes_to_compare -= [ "acronym", "title" ] # Updated by this test
      attributes_to_compare -= [ "created_at", "updated_at" ] # Modified to import time
    
      attributes_to_compare.each { |attr|
        original = conf_attrs[attr]
        imported = new_conf_attrs[attr]
        assert original == imported, "conference #{attr} should be identical. original is #{original} ; imported is #{imported}"
      }
    end
  end
end