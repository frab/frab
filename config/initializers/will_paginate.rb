module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options[:renderer] ||= BootstrapLinkRenderer
      options[:previous_label] ||= '<i class="bi bi-chevron-left"></i>'.html_safe
      options[:next_label] ||= '<i class="bi bi-chevron-right"></i>'.html_safe
      super.try :html_safe
    end

    class BootstrapLinkRenderer < LinkRenderer
      protected

      def html_container(html)
        tag :nav, tag(:ul, html, class: "pagination flex-wrap"), container_attributes
      end

      def page_number(page)
        tag :li,
          link(page, page, rel: rel_value(page), class: "page-link"),
          class: "page-item#{' active' if page == current_page}"
      end

      def previous_or_next_page(page, text, classname, aria_label = nil)
        tag :li,
          link(text, page || '#', class: "page-link"),
          :'aria-label' => aria_label,
          class: "page-item #{classname}#{' disabled' unless page}"
      end

      def gap
        tag :li,
          link(super, '#', class: "page-link"),
          class: "page-item disabled"
      end
    end
  end
end
