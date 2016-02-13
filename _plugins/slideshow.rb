
# for slideshows, split the original markdown into a cover page and the actual deck
Jekyll::Hooks.register :documents, :pre_render do |page|
  if page.data["layout"] == 'slidedeck'

    idx = page.content.index('---')
    if idx
      page.data["source"] = page.content.slice(idx+3, page.content.length)
      page.content = page.content.slice(0, idx)
    else
      page.data["source"] = page.content
    end
  end
end

# provide javascript-safe filtration
# used primarily to feed markdown to remark-js
module Jekyll
  module AssetFilter
    JS_ESCAPE_MAP = {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'"
    }

    JS_ESCAPE_MAP["\342\200\250".force_encoding(Encoding::UTF_8).encode!] = '&#x2028;'
    JS_ESCAPE_MAP["\342\200\251".force_encoding(Encoding::UTF_8).encode!] = '&#x2029;'

    # Escapes carriage returns and single and double quotes for JavaScript segments.
    # Borrowed from Rails:
    # https://raw.githubusercontent.com/rails/rails/9505a21f425e37e54426120849e3ca2a494cc7b0/actionview/lib/action_view/helpers/javascript_helper.rb
    def escape_javascript(input)
      if input
        input.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) {
          |match| JS_ESCAPE_MAP[match]
        }
      else
        ''
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)


