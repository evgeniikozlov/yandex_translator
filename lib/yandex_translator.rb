require "yandex_translator/version"

# A library for translating text using Yandex Translate API version 1.5
#
module YandexTranslator
  require 'net/http'
  require 'json'

  class YandexError < StandardError; end

  class Translator
    attr_accessor :key, :detected
    @@url_base = 'https://translate.yandex.net/api/v1.5/tr.json/'

    # Returns the Translator object
    #
    def initialize(key)
      @key = key
      @detected = nil
    end

    # Returns the list of available translation pairs and
    # If the _lang_ argument is set also returns transcriptions of languages abbreviations
    #
    def lang_list(lang=nil)
      url = @@url_base + 'getLangs?' + 'key=' + @key
      if lang then url += '&ui=' + lang end
      url = URI(url)
      res = JSON.parse(Net::HTTP.get(url))
      check_errors(res)
      return res
    end

    # Returns possible text languages
    # The _hint_ argument defaults to *nil*, can be a string or an array of prefered languages
    #
    def lang_detect(text, hint=nil)
      url = @@url_base + 'detect?key=' + @key + '&text=' + URI::encode(text)
      if hint
        url += '&hint='
        if hint.is_a?(String)  # parse hint if it is a string or array
          url += hint
        else
          hint.each { |x| url += x + ','}
          url = url[0..-2]
        end
      end
      url = URI(url)
      res = JSON.parse(Net::HTTP.get(url))
      check_errors(res)
      return res['lang']
    end

    # Return the translation of the _text_ argument
    # _lang_ argument can be 2 types:
    # * The pair of the languages "from-to" ('en-ru')
    # * One destination language ('en')
    # _format_ argument defaults to *nil*. Can be "plain" for plain text or "html" for HTMl marked text
    # _options_ argument defaults to *nil*. Can be "1" to include to the response the autodetected language of the source text. You can obtain it by attribute *detected*
    def translate(text, lang, format:nil, options:nil)
      url = @@url_base + 'translate?' + 'key=' + @key + '&' + 'text=' + URI::encode(text) + '&' + 'lang=' + lang
      if format then url += '&format=' + format end
      if options then url += '&options=' + options.to_s end

      url = URI(url)
      res = JSON.parse(Net::HTTP.get(url))
      check_errors(res)
      if options == 1 then @detected = res['detected']['lang'] else @detected = nil end
      return res['text']
    end

    def check_errors(res)
      if res['code'] and res['code'] != 200
        raise(YandexError , res['message'])
      end
    end

  end
end