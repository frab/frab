module ActionView
  module Helpers
    module FormTagHelper
      
      def submit_tag(value = "Save changes", options = {})
        options.stringify_keys!

        if disable_with = options.delete("disable_with")
          options["data-disable-with"] = disable_with
        end

        if confirm = options.delete("confirm")
          add_confirm_to_attributes!(options, confirm)
        end

        content_tag :button, value, { "type" => "submit", "name" => "commit", "value" => value }.update(options.stringify_keys)
      end

    end
  end
end
