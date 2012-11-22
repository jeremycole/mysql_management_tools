module MysqlTableManager
  class Task; end

  class AbstractTask
    attr_reader :table_manager

    def initialize(table_manager)
      @table_manager = table_manager
    end

    def connection_manager
      @table_manager.connection_manager
    end

    def self.description
      nil
    end

    def description
      self.class.description
    end

    def self.modifies?
      false
    end

    def modifies?
      self.class.modifies?
    end

    def start
    end

    def finish
    end

    def applies?(host, table)
      true
    end

    def apply(host, table)
      raise RuntimeError.new("#{self.class} does not implement apply!")
    end

    def unapplies?(host, table)
      raise RuntimeError.new("#{self.class} does not implement unapplies?!")
    end

    def unapply(host, table)
      raise RuntimeError.new("#{self.class} does not implement unapply!")
    end
  end
end