# Code Coverage

SimpleCov.start do

  merge_timeout 1500
  minimum_coverage 60

  add_filter '/assets/'
  add_filter '/bin/'
  add_filter '/config/'
  add_filter '/coverage/'
  add_filter '/controlled/'
  add_filter '/docs/'
  add_filter '/log/'
  add_filter '/public/'
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/views/'

  add_group 'UseCases' do |src_file|
    ['strategy/services'].any? do |item|
      src_file.filename.include? item
    end
  end
  add_group 'Security' do |src_file|
    ['strategy/secure', 'strategy/strategy.rb'].any? do |item|
      src_file.filename.include? item
    end
  end
  add_group 'Main' do |src_file|
    ['main', 'routes', 'views/helpers',
    'strategy/utils'].any? do |item|
      src_file.filename.include? item
    end
  end
  add_group "Persistence" do |src_file|
    ['persistence',
     'persistence/entity',
     'persistence/relations',
     'persistence/repositories'].any? do |item|
      src_file.filename.include? item
    end
  end

end
