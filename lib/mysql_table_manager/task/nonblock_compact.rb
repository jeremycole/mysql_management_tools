module MysqlTableManager
  class Task::NonBlockCompact < AbstractTask
    def self.description
      [
        "Compact the table by running a no-op ALTER TABLE against it. The",
        "InnoDB storage engine is assumed.  This uses the Non-blocking alter",
        "that is present only in Twitter MySQL builds.",
      ].join("\n")
    end

    def self.modifies?
      true
    end

    def apply(host, table)
      connection_manager.nonblock_compact_table(host, table)
    end
  end
end