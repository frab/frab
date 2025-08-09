
require 'prawn/table'

# Enhanced color palette for event cards
def card_colors
  @card_colors ||= {
    primary: '2563eb',      # Modern blue
    secondary: '64748b',    # Slate gray
    accent: '06b6d4',       # Cyan
    background: 'f8fafc',   # Light gray
    text: '1e293b',         # Dark slate
    border: 'e2e8f0',       # Light border
    white: 'ffffff',
    success: '10b981',      # Green
    warning: 'f59e0b',      # Amber
    error: 'ef4444',        # Red
    purple: '8b5cf6',       # Purple for variety
    pink: 'ec4899'          # Pink for variety
  }
end

def info_table_rows(event)
  room = event.room.try(:name) or ""
  time_str = event.humanized_time_str
  rows = []

  # Clean info rows with better formatting
  rows << [
    { content: "Track: #{event.track.try(:name) || 'General'}", text_color: card_colors[:text] },
    { content: "Type: #{event.event_type}", text_color: card_colors[:primary] }
  ]

  rows << [
    { content: "Language: #{event.language}", text_color: card_colors[:secondary] },
    { content: "Duration: #{format_time_slots(event.time_slots)}", text_color: card_colors[:accent] }
  ]

  if room.present? or time_str.present?
    rows << [
      { content: "Room: #{room}", text_color: card_colors[:success] },
      { content: "Time: #{time_str}", text_color: card_colors[:warning] }
    ]
  end

  rows
end

# Get event color based on type
def event_type_color(event_type)
  case event_type&.downcase
  when 'keynote', 'plenary'
    card_colors[:primary]
  when 'workshop', 'tutorial'
    card_colors[:success]
  when 'lightning'
    card_colors[:warning]
  when 'panel'
    card_colors[:purple]
  when 'demo'
    card_colors[:pink]
  else
    card_colors[:secondary]
  end
end

def add_speakers(columns, event)
  event.speakers.each do |p|
    columns << {text: p.full_name + "\n", size: 12}
    availabilities_in = p.availabilities_in(@conference)

    available_days = availabilities_in.map { |a| a.day }
    (@conference.days -  available_days).each { |d|
      columns << {text: "n/a #{l(d.start_date, format: :short_datetime)}\n", size: 9}
    }

    availabilities = availabilities_in.map { |a| a.humanized_date_range }
    availabilities = availabilities - @conference_days
    columns << {text: availabilities.join("\n")+"\n", size: 9}
  end
end

def add_event_rating(columns, event)
  return unless event.average_rating.present?
  avg_rating = "\nRating: #{event.average_rating.round(2).to_s}\n"
  columns << {text: avg_rating, size: 12}
end

def abstract(event)
  (event.abstract || event.description || "").gsub(/(\r\n|\n)/, " ")
end

