require 'mysql_table_manager/abstract_task'
require 'mysql_table_manager/table_manager'

module_glob = File.dirname(__FILE__) + "/mysql_table_manager/task/*.rb"
Dir.glob(module_glob).each do |file|
  require file
end
