# frozen_string_literal: true
require 'prawn/measurement_extensions'
require 'prawn/table'

def room_table_data(rooms)
  table_data = []
  table_data << [''] + rooms.map(&:name)
  each_timeslot do |time|
    row = []
    row << l(time, format: :time)
    rooms.size.times { row << '' }
    table_data << row
  end

  table_data
end

def header_content_left
  @day.humanized_date_range(:month_datetime)
end

def header_content_center
  @conference.acronym
end

def header_content_right
  @conference.schedule_version
end

prawn_document(
  page_layout: @orientation,
  page_size: @layout.page_size
) do |pdf|
  pdf.font_families.update('BitStream Vera' => {
                             normal: Rails.root.join('vendor', 'fonts', 'vera.ttf').to_s,
                             bold: Rails.root.join('vendor', 'fonts', 'verabd.ttf').to_s,
                             italic: Rails.root.join('vendor', 'fonts', 'verait.ttf').to_s
                           })
  pdf.font 'BitStream Vera'

  @layout.bounds = pdf.bounds

  number_of_columns = [ @view_model.rooms.size, @rooms_per_page ].min
  number_of_pages = (@view_model.rooms.size / number_of_columns.to_f).ceil.to_i
  column_width = @layout.page_width / number_of_columns
  timeslot_height = @layout.timeslot_height(number_of_timeslots)


  # A page contains the full time range. New pages will
  # contain further rooms.
  number_of_pages.times do |current_page|
    offset = current_page * number_of_columns

    # Enhanced date visibility
    pdf.fill_color '2563eb'  # Blue background for date
    date_text = header_content_left
    date_width = pdf.width_of(date_text, size: 12) + 16
    box_x = @layout.header_left_anchor[0] - 4
    box_y = @layout.header_left_anchor[1] + 8
    pdf.rounded_rectangle [box_x, box_y], date_width, 20, 4
    pdf.fill

    # Date text centered in the blue box
    pdf.fill_color 'ffffff'
    pdf.font 'BitStream Vera', style: :bold
    text_x = box_x + (date_width - pdf.width_of(date_text, size: 12)) / 2
    text_y = box_y - 14  # Vertically centered in 20px box
    pdf.draw_text date_text, size: 12, at: [text_x, text_y]

    # Reset and draw other header elements
    pdf.fill_color '000000'
    pdf.font 'BitStream Vera', style: :normal
    pdf.draw_text header_content_center, size: 16, at: @layout.header_center_anchor
    pdf.draw_text header_content_right, size: 9, at: @layout.header_right_anchor

    rooms = @view_model.rooms[offset..(offset + number_of_columns - 1)]
    table_data = room_table_data(rooms)

    table = pdf.make_table(table_data) do |t|
      t.cells.style(border_width: 1.pt, border_color: 'cccccc')
      t.row(0).height = @layout.header_height
      t.row(0).align = :center
      t.row(0).font_style = :bold
      t.row(0).style(size: 10)
      t.column(0).width = @layout.margin_width - 1
      t.rows(1..-1).style(size: 4)
      t.rows(1..-1).height = timeslot_height
      t.rows(1..-1).padding = 3
      t.rows(1..-1).align = :right
      t.columns(1..-1).width = column_width
    end

    table.draw
    offset = pdf.bounds.height - table.height

    # draw start time column
    events = @view_model.events_by_room(rooms[0])
    events.each do |event|
      y = (timeslots_between(event.start_time, @day.end_date) - 1) * timeslot_height
      y += offset
      coord = [0, y]
      pdf.bounding_box(coord,
                       width: @layout.margin_width - 1,
                       height: (event.time_slots == 0 ? timeslot_height : event.time_slots * timeslot_height - 1)) do
        pdf.rounded_rectangle(pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3)
        pdf.fill_color = 'ffffff'
        pdf.fill_and_stroke
        pdf.fill_color = '000000'
        pdf.text_box event.start_time.strftime('%H:%M'), size: 8, at: [pdf.bounds.left + 2, pdf.bounds.top - 2]
      end
    end

    # draw events
    rooms.size.times do |i|
      events = @view_model.events_by_room(rooms[i])
      events.each do |event|
        coord = event_coordinates(i, event, column_width, timeslot_height, offset)
        pdf.bounding_box(coord,
                         width: column_width - 1,
                         height: (event.time_slots == 0 ? timeslot_height : event.time_slots * timeslot_height - 1)) do
          pdf.rounded_rectangle pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3
          pdf.fill_color = 'ffffff'
          pdf.fill_and_stroke
          pdf.fill_color = '000000'

          # Event title - allow for wrapping
          pdf.font 'BitStream Vera', style: :bold
          pdf.fill_color = '000000'
          title_height = pdf.bounds.height > 50 ? 20 : 12
          pdf.text_box event.title,
            size: 8,
            at: [pdf.bounds.left + 3, pdf.bounds.top - 3],
            width: pdf.bounds.width - 6,
            height: title_height,
            overflow: :shrink_to_fit

          # Track name (if available) - positioned below title
          track_y = pdf.bounds.top - title_height - 5
          if event.track && pdf.bounds.height > 35
            pdf.font 'BitStream Vera', style: :italic
            pdf.fill_color = '2563eb'  # Blue color for track
            pdf.text_box "[#{event.track.name}]",
              size: 6,
              at: [pdf.bounds.left + 3, track_y],
              width: pdf.bounds.width - 6
            track_y -= 10  # Adjust for next element
          end

          # Abstract preview - longer text, better positioned
          if event.abstract.present? && pdf.bounds.height > 45
            # Use more characters for longer abstracts
            max_chars = pdf.bounds.height > 80 ? 120 : 80
            abstract_preview = event.abstract.gsub(/\s+/, ' ').strip[0..max_chars-1]
            abstract_preview += '...' if event.abstract.length >= max_chars

            pdf.fill_color = '666666'  # Gray color for abstract
            pdf.font 'BitStream Vera', style: :normal

            # Calculate available height for abstract
            speaker_space = event.speakers.any? ? 15 : 5
            abstract_height = pdf.bounds.bottom + speaker_space - track_y + 10

            pdf.text_box abstract_preview,
              size: 6,
              at: [pdf.bounds.left + 3, track_y],
              width: pdf.bounds.width - 6,
              height: abstract_height,
              overflow: :shrink_to_fit,
              leading: 1
          end

          # Speaker names at bottom - better positioned
          if event.speakers.any?
            pdf.fill_color = '000000'
            pdf.font 'BitStream Vera', style: :italic
            pdf.text_box event.speakers.map(&:public_name).join(', '),
              size: 6,
              width: pdf.bounds.width - 6,
              align: :right,
              at: [pdf.bounds.left + 3, pdf.bounds.bottom + 3]
          end
        end
      end
    end

    pdf.start_new_page unless current_page == number_of_pages - 1
  end
end
