class UpdateMailTemplateContent < ActiveRecord::Migration[5.2]
  MIGRATION = { '#first_name' => '%{forename}',
                '#last_name' => '%{surname}',
                '#public_name' => '%{public_name}' }
                
  def change
    reversible do |dir|
      migration_dict=MIGRATION
      dir.up do
        @migration_dict=MIGRATION
      end
      dir.down do
        @migration_dict=MIGRATION.invert
      end
      
      MailTemplate.all.each do |mail_template|
        s = mail_template.content
        @migration_dict.each do |from, to|
          s.gsub!(from, to)
        end
        mail_template.update_attributes!(content: s)
      end
    end  
  end
end
