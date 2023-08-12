module FontAwesomeParser
  USED_ICONS = %w[
    regular-circle-check
    regular-thumbs-up
    regular-face-smile
    regular-face-frown
    regular-face-meh
    regular-thumbs-down
    solid-chevron-left
    solid-chevron-right
    solid-ellipsis
    solid-up-down-left-right
    solid-magnifying-glass
    solid-circle-exclamation
    solid-bars
    solid-xmark
    solid-bold
    solid-italic
    solid-strikethrough
    solid-underline
    solid-heading
    solid-eye-slash
    solid-code
    solid-quote-right
  ].sort.freeze
  MODULE_PATH = Rails.root.join("node_modules/@fortawesome/fontawesome-free")

  module_function

  def svg_symbol_document
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.comment attribution
      xml.svg(xmlns: "http://www.w3.org/2000/svg") do
        USED_ICONS.each do |icon|
          svg = svg_entry(icon)
          xml.symbol(id: icon, viewBox: "0 0 #{svg['width']} #{svg['height']}") do
            xml.path(d: svg["path"])
          end
        end
      end
    end.to_xml
  end

  def svg_entry(icon)
    @data ||= JSON.parse(MODULE_PATH.join("metadata/icon-families.json").read)
    type, name = icon.split("-", 2)
    @data[name]["svgs"]["classic"][type]
  end

  def attribution
    MODULE_PATH.join("attribution.js").read[/`([\s\S]*)`/, 1]
  end
end
