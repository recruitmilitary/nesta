source "http://rubygems.org"

gem "builder", "2.1.2"
gem "haml", "2.2.20"
gem "maruku", "0.6.0"
gem "RedCloth", "4.2.2"
gem "sinatra", "0.9.4"

group :development do
  gem "shotgun"
  gem "capistrano"
  gem "capistrano-ext"
end

group :development, :test do
  gem "hpricot", "0.8.2"
  gem "rack-test", "0.5.3", :require => "rack/test"
  gem "rspec", "1.3.0"
  gem "rspec_hpricot_matchers", "1.0"
  gem "test-unit", "1.2.3"
end

group :production do
  gem "unicorn"
end
