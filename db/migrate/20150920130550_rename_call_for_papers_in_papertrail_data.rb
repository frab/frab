class RenameCallForPapersInPapertrailData < ActiveRecord::Migration[4.2]
  def up
    PaperTrail::Version.where(item_type: 'CallForPapers').update_all(item_type: 'CallForParticipation')
  end

  def down
    PaperTrail::Version.where(item_type: 'CallForParticipation').update_all(item_type: 'CallForPapers')
  end
end
