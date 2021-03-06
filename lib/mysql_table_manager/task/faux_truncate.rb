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
      connection_manager.create_empty_table_from(host, table, "#{table}_new")
      connection_manager.modifying_query(host, "RENAME TABLE #{table} TO #{table}_old, " + 
        "#{table}_new TO #{table}")
      connection_manager.drop_table(host, "#{table}_old")
    end
  end
end