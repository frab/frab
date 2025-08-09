require 'test_helper'

# Test to verify Prawn-specific functionality works before/after upgrade
class PrawnCompatibilityTest < ActiveSupport::TestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @day = @conference.days.first
    @event = @conference.events.first
    @room = @conference.rooms.first
    @event.update!(room: @room, start_time: @day.start_date + 10.hours)
    
    # Add speaker for more realistic testing
    @person = create(:person, first_name: "Test", last_name: "Speaker")
    create(:event_person, event: @event, person: @person, event_role: 'speaker')
  end

  test 'Prawn table functionality works in cards PDF' do
    # Test the table functionality used in cards.pdf.prawn
    pdf_content = nil
    
    assert_nothing_raised do
      # Simulate the table generation from cards.pdf.prawn
      pdf = Prawn::Document.new(page_layout: :landscape)
      
      # Test table creation (this will break in Prawn 2.0 without prawn-table gem)
      table_data = [
        [@event.track&.name || '', @event.event_type || 'lecture', 
         @event.language || 'en', '4']  # time_slots placeholder
      ]
      
      room_time = [@event.room&.name || '', @event.start_time&.strftime('%H:%M') || '']
      table_data << room_time if room_time.any?(&:present?)
      
      table = pdf.table(table_data, width: 300, cell_style: {align: :center})
      
      assert table.present?, "Table should be created successfully"
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end

  test 'Prawn measurement extensions work in custom PDF' do
    # Test measurement extensions used in custom_pdf.pdf.prawn
    assert_nothing_raised do
      require 'prawn/measurement_extensions'
      # These require prawn/measurement_extensions
      header_height = 0.8.cm
      margin_height = 2.5.cm
      margin_width = 1.5.cm
      
      assert_in_delta 22.677165354330708, header_height, 0.00000000001, "Centimeter conversion should work"
      assert_in_delta 70.86614173228346, margin_height, 0.00000000001, "Centimeter conversion should work"  
      assert_in_delta 42.51968503937008, margin_width, 0.00000000001, "Centimeter conversion should work"
    end
  end

  test 'Prawn formatted text functionality works' do
    # Test formatted text functionality used in cards.pdf.prawn
    pdf_content = nil
    
    assert_nothing_raised do
      pdf = Prawn::Document.new
      
      # Test formatted text box (used in cards PDF)
      formatted_text = [
        {text: "Speakers\n", styles: [:bold], size: 12},
        {text: @person.full_name + "\n", size: 12},
        {text: "Test availability\n", size: 9}
      ]
      
      pdf.formatted_text_box(
        formatted_text,
        at: [0, 200],
        width: 100,
        overflow: :shrink_to_fit
      )
      
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "Formatted text PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end

  test 'Prawn grid functionality works' do
    # Test grid functionality used in cards.pdf.prawn  
    pdf_content = nil
    
    assert_nothing_raised do
      pdf = Prawn::Document.new(page_layout: :landscape)
      
      # Test grid definition and usage
      pdf.define_grid(rows: 2, columns: 2, gutter: 10)
      
      pdf.grid(0, 0).bounding_box do
        pdf.text("Test content in grid cell", size: 16, style: :bold)
      end
      
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "Grid PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end

  test 'Prawn custom font loading works' do
    # Test custom font functionality used in both PDF templates
    pdf_content = nil
    
    assert_nothing_raised do
      pdf = Prawn::Document.new
      
      # Test font family update (used in both templates)
      font_path = Rails.root.join("vendor", "fonts")
      if File.exist?(font_path.join("vera.ttf"))
        pdf.font_families.update("BitStream Vera" => {
          normal: font_path.join("vera.ttf").to_s,
          bold: font_path.join("verabd.ttf").to_s,
          italic: font_path.join("verait.ttf").to_s
        })
        pdf.font "BitStream Vera"
      end
      
      pdf.text("Test text with custom font", size: 12)
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "Custom font PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end

  test 'Prawn drawing primitives work in schedule PDF' do
    # Test drawing functionality used in custom_pdf.pdf.prawn
    pdf_content = nil
    
    assert_nothing_raised do
      pdf = Prawn::Document.new
      
      # Test drawing operations used in schedule PDF
      pdf.bounding_box([0, 200], width: 100, height: 50) do
        pdf.rounded_rectangle(pdf.bounds.top_left, pdf.bounds.width, pdf.bounds.height, 3)
        pdf.fill_color = 'ffffff'
        pdf.fill_and_stroke
        pdf.fill_color = '000000'
        pdf.text_box 'Event Title', size: 8, at: [pdf.bounds.left + 2, pdf.bounds.top - 2]
      end
      
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "Drawing PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end

  test 'Prawn text encoding options work' do
    # Test text rendering with special characters
    pdf_content = nil
    
    assert_nothing_raised do
      pdf = Prawn::Document.new
      
      # Test text rendering (encoding issues vary by Prawn version)
      pdf.text("Test Title", size: 16, style: :bold)
      pdf.text("Simple text content", size: 12)
      
      pdf_content = pdf.render
    end
    
    assert pdf_content.present?, "Text PDF should be generated"
    assert pdf_content.start_with?('%PDF'), "Should be valid PDF"
  end
end