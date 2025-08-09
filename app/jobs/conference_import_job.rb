class ConferenceImportJob
  include SuckerPunch::Job

  def perform(import_dir, user_id)
    user = User.find(user_id)
    cache_key = "conference_import_#{user_id}"

    begin
      # Update progress: Starting
      Rails.cache.write(cache_key, {
        status: 'in_progress',
        progress: 10,
        message: 'Starting conference import...'
      }, expires_in: 1.hour)

      # Check if import directory exists and contains required files
      unless File.directory?(import_dir)
        raise "Import directory not found: #{import_dir}"
      end

      # Look for the extracted frab export directory
      frab_export_dir = find_frab_export_dir(import_dir)

      Rails.cache.write(cache_key, {
        status: 'in_progress',
        progress: 30,
        message: 'Validating conference data...'
      }, expires_in: 1.hour)

      # Run the actual import using ImportExportHelper
      require 'import_export_helper.rb'
      helper = ImportExportHelper.new

      Rails.cache.write(cache_key, {
        status: 'in_progress',
        progress: 50,
        message: 'Importing conference data...'
      }, expires_in: 1.hour)

      # Capture output for logging
      original_stdout = $stdout
      $stdout = StringIO.new

      helper.run_import(frab_export_dir)

      output = $stdout.string
      $stdout = original_stdout

      Rails.cache.write(cache_key, {
        status: 'in_progress',
        progress: 90,
        message: 'Finalizing import...'
      }, expires_in: 1.hour)

      # Clean up temporary files
      FileUtils.rm_rf(import_dir)

      # Success
      Rails.cache.write(cache_key, {
        status: 'completed',
        progress: 100,
        message: 'Conference import completed successfully!'
      }, expires_in: 1.hour)

      Rails.logger.info "Conference import completed for user #{user_id}. Output: #{output}"

    rescue => e
      Rails.logger.error "Conference import failed for user #{user_id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Clean up on error
      FileUtils.rm_rf(import_dir) if import_dir && File.directory?(import_dir)

      # Provide user-friendly error messages
      user_message = case e.message
      when /conference .* already exists/i, /Conference .* already exists/i
        "Import failed: A conference with this name already exists. Please rename the existing conference first or choose a different export."
      when /Could not find frab export data/i
        "Import failed: The uploaded file doesn't appear to contain valid frab export data. Please ensure you're uploading a tarball created with TARBALL=true."
      when /Import directory.*does not exist/i
        "Import failed: The uploaded file could not be extracted properly. Please ensure it's a valid .tar.gz file created with TARBALL=true."
      when /No such file or directory.*tar/i
        "Import failed: The uploaded file appears to be corrupted or is not a valid tarball format."
      when /callback.*has not been defined/i
        "Import failed: There was an issue with the data validation callbacks. This is likely a temporary issue - please try again."
      when /Validation.*failed/i
        "Import failed: The conference data contains invalid or missing required information (#{e.message.gsub(/Validation.*failed: /, '')}). This may be due to differences between frab versions or incomplete export data."
      when /can't be blank/i
        "Import failed: Required fields are missing in the conference data. This may be due to differences between frab versions or data export issues."
      else
        "Import failed: #{e.message}"
      end

      Rails.cache.write(cache_key, {
        status: 'error',
        progress: 0,
        message: user_message
      }, expires_in: 1.hour)

      raise e
    ensure
      $stdout = original_stdout if original_stdout
    end
  end

  private

  def find_frab_export_dir(import_dir)
    # Look for common patterns in extracted tarball
    possible_dirs = [
      File.join(import_dir, 'frab_export'),
      File.join(import_dir, 'tmp/frab_export'),
      import_dir # Sometimes the tarball extracts directly
    ]

    # Also check subdirectories for frab_export
    Dir.glob(File.join(import_dir, '**/frab_export')).each do |dir|
      possible_dirs << dir
    end

    # Find the directory that contains conference.yaml
    possible_dirs.each do |dir|
      if File.exist?(File.join(dir, 'conference.yaml'))
        return dir
      end
    end

    # If no conference.yaml found, try any directory with .yaml files
    Dir.glob(File.join(import_dir, '**/*.yaml')).each do |yaml_file|
      dir = File.dirname(yaml_file)
      if File.basename(yaml_file) == 'conference.yaml'
        return dir
      end
    end

    raise "Could not find frab export data in the uploaded tarball. Expected to find conference.yaml file."
  end
end