prawn_document(page_layout: :landscape) do |pdf|

  pdf.font_families.update("BitStream Vera" => {
    normal: Rails.root.join("vendor", "fonts", "vera.ttf").to_s,
    bold: Rails.root.join("vendor", "fonts", "verabd.ttf").to_s,
    italic: Rails.root.join("vendor", "fonts", "verait.ttf").to_s
  })
  pdf.font "BitStream Vera"

  pdf.define_grid(rows: 2, columns: 2, gutter: 10)

  @conference_days = @conference.days.map { |day| day.humanized_date_range }
  @events = @events.to_a

  (@events.size / 4 + 1).times do

    [[0,0],[0,1],[1,0],[1,1]].each do |coords|

      if event = @events.pop
        event_color = event_type_color(event.event_type)

        pdf.grid(coords[0], coords[1]).bounding_box do
          # Card background with white fill and subtle border
          pdf.fill_color card_colors[:white]
          pdf.stroke_color card_colors[:border]
          pdf.line_width 1
          pdf.rounded_rectangle [0, pdf.bounds.top], pdf.bounds.width, pdf.bounds.height, 8
          pdf.fill_and_stroke

          # Left accent bar instead of top bar - cleaner look
          pdf.fill_color event_color
          pdf.rectangle [0, pdf.bounds.top], 4, pdf.bounds.height
          pdf.fill

          # Card content area - leave space for left accent bar
          pdf.bounding_box([12, pdf.bounds.top - 8], width: pdf.bounds.width - 20, height: pdf.bounds.height - 16) do

            # Title with enhanced styling - leave space for badge
            pdf.fill_color card_colors[:text]
            pdf.font 'BitStream Vera', style: :bold
            title = event.title.truncate(65)  # Shorter to leave space for badge
            pdf.text(title, size: 15, leading: 2, skip_encoding: true)

            # Event ID badge - positioned after title to avoid overlap
            id_text = "##{event.id}"
            # Calculate badge width based on text length
            badge_width = [pdf.width_of(id_text, size: 8) + 8, 35].max  # min 35px width
            badge_x = pdf.bounds.width - badge_width - 2  # 2px margin from right edge
            badge_y = pdf.bounds.top - 2  # 2px from top

            pdf.fill_color card_colors[:background]
            pdf.stroke_color event_color
            pdf.line_width 1
            pdf.rounded_rectangle [badge_x, badge_y], badge_width, 16, 4
            pdf.fill_and_stroke
            pdf.fill_color event_color
            pdf.font 'BitStream Vera', style: :bold
            pdf.text_box id_text, size: 8, at: [badge_x + 4, badge_y - 3],
                        width: badge_width - 8, align: :center

            # Subtitle with better spacing
            if event.subtitle.present?
              pdf.move_down 4
              pdf.fill_color card_colors[:secondary]
              pdf.font 'BitStream Vera', style: :italic
              subtitle = event.subtitle.truncate(60)
              pdf.text(subtitle, size: 12, leading: 1)
            end

            pdf.move_down 8

            # Enhanced Info Table
            info_table = pdf.table(
              info_table_rows(event),
              width: pdf.bounds.width,
              cell_style: {
                align: :left,
                padding: [4, 6],
                border_width: 0.5,
                border_color: card_colors[:border],
                size: 9
              }
            ) do |t|
              t.row(0).style(background_color: card_colors[:background])
              if t.row(1)
                t.row(1).style(background_color: card_colors[:white])
              end
            end

            # Content positioning
            content_top = pdf.cursor - 12

            # Speakers Column with clean styling
            pdf.bounding_box([0, content_top], width: 90, height: content_top - 20) do
              # Speakers header
              pdf.fill_color event_color
              pdf.font 'BitStream Vera', style: :bold
              pdf.text t('col_speakers'), size: 10
              pdf.move_down 3

              # Speaker list
              pdf.fill_color card_colors[:text]
              pdf.font 'BitStream Vera', style: :normal
              event.speakers.each do |speaker|
                pdf.text speaker.full_name, size: 9, leading: 1.5
              end

              # Rating if available
              if event.average_rating.present?
                pdf.move_down 4
                pdf.fill_color card_colors[:warning]
                pdf.font 'BitStream Vera', style: :bold
                pdf.text "Rating: #{event.average_rating.round(1)}/5", size: 8
              end
            end

            # Abstract Column with better typography
            pdf.bounding_box([95, content_top], width: pdf.bounds.width - 95, height: content_top - 20) do
              # Abstract header
              pdf.fill_color event_color
              pdf.font 'BitStream Vera', style: :bold
              pdf.text t('col_abstract'), size: 10
              pdf.move_down 3

              # Abstract content
              pdf.fill_color card_colors[:text]
              pdf.font 'BitStream Vera', style: :normal
              abstract_text = abstract(event)
              pdf.text abstract_text,
                size: 9,
                align: :left,
                leading: 1.5,
                skip_encoding: true
            end
          end

        end
      end

    end

    pdf.start_new_page unless @events.empty?

  end

end
