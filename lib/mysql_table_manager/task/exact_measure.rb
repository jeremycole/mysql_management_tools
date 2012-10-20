module MysqlTableManager
  class Task::ExactMeasure < AbstractTask
    def self.description
      "Report the table sizes in bytes, and the exact number of rows."
    end

    def print_table_size(host, table, size)
      table_manager.log "%s/%s: table_size: %i, %i, %i, %i" % [
        host, table,
        size["rows"], size["index"], size["data"], size["total"]
      ]
    end

    def apply(host, table)
      print_table_size(host, table, connection_manager.table_size(host, table, true))
    end
  end
end