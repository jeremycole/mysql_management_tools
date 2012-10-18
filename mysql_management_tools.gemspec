Gem::Specification.new do |s|
  s.name        = 'mysql_management_tools'
  s.version     = File.open("VERSION").readline.chomp
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'MySQL Management Tools'
  s.description = 'A library and tools for managing MySQL servers'
  s.authors     = [ 'Jeremy Cole' ]
  s.email       = 'jeremycole@twitter.com'
  s.homepage    = 'http://twitter.com/jeremycole'
  s.files = [
    'lib/mysql_management/basic_interaction.rb',
    'lib/mysql_management/mysql_connection_manager.rb',
  ]
  s.executables = [
    'mysql_table_manager',
  ]
end
