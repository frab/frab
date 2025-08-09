require 'test_helper'

class StaticSchedulePdfTest < ActiveSupport::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers, program_export_base_url: 'http://localhost:3000')
  end

  test 'ProgramRenderer initializes correctly' do
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')

    assert_not_nil renderer
    assert_equal @conference, renderer.instance_variable_get(:@conference)
    assert_equal 'en', renderer.instance_variable_get(:@locale)
  end

  test 'ProgramRenderer view_model returns ScheduleViewModel' do
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')
    view_model = renderer.view_model

    assert_instance_of ScheduleViewModel, view_model
    assert_equal @conference, view_model.instance_variable_get(:@conference)
  end

  test 'ProgramRenderer base_url generation works' do
    @conference.update!(program_export_base_url: 'https://example.com/path')
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')

    assert_equal '/path/', renderer.base_url
  end

  test 'ProgramRenderer base_url handles URLs without trailing slash' do
    @conference.update!(program_export_base_url: 'https://example.com/path')
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')

    assert_equal '/path/', renderer.base_url
    assert renderer.base_url.end_with?('/'), "Base URL should end with slash"
  end

  test 'ProgramRenderer defaults method sets correct assigns' do
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')

    assigns = renderer.send(:defaults, {custom: 'value'})

    assert_equal @conference, assigns[:conference]
    assert_instance_of ScheduleViewModel, assigns[:view_model]
    assert_equal 'value', assigns[:custom]
  end

  test 'ProgramRenderer setup_renderer creates controller renderer' do
    renderer = StaticSchedule::ProgramRenderer.new(@conference, 'en')
    controller_renderer = renderer.instance_variable_get(:@renderer)

    assert_not_nil controller_renderer
    # Verify it has the expected environment setup
    env = controller_renderer.instance_variable_get(:@env)
    assert_equal @conference.acronym, env['action_dispatch.request.path_parameters'][:conference_acronym]
    assert_equal 'en', env['action_dispatch.request.path_parameters'][:locale]
  end

  test 'ProgramRenderer works with different locales' do
    %w[en de fr].each do |locale|
      renderer = StaticSchedule::ProgramRenderer.new(@conference, locale)

      assert_equal locale, renderer.instance_variable_get(:@locale)

      # Test that the renderer environment is set up correctly
      controller_renderer = renderer.instance_variable_get(:@renderer)
      env = controller_renderer.instance_variable_get(:@env)
      assert_equal locale, env['action_dispatch.request.path_parameters'][:locale]
    end
  end
end
