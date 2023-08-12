require "test_helper"

class FontAwesomeParserTest < ActiveSupport::TestCase
  context "the currently generated file" do
    should "be up to date" do
      current_data = Rails.public_path.join("images/fa-icons.svg").read
      generated_data = FontAwesomeParser.svg_symbol_document
      assert_equal(current_data, generated_data)
    end
  end
end
