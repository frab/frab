#!bin/rails runner

require 'open-uri'
Dir[Rails.root.join('app', 'models', '**/*')].each { |file| File.basename(file, '.rb').camelize.constantize }



def key(instance, attachment)
  SecureRandom.uuid
  # Alternatively:
  # instance.send("#{attachment}_file_name")
end

def checksum(attachment)
  Digest::MD5.base64digest(attachment.download)
end

get_blob_id = case ActiveRecord::Base.connection.class.to_s
              when 'ActiveRecord::ConnectionAdapters::SQLite3Adapter'
                'LAST_INSERT_ROWID()'
              when 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
                'LASTVAL()'
              else
                'LAST_INSERT_ID()'
              end

active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
      INSERT INTO active_storage_blobs (
        `key`, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES (?, ?, ?, '{}', ?, ?, ?)
SQL

active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES (?, ?, ?, #{get_blob_id}, ?)
SQL

models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

ActiveRecord::Base.transaction do
  models.each do |model|
    attachments = model.column_names.map do |c|
      if c =~ /(.+)_file_name$/
        $1
      end
    end.compact

    model.find_each.each do |instance|
      attachments.each do |attachment|
        next unless instance.send("#{attachment}_file_name")
        p "copying attachment #{attachment} of #{model}##{instance.id}"
        active_storage_blob_statement.execute(
          key(instance, attachment),
          instance.send("#{attachment}_file_name"),
          instance.send("#{attachment}_content_type"),
          instance.send("#{attachment}_file_size"),
          checksum(instance.send(attachment)),
          instance.updated_at.iso8601
        )

        active_storage_attachment_statement.
          execute(attachment, model.name, instance.id, instance.updated_at.iso8601)
      end
    end
  end
end

active_storage_attachment_statement.close
active_storage_blob_statement.close
