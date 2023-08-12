module SvgIconHelper
  def svg_icon_tag(icon_name, class: nil, title: nil, **)
    klass = binding.local_variable_get(:class)
    tag.svg(class: "svg-icon #{icon_name}-icon #{klass}", **) do
      title_element = "".html_safe
      title_element = tag.title(title) if title # setting title on the svg element doesn't work
      title_element + tag.use(fill: "currentColor", href: asset_pack_path("static/fa-icons.svg") + "##{icon_name}")
    end
  end

  def verified_artist_icon(**)
    svg_icon_tag("regular-circle-check", viewBox: "0 0 512 512", **)
  end

  def paginate_left_icon(**)
    svg_icon_tag("solid-chevron-left", viewBox: "0 0 320 512", **)
  end

  def paginate_right_icon(**)
    svg_icon_tag("solid-chevron-right", viewBox: "0 0 320 512", **)
  end

  def paginator_more_icon(**)
    svg_icon_tag("solid-ellipsis", viewBox: "0 0 448 512", **)
  end

  def mobile_menu_toggle_on_icon(**)
    svg_icon_tag("solid-bars", viewBox: "0 0 448 512", **)
  end

  def mobile_menu_toggle_off_icon(**)
    svg_icon_tag("solid-xmark", viewBox: "0 0 384 512", **)
  end

  def vote_up_icon(**)
    svg_icon_tag("regular-thumbs-up", viewBox: "0 0 512 512", **)
  end

  def vote_meh_icon(**)
    svg_icon_tag("regular-face-meh", viewBox: "0 0 512 512", **)
  end
  alias tag_count_meh_icon vote_meh_icon

  def vote_down_icon(**)
    svg_icon_tag("regular-thumbs-down", viewBox: "0 0 512 512", **)
  end

  def tag_count_good_icon(**)
    svg_icon_tag("regular-face-smile", viewBox: "0 0 512 512", **)
  end

  def tag_count_bad_icon(**)
    svg_icon_tag("regular-face-frown", viewBox: "0 0 512 512", **)
  end

  def warning_icon(**)
    svg_icon_tag("solid-circle-exclamation", viewBox: "0 0 512 512", **)
  end

  def tag_search_icon(**)
    svg_icon_tag("solid-magnifying-glass", viewBox: "0 0 512 512", **)
  end

  def detach_icon(**)
    svg_icon_tag("solid-up-down-left-right", viewBox: "0 0 512 512", **)
  end

  def dtext_bold_icon(**)
    svg_icon_tag("solid-bold", viewBox: "0 0 384 512", **)
  end

  def dtext_italic_icon(**)
    svg_icon_tag("solid-italic", viewBox: "0 0 384 512", **)
  end

  def dtext_strikethrough_icon(**)
    svg_icon_tag("solid-strikethrough", viewBox: "0 0 512 512", **)
  end

  def dtext_underline_icon(**)
    svg_icon_tag("solid-underline", viewBox: "0 0 448 512", **)
  end

  def dtext_heading_icon(**)
    svg_icon_tag("solid-heading", viewBox: "0 0 448 512", **)
  end

  def dtext_spoiler_icon(**)
    svg_icon_tag("solid-eye-slash", viewBox: "0 0 640 512", **)
  end

  def dtext_code_icon(**)
    svg_icon_tag("solid-code", viewBox: "0 0 640 512", **)
  end

  def dtext_quote_icon(**)
    svg_icon_tag("solid-quote-right", viewBox: "0 0 448 512", **)
  end
end
