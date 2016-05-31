module CustomPDF
  class HalfPageLayout < FullPageLayout
    def page_width
      @bounds.width / 2 - margin_width
    end
  end
end
