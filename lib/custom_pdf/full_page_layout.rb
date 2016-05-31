module CustomPDF
  class FullPageLayout
    def initialize(page_size)
      @page_size = page_size
    end
    attr_reader :page_size
    attr_writer :bounds

    def header_left_anchor
      [@bounds.left, @bounds.top + 0.5.cm]
    end

    def header_center_anchor
      [@bounds.left + 12.cm, @bounds.top + 0.5.cm]
    end

    def header_right_anchor
      [@bounds.right - 1.cm, @bounds.top + 0.5.cm]
    end

    def header_height
      0.8.cm
    end

    # determine borders by page size, because all timeslots need to fit
    # on one page
    def margin_height
      return 3.5.cm if bigger_than_a4
      2.5.cm
    end

    def timeslot_height(number_of_timeslots)
      (@bounds.height - margin_height - header_height) / number_of_timeslots
    end

    def margin_width
      1.5.cm
    end

    def page_width
      @bounds.width - margin_width
    end

    private

    def bigger_than_a4
      Prawn::Document::PageGeometry::SIZES['A4'].inject(:*) < Prawn::Document::PageGeometry::SIZES[@page_size].inject(:*)
    end
  end
end
