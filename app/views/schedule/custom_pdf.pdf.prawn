# frozen_string_literal: true
require 'prawn/measurement_extensions'

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
  page_layout: landscape? ? :landscape : :portrait,
  page_size: @layout.page_size
) do |pdf|
  pdf.font_families.update('BitStream Vera' => {
                             normal: Rails.root.join('vendor', 'fonts', 'vera.ttf').to_s,
                             bold: Rails.root.join('vendor', 'fonts', 'verabd.ttf').to_s,
                             italic: Rails.root.join('vendor', 'fonts', 'verait.ttf').to_s
                           })
  pdf.font 'BitStream Vera'

  @layout.bounds = pdf.bounds

  number_of_columns = @rooms.size < 5 ? @rooms.size : 5
  number_of_pages = (@rooms.size / number_of_columns.to_f).ceil.to_i
  column_width = @layout.page_width / number_of_columns
  timeslot_height = @layout.timeslot_height(number_of_timeslots)

  # A page contains the full time range. New pages will
  # contain further rooms.
  number_of_pages.times do |current_page|
    offset = current_page * number_of_columns

    pdf.draw_text header_content_left, size: 9, at: @layout.header_left_anchor
    pdf.draw_text header_content_center, size: 16, at: @layout.header_center_anchor
    pdf.draw_text header_content_right, size: 9, at: @layout.header_right_anchor

    rooms = @rooms[offset..(offset + number_of_columns - 1)]
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
    events = @events[rooms[0]]
    events.each do |event|
      y = (timeslots_between(event.start_time, @day.end_date) - 1) * timeslot_height
      y += offset
      coord = [0, y]
      pdf.bounding_box(coord,
                       width: @layout.margin_width - 1,
                       height: event.time_slots * timeslot_height - 1) do
        pdf.rounded_rectangle(pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3)
        pdf.fill_color = 'ffffff'
        pdf.fill_and_stroke
        pdf.fill_color = '000000'
        pdf.text_box event.start_time.strftime('%H:%M'), size: 8, at: [pdf.bounds.left + 2, pdf.bounds.top - 2]
      end
    end

    # draw events
    rooms.size.times do |i|
      events = @events[rooms[i]]
      events.each do |event|
        coord = event_coordinates(i, event, column_width, timeslot_height, offset)
        pdf.bounding_box(coord,
                         width: column_width - 1,
                         height: event.time_slots * timeslot_height - 1) do
          pdf.rounded_rectangle pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3
          pdf.fill_color = 'ffffff'
          pdf.fill_and_stroke
          pdf.fill_color = '000000'
          pdf.text_box event.title, size: 8, at: [pdf.bounds.left + 2, pdf.bounds.top - 2]
          pdf.text_box event.speakers.map(&:public_name).join(', '),
            size: 6,
            width: pdf.bounds.width - 4,
            style: :italic,
            align: :right,
            at: [pdf.bounds.left + 2, pdf.bounds.bottom + 8]
        end
      end
    end

    pdf.start_new_page unless current_page == number_of_pages - 1
  end
end
