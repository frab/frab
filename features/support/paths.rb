module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the (.*) cfp home page/
      cfp_root_path(:conference_acronym => $1)
    when /the (.*) cfp sign in page/
      new_cfp_user_session_path(:conference_acronym => $1)
    when /an open cfp's home page/
      cfp = CallForPapers.make!
      cfp_root_path(:conference_acronym => cfp.conference.acronym)
    when /an open cfp's event submission page/
      cfp = CallForPapers.make!
      new_cfp_event_path(:conference_acronym => cfp.conference.acronym)
    when /login/
      '/users/sign_in'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
