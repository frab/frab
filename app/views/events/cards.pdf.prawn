prawn_document(page_layout: :landscape) do |pdf|

  pdf.font_families.update("BitStream Vera" => {
    normal: Rails.root.join("vendor", "fonts", "vera.ttf").to_s,
    bold: Rails.root.join("vendor", "fonts", "verabd.ttf").to_s,
    italic: Rails.root.join("vendor", "fonts", "verait.ttf").to_s
  })
  pdf.font "BitStream Vera"

  pdf.define_grid(rows: 2, columns: 2, gutter: 10)

  (@events.size / 4 + 1).times do
    
    [[0,0],[0,1],[1,0],[1,1]].each do |coords|

      if event = @events.pop
        pdf.grid(coords[0], coords[1]).bounding_box do

          # Title
          title = "[#{event.id}] #{event.title.truncate(90)}"
          pdf.text(title, size: 16, style: :bold, skip_encoding: true)
          subtitle = (event.subtitle || "").truncate(40)
          pdf.text(subtitle, size: 14, style: :italic)

          # Info Table
          #pdf.move_cursor_to 100
          room = event.room.try(:name) or ""
          time_str = event.humanized_time_str
          rows = []
          rows << [event.track.try(:name), event.event_type, 
                  event.language, format_time_slots(event.time_slots)]
          rows << [room, time_str] if room.present? or time_str.present?
          info_table = pdf.table(
            rows,
            width: 300,
            cell_style: {align: :center}
          )


          # Speakers Column
          top = 200 - info_table.height
          conference_days = @conference.days.map { |day| day.humanized_date_range }
          columns = [{text: "Speakers:\n", styles: [:bold], size: 12}]

          speakers = event.speakers.each do |p| 
            columns << {text: p.full_name + "\n", size: 12}
            availabilities = p.availabilities_in(@conference).map { |a| 
              a.humanized_date_range 
            } 
            availabilities = availabilities - conference_days
            columns << {text: availabilities.join("\n")+"\n", size: 9}
          end

          unless event.average_rating.nil?
            avg_rating = "\nRating: #{event.average_rating.round(2).to_s}\n"
            columns << {text: avg_rating, size: 12}
          end

          pdf.formatted_text_box(
            columns,
            at: [0,top],
            width: 100,
            overflow: :shrink_to_fit
          )

          # Abstract Column
          abstract = (event.abstract || event.description || "").gsub(/(\r\n|\n)/, " ")
          pdf.formatted_text_box(
            [{text: "Abstract:\n", styles: [:bold], size: 12},
             {text: abstract, size: 12}],
            at: [100,top],
            width: 200,
            align: :justify,
            overflow: :shrink_to_fit,
            skip_encoding: true
          )

        end
      end

    end

    pdf.start_new_page unless @events.empty?
  
  end

end
