module WebAppThemeHelper
  def block(&block)
    content_tag(:div, { class: "block" }, &block)
  end

  def content(&block)
    content_tag(:div, { class: "content" }, &block)
  end

  def inner(&block)
    content_tag(:div, { class: "inner" }, &block)
  end

  def actions_bar(&block)
    content_tag(:div, { class: "actions-bar" }, &block)
  end

  def actions_block(&block)
    content_tag(:div, id: "actions", class: "block") do
      content_tag(:h3, "Actions") + content(&block)
    end
  end
end
