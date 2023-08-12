require "test_helper"

# This is pretty jank but ensures that the viewBoxes stay in sync
class SvgIconHelperTest < ActionView::TestCase
  # Method isn't present for some reason
  def asset_pack_path(...)
    ""
  end

  # rubocop:disable Naming/VariableName
  def svg_icon_tag(icon_name, viewBox:) # rubocop:disable Naming/MethodParameterName
    expected = FontAwesomeParser.svg_entry(icon_name)["viewBox"].join(" ")
    assert_equal(expected, viewBox)
  end
  # rubocop:enable Naming/VariableName

  context "the icon generation methods" do
    %i[
      paginate_left_icon paginate_right_icon paginator_more_icon
      mobile_menu_toggle_on_icon mobile_menu_toggle_off_icon
      verified_artist_icon vote_up_icon vote_meh_icon vote_down_icon
      warning_icon tag_search_icon detach_icon tag_count_good_icon tag_count_bad_icon
      dtext_bold_icon dtext_italic_icon dtext_strikethrough_icon dtext_underline_icon
      dtext_heading_icon dtext_spoiler_icon dtext_code_icon dtext_quote_icon
    ].each do |method|
      should "provide the correct viewBox for #{method}" do
        send(method)
      end
    end
  end
end
