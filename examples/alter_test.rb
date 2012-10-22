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

    # Does this class modify anything? If so, we won't call 'apply' if
    # running in dry-run mode.
    def self.modifies?
      true
    end

    # Would 'apply' do something? Check for the existence of column 'b',
    # and if it is missing, 'apply' should work.
    def applies?(host, table)      
      ! connection_manager.list_columns(host, table).include?("b")
    end

    # Run the ALTER TABLE to modify the table in a 'forward' direction,
    # adding the column.
    def apply(host, table)
      connection_manager.query(host,
        "ALTER TABLE #{table} ADD COLUMN b INT NOT NULL"
      )
    end

    # Would 'unapply' do something? Check for the existence of column 'b',
    # and if it is present, 'unapply' should work.
    def unapplies?(host, table)      
      connection_manager.list_columns(host, table).include?("b")
    end

    # Run the ALTER TABLE to modify the table in a 'backward' direction,
    # removing the column.
    def unapply(host, table)
      connection_manager.query(host,
        "ALTER TABLE #{table} DROP COLUMN b"
      )
    end
  end
end
