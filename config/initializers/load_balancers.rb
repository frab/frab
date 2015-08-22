if Rails.env.production?
  # Don't show trace pages in production! Requests shall never originate from localhost!
  # see: http://helderribeiro.net/?p=357
  class ActionDispatch::Request
    def local?
      false
    end
  end
end
