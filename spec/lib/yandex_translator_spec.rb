require 'spec_helper'

describe YandexTranslator::Translator do
  let(:key) {'api_key'}
  subject(:translator) {YandexTranslator::Translator.new(key)}

  it 'should exists' do
    YandexTranslator::Translator.new(key)
  end

  describe '#translate' do
    let(:translate_url) {"https://translate.yandex.net/api/v1.5/tr.json/translate?format=plain&key=#{key}&lang=ru&options=0"}
                           # "https://translate.yandex.net/api/v1.5/tr.json/translate?format=plain&key=api_key&lang=ru&options=0"
    let(:translate_request_body) {"text=Car"}
    let(:translate_response_body) {'{"code":200, "lang": "en-ru", "text": ["Автомобиль"]}'}
    let!(:translate_request) do
      stub_request(:post, translate_url)
        .with(body: translate_request_body)
        .to_return(
          body: translate_response_body,
          headers: {'content-type' => 'application/json'}
        )
    end

    it 'returns translation' do
      expect(translator.translate('Car', 'ru')).to eq ['Автомобиль']
    end

    context 'when server responds with invalid "lang" parameter error' do
      let(:translate_url) {"https://translate.yandex.net/api/v1.5/tr.json/translate?format=plain&key=#{key}&lang=ri&options=0"}
      let(:translate_request_body) {"text=Car"}
      let(:translate_response_body) {'{"code":501,"message":"The specified translation direction is not supported"}'}
      let!(:translate_request) do
        stub_request(:post, translate_url)
          .with(body: translate_request_body)
          .to_return(
            body: translate_response_body,
          )
      end

      it 'returns translation error' do
        expect {
          translator.translate('Car', 'ri')
        }.to raise_error(YandexTranslator::SelectedTranslationDirectionNotSupportedError, "The specified translation direction is not supported")
      end
    end
  end

  describe '#lang_detect' do
    let(:detect_url) {"https://translate.yandex.net/api/v1.5/tr.json/detect?hint=&key=#{key}"}
    let(:detect_request_body) {'text=Car'}
    let(:detect_response_body) {'{"code": 200, "lang": "en"}'}
    let!(:detect_request) do
      stub_request(:post, detect_url)
        .with(body: detect_request_body)
        .to_return(
          body: detect_response_body,
          headers: {'Content-Type' => 'application/json'}
        )
    end

    it 'returns detected language' do
      expect(translator.lang_detect('Car')).to eq 'en'
    end
  end
end