# YandexTranslator::Translator

A library for translating text using Yandex Translate API version 1.5 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yandex_translator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex_translator

## Usage

1. Create translator object using your API key. You can obtain a key [here](https://tech.yandex.ru/keys/get/?service=trnsl).

```ruby
translator = YandexTranslator::Translator.new(key)
```

2. To get the list of available translation directions and transcriptions of languages abbreviations use method **lang_list**:

```ruby
translator.lang_list(text, hint=nil)
```

3. To get possible text languages use method **lang_detect**:

```ruby
translator.lang_detect(text, hint=nil)
```

4. To translate text use method **translate**:

```ruby
translator.translate(text, lang, format:nil, options:nil)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

