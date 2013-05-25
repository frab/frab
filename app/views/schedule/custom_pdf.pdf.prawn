require "prawn/measurement_extensions"

prawn_document(
  :page_layout => landscape? ? :landscape : :portrait,
  :page_size => @page_size
) do |pdf|

  pdf.font_families.update("BitStream Vera" => {
    :normal => Rails.root.join("vendor", "fonts", "vera.ttf").to_s,
    :bold => Rails.root.join("vendor", "fonts", "verabd.ttf").to_s,
    :italic => Rails.root.join("vendor", "fonts", "verait.ttf").to_s
  })
  pdf.font "BitStream Vera"

  # determine borders by page size, because all timeslots need to fit
  # on one page
  margin_width = 1.5.cm
  margin_height = 1.cm
  if Prawn::Document::PageGeometry::SIZES["A4"].inject(:*) < Prawn::Document::PageGeometry::SIZES[@page_size].inject(:*)
    margin_height = 2.cm
  end

  header_height = 0.8.cm

  number_of_columns = @rooms.size < 5 ? @rooms.size : 5 
  number_of_pages = (@rooms.size / number_of_columns.to_f).ceil.to_i
  column_width = (pdf.bounds.width - margin_width) / number_of_columns
  timeslot_height = (pdf.bounds.height - margin_height - header_height) / number_of_timeslots

  # A page contains the full time range. New pages will
  # contain further rooms.
  number_of_pages.times do |current_page|
  
    offset = current_page * number_of_columns
    rooms = @rooms[(offset)..(offset + number_of_columns -1)]

    table_data = Array.new

    table_data << [""] + rooms.map(&:name)

    each_timeslot do |time|
      row = []
      row << time.strftime("%H:%M")
      rooms.size.times { row << "" }
      table_data << row
    end

    table = pdf.make_table(table_data) do |t|
      t.cells.style(:border_width => 1.pt, :border_color => "cccccc")
      t.row(0).height = header_height
      t.row(0).align = :center
      t.row(0).font_style = :bold
      t.row(0).style(:size => 10)
      t.column(0).width = margin_width - 1
      t.rows(1..-1).style(:size => 4)
      t.rows(1..-1).height = timeslot_height
      t.rows(1..-1).padding = 3
      t.rows(1..-1).align = :right
      t.columns(1..-1).width = column_width
    end

    table.draw
    offset = pdf.bounds.height - table.height

    rooms.size.times do |i|
      events = @events[rooms[i]]
      events.each do |event|
        pdf.bounding_box(event_coordinates(i, event, column_width, timeslot_height, offset), 
                         :width => column_width, 
                         :height => event.time_slots * timeslot_height) do
          pdf.rounded_rectangle pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3 
          pdf.fill_color = "ffffff"
          pdf.fill_and_stroke
          pdf.fill_color = "000000"
          pdf.text_box event.title, :size => 8, :at => [pdf.bounds.left + 2, pdf.bounds.top - 2]
          pdf.text_box event.speakers.map(&:full_public_name).join(", "), 
            :size => 6,
            :width => pdf.bounds.width - 4,
            :style => :italic, 
            :align => :right,
            :at => [pdf.bounds.left + 2, pdf.bounds.bottom + 8]
        end
      end
    end

    pdf.start_new_page unless current_page == number_of_pages - 1
  
  end

end
