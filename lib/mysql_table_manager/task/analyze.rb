module MysqlTableManager
  class Task::Analyze < AbstractTask
    def self.description
      "Analyze the table by running a ANALYZE TABLE against it."
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.analyze_table(host, table)
    end
  end
end