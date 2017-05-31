require "yandex_translator/version"

# A library for translating text using Yandex Translate API version 1.5
#
module YandexTranslator
  require 'net/http'
  require 'json'
  require 'http'

  class YandexError < StandardError; end

  class WrongAPIKeyError < YandexError; end
  class BlockedAPIKeyError < YandexError; end
  class DaylyLimitExceededError < YandexError; end
  class MaximumTextSizeExceededError < YandexError; end
  class TextCannotBeTranslatedError < YandexError; end
  class SelectedTranslationDirectionNotSupportedError < YandexError; end

  # A Translator class
  #
  class Translator
    attr_accessor :key, :detected
    Url_base = 'https://translate.yandex.net/api/v1.5/tr.json/'

    # Returns the Translator object
    #
    def initialize(key)
      @key = key
      @detected = nil
    end

    # Returns the hash with keys:
    # * "dirs" with values of available translation pairs
    # * "langs" with keys languages abbreviations transcriptions(if the _lang_ argument is set)
    #
    def lang_list(lang=nil)
      requester(:lang_list, {:key => @key}, nil)
    end

    # Returns possible text languages
    # The _hint_ argument defaults to *nil*, should be a string of prefered languages, separator ","
    #
    def lang_detect(text, hint=nil)
      requester(:lang_detect, {:key => @key, :hint => hint}, {:text => URI::encode(text)})
    end

    # Return the translation of the _text_ argument
    # _lang_ argument can be 2 types:
    # * The pair of the languages "from-to" ('en-ru')
    # * One destination language ('en')
    # _format_ argument defaults to *plain*. Can be "plain" for plain text or "html" for HTMl marked text
    # _options_ argument defaults to *0*. Can be "1" to include to the response the autodetected language of the source text. You can obtain it by attribute *detected*
    def translate(text, lang, format: :plain, options: 0)
      requester(:translate, {:key => @key, :lang => lang, :format => format, :options => options},
                {:text => text})
    end

    def requester(method, params, body)
      url_method = case method
                     when :lang_list then 'getLangs?'
                     when :lang_detect then 'detect?'
                     when :translate then 'translate?'
                   end
      res = HTTP.post(Url_base + url_method, :params => params, :form => body)
      res = JSON.parse(res)

      if res['code'] and res['code'] != 200
        case res['code']
          when 401 then raise(WrongAPIKeyError, res['message'])
          when 402 then raise(BlockedAPIKeyError, res['message'])
          when 404 then raise(DaylyLimitExceededError, res['message'])
          when 413 then raise(MaximumTextSizeExceededError, res['message'])
          when 422 then raise(TextCannotBeTranslatedError, res['message'])
          when 501 then raise(SelectedTranslationDirectionNotSupportedError, res['message'])
          else raise(YandexError , res['message'])
        end
      end

      case method
        when :lang_list then res
        when :lang_detect then res['lang']
        when :translate then
          if params[:options] == 1 then @detected = res['detected']['lang'] else @detected = nil end
          res['text'][0]
      end
    end
  end
end