#
# This is an example of using mysql_table_manager to perform a schema change.
#
# The following table can be used to test it:
# 
#   CREATE TABLE alter_test (a INT NOT NULL);
#

module MysqlTableManager
  class Task::AlterTest < AbstractTask
    def self.description
      "Alter a table to add a column named 'b'"
    end

    def self.modifies?
      true
    end

    def applies?(host, table)      
      ! connection_manager.list_columns(host, table).include?("b")
    end

    def apply(host, table)
      connection_manager.query(host,
        "ALTER TABLE #{table} ADD COLUMN b INT NOT NULL"
      )
    end

    def unapplies?(host, table)      
      connection_manager.list_columns(host, table).include?("b")
    end

    def unapply(host, table)
      connection_manager.query(host,
        "ALTER TABLE #{table} DROP COLUMN b"
      )
    end
  end
end
