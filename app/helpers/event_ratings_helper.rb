module EventRatingsHelper
  def raty_icon_path(icon)
    asset_path("raty/star-#{icon}.png").sub(/^\//, "")
  end
end
