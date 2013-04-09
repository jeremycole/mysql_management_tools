module MysqlTableManager
  class Task::FauxTruncate < AbstractTask
    def self.description
      [
        "Truncates table by creating a duplicate table, swapping it",
        "with the old, then dropping the old table.  This secondary method",
        "is used because of innodb stalls when using the actual truncate",
        "command.  See http://bugs.mysql.com/bug.php?id=68184",
      ].join("\n")
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.modifying_query(host, "CREATE TABLE #{table}_to_drop LIKE #{table}")
      connection_manager.swap_tables(host, table, "#{table}_to_drop")
      connection_manager.drop_table(host, "#{table}_to_drop")
    end
  end
end