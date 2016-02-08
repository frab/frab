# source: https://gist.github.com/jessecurry/6226080
namespace :paperclip_migration do
  desc 'Migrate paperclip storage to 3.x layout'

  task migrate: :environment do
    # Make sure that all of the models have been loaded so any attachments are registered
    puts 'Loading models...'
    Dir[Rails.root.join('app', 'models', '**/*')].each { |file| File.basename(file, '.rb').camelize.constantize }

    # Iterate through all of the registered attachments
    attachment_registry.each_definition do |klass, name, _options|
      puts "Migrating #{klass}: #{name}"
      klass.find_each(batch_size: 100) do |instance|
        attachment = instance.send(name)

        next if attachment.blank?

        if attachment.styles.empty?
          old_path = interpolator.interpolate(old_path_option, attachment, 'original')
          new_path = interpolator.interpolate(new_path_option, attachment, 'original')
          local_move(old_path, new_path)
        else
          styles = attachment.styles.keys + [:original]
          styles.each do |style_name|
            old_path = interpolator.interpolate(old_path_option, attachment, style_name)
            new_path = interpolator.interpolate(new_path_option, attachment, style_name)
            local_move(old_path, new_path)
          end
        end
      end
    end
  end

  #############################################################################

  private

  # Paperclip Configuration
  def attachment_registry
    Paperclip::AttachmentRegistry
  end

  def interpolator
    Paperclip::Interpolations
  end

  def old_path_option
    ':rails_root/public/system/:attachment/:id/:style/:filename'
  end

  def new_path_option
    ':rails_root/public/system/:class/:attachment/:id_partition/:style/:filename'
  end

  def local_move(old_path, new_path)
    unless File.readable?(old_path)
      STDERR.puts "missing #{old_path}, skipping!"
      return
    end
    FileUtils.mkdir_p(File.dirname(new_path))
    FileUtils.mv(old_path, new_path)
  end
end
