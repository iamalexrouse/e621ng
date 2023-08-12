namespace :webpacker do
  desc "Create SVG symbols"
  task svg_symbols: :environment do
    target_path = Rails.public_path.join("images/fa-icons.svg")
    icon_data = FontAwesomeParser.svg_symbol_document
    File.write(target_path, icon_data)
  end
end
