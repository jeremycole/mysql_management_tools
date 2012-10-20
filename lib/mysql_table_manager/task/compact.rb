module MysqlTableManager
  class Task::Compact < AbstractTask
    def self.description
      [
        "Compact the table by running a no-op ALTER TABLE against it. The",
        "InnoDB storage engine is assumed.",
      ].join("\n")
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.compact_table(host, table)
    end
  end
end