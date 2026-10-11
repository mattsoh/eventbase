module ApplicationHelper
  PLACEHOLDER_TEXT = "Placeholder text".freeze

  def placeholder_text
    PLACEHOLDER_TEXT
  end

  # Grey box labelled "Placeholder image", standing in for real artwork.
  def placeholder_image(css_class: nil, width: nil, height: nil)
    style = { width: width && "#{width}px", height: height && "#{height}px" }.compact.map { |k, v| "#{k}: #{v}" }.join("; ")
    tag.span("Placeholder image", class: [ "placeholder-image", css_class ].compact.join(" "),
             role: "img", aria: { label: "Placeholder image" }, style: style.presence)
  end
end
