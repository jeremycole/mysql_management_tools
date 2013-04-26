Gem::Specification.new do |s|
  s.name        = 'mysql_management_tools'
  s.version     = File.open("VERSION").readline.chomp
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'MySQL Management Tools'
  s.description = 'A library and tools for managing MySQL servers'
  s.authors     = [ 'Jeremy Cole', 'Will Gunty' ]
  s.email       = ['jeremycole@twitter.com', 'wg@twitter.com']
  s.homepage    = 'https://github.com/jeremycole/mysql_management_tools'

  s.files = [
    'lib/mysql_management/basic_interaction.rb',
    'lib/mysql_management/mysql_connection_manager.rb',
    'lib/mysql_table_manager/abstract_task.rb',
    'lib/mysql_table_manager/table_manager.rb',
    'lib/mysql_table_manager.rb',
  ]
  s.files += Dir.glob("lib/mysql_table_manager/task/*.rb")

  s.executables = [
    'mysql_table_manager',
  ]
  s.add_dependency('inifile', '>=2.0.2')
end
