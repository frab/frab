module StaticSchedule
  class Pages
    def initialize(renderer, conference)
      @renderer = renderer
      @conference = conference
      @paths = []
    end

    def all
      standard
      days
      events
      speakers
      @paths
    end

    private

    def standard
      @paths = [
        { action: :index, target: 'index.html' },
        { action: :style, format: :css, target: 'style.css' },
        { action: :events, target: 'events.html' },
        { action: :events, format: :json, target: 'events.json' },
        { action: :speakers, target: 'speakers.html' },
        { action: :speakers, format: :json, target: 'speakers.json' },
        { action: :index, format: :ics, target: 'schedule.ics' },
        { action: :index, format: :xcal, target: 'schedule.xcal' },
        { action: :index, format: :json, target: 'schedule.json' },
        { action: :index, format: :xml, target: 'schedule.xml' }
      ]
    end

    def days
      day_index = 1
      @conference.days.each do |day|
        if day.rooms.present?
          @paths << { action: :day, assigns: { day: day }, target: "schedule/#{day_index}.html" }
          @paths << {
            action: :day,
            template: 'schedule/custom_pdf.pdf.prawn',
            format: :prawn,
            assigns: { day: day, layout: CustomPDF::FullPageLayout.new('A4') },
            target: "schedule/#{day_index}.pdf"
          }
        end
        day_index += 1
      end
      []
    end

    def events
      @conference.events.is_public.confirmed.scheduled.each do |event|
        @paths << {
          action: :event,
          assigns: { view_model: @renderer.view_model.for_event(event.id) },
          target: "events/#{event.id}.html"
        }
        @paths << {
          action: :event,
          format: :ics,
          assigns: { view_model: @renderer.view_model.for_event(event.id) },
          target: "events/#{event.id}.ics"
        }
      end
    end

    def speakers
      Person.publicly_speaking_at(@conference).confirmed(@conference).each do |speaker|
        @paths << {
          action: :speaker,
          assigns: { view_model: @renderer.view_model.for_speaker(speaker.id) },
          target: "speakers/#{speaker.id}.html"
        }
      end
    end
  end
end
