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
end
