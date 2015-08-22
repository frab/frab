module Public::FeedbackHelper
  def feedback_page?
    request.path =~ /feedback/
  end
end
