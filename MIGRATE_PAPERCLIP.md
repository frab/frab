# Migrate From Paperclip


## Apply the ActiveStorage database migrations.

    rails db:migrate


## Configure storage.

Frab data migration is only supported for ActiveStorage's DiskService.

## Copy the database data over.

    bin/paperclip_copy_table.rb

## Copy the files over.

    bin/paperclip_copy_assets.rb
