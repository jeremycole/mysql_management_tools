module MysqlTableManager
  class Task::Truncate < AbstractTask
    def self.description
      [
        "Truncate the table, removing all rows and recreating the table to",
        "regain disk space.",
      ].join("\n")
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.truncate_table(host, table)
    end
  end
end