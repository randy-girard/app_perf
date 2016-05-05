module SystemMetrics
  module MetricsHelper
    IDENTIFIER_ATTRS = [:end_point, :layout, :identifier, :path, :name]

    def set_title(title)
      content_for(:title, title.to_s)
    end

    def title
      content_for?(:title) ? content_for(:title) : 'System Metrics'
    end

    def set_page_title(page_title)
      content_for(:page_title, page_title.to_s)
    end

    def page_title
      content_for?(:page_title) ? content_for(:page_title) : ''
    end

    def identifier(metric)
      attr = IDENTIFIER_ATTRS.find { |attr| metric.payload.include?(attr) && metric.payload[attr] != nil }  
      attr.present? ? metric.payload[attr] : metric.name
    end

    def slow_threshold(metric)
      case metric.name
      when 'request.rack' then 500.0
      when 'process_action.action_controller' then 450.0
      when 'sql.active_record' then 150.0
      when /render_[^\.]+\.action_view/ then 250.0
      else 200.0
      end
    end
  end
end
