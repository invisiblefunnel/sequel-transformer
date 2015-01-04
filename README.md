# Sequel Transformer

Organize, document, and instrument ETL processes with SQL and Ruby. Inspired by [Square's ETL library](https://github.com/square/ETL). Powered by [Sequel](https://github.com/jeremyevans/sequel).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-transformer'
```

And then execute:

```console
bundle
```

Or install it yourself as:

```console
gem install sequel-transformer
```

## Usage

```ruby
require 'sequel'
DB = Sequel.sqlite
DB.extension :transformer

DB.transformer "Update latest widgets" do |chain|
  chain.basic_logging!

  chain.step "ensure destination" do |db|
    db.create_table? :widgets do
      primary_key :id
      column :meta, :text
    end
  end

  chain.step "build metadata" do |db|
    # 
  end

  chain.step "validations" do |db|
    # 
  end

  chain.step "cleanup" do |db|
    db.run %[
      DROP TABLE IF EXISTS temp_widget_data;
    ]
  end
end
```

## Contributing

1. Fork it ( https://github.com/invisiblefunnel/sequel-transformer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
