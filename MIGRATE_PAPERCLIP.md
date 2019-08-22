# Migrate From Paperclip


## Apply the ActiveStorage database migrations.

    rails db:migrate


## Configure storage.

Frab data migration is only supported for ActiveStorage's DiskService.

## Copy the database data over.

    bin/paperclip_copy_table.rb

## Copy the files over.

    bin/paperclip_copy_assets.rb


## TODO

* eager loading:   @users = User.all.order(:name).includes(avatar_attachment: :blob)
* validations
* tests
* views
