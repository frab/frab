# https://github.com/rails/rails/issues/31324
if ActionPack::VERSION::STRING >= "5.2.0"
  if defined? Minitest::Rails
    Minitest::Rails::TestUnit = Rails::TestUnit
  end
end
