module ApplicationHelper
  def body_classes
    [
      controller_name,
      "#{controller_name}-#{action_name}",
    ].join(" ").gsub("_", "-")
  end

  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    self.output_buffer = render(file: "layouts/#{layout}")
  end

  def meta_title
    if custom_title = content_for(:title).presence
      "#{custom_title} · #{t(:site_name)}"
    else
      "#{t(:site_name)} - #{t('meta.default_title')}"
    end
  end

  def meta_description
    content_for(:description).presence || t('meta.default_description')
  end

  def active_if_current(path)
    request.path == path ? ' active ' : ''
  end

  def active_if_any_current(paths)
    any_active = paths.any? do |path|
      path == request.path
    end
    any_active ? ' active ' : ''
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      alert_class = [:alert, :error].include?(msg_type&.to_sym) ? "alert-warning" : "alert-primary"
      concat(content_tag(:div, message, class: "alert #{alert_class}"))
    end
    nil
  end
end
