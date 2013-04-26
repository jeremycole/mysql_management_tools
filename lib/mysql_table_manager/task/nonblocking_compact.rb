module MysqlTableManager
  class Task::NonBlockingCompact < AbstractTask
    def self.description
      [
        "Compact the table by running a no-op alter table against it. The",
        "InnoDB storage engine is assumed.  This uses the Non-blocking alter",
        "that is present only in Twitter MySQL version 5.5.28.t8 and higher",
      ].join("\n")
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.nonblocking_compact_table(host, table)
    end
  end
end