module MysqlTableManager
  class Task::Optimize < AbstractTask
    def self.description
      "Optimize the table by running a OPTIMIZE TABLE against it."
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.optimize_table(host, table)
    end
  end
end