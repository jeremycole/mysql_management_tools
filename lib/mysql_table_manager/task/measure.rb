module MysqlTableManager
  class Task::Measure < AbstractTask
    def self.description
      "Report the table sizes in bytes, and the estimated number of rows."
    end

    def print_table_size(host, table, size)
      table_manager.log "%s/%s: table_size: %i, %i, %i, %i" % [
        host, table,
        size["rows"], size["index"], size["data"], size["total"]
      ]
    end

    def apply(host, table)
      connection_manager.analyze_table(host, table)
      print_table_size(host, table, connection_manager.table_size(host, table, false))
    end
  end
end