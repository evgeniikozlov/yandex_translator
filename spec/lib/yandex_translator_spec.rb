require 'spec_helper'

describe YandexTranslator::Translator do
  let(:key) { 'api_key' }
  subject(:translator) { YandexTranslator::Translator.new(key) }

  it 'should exists' do
    YandexTranslator::Translator.new(key)
  end

  # it 'returns YandexError for invalid key' do
  #   expect{YandexTranslator::Translator.new(key)}.to raise_error(YandexTranslator::YandexError)
  # end

  describe '#translate' do
    let(:translate_url) { "https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{key}&text=Car&lang=ru" }
    let(:translate_response_body) { '{"code":200, "lang": "en-ru", "text": ["Автомобиль"]}' }
    let!(:translate_request) do
      stub_request(:get, translate_url)
          .to_return(
              body: translate_response_body,
              headers: {'Content-Type' => 'application/json'}
          )
    end

    it 'returns translalation' do
      expect(translator.translate('Car', 'ru')).to eq ['Автомобиль']
    end

    context 'when server responds with invalid "lang" parameter error' do
      let(:translate_request_body) { "text=Car&lang=ru-ru&key=#{key}" }
      let(:translate_url) {"https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{key}&text=Car&lang=ri"}
      let(:translate_response_body) { '{"code":501,"message":"The specified translation direction is not supported"}' }
      let!(:translate_request) do
        stub_request(:get, translate_url)
            .to_return(
                body: translate_response_body,
            )
      end

      it 'returns translation error' do
        expect{
          translator.translate('Car', 'ri')
        }.to raise_error(YandexTranslator::YandexError, "The specified translation direction is not supported")
      end
    end
  end

  describe '#lang_detect' do
    let(:detect_url) { "https://translate.yandex.net/api/v1.5/tr.json/detect?key=#{key}&text=Car" }
    let(:detect_response_body) { '{"code": 200, "lang": "en"}' }
    let!(:detect_request) do
      stub_request(:get, detect_url)
          .to_return(
              body: detect_response_body,
              headers: { 'Content-Type' => 'application/json' }
          )
    end

    it 'returns detected language' do
      expect(translator.lang_detect('Car')).to eq 'en'
    end
  end
end