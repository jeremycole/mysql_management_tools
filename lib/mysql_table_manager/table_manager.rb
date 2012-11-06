module MysqlTableManager
  class TableManager
    attr_accessor :verbose, :dry_run, :debug
    attr_reader :connection_manager

    def initialize(logger, asker, connection_manager)
      @logger               = logger
      @asker                = asker
      @connection_manager   = connection_manager
      @verbose              = false
      @dry_run              = false
      @debug                = false
    end

    def log(*args)
      @logger.log(*args) if @logger
    end

    def ask(*args)
      @asker.ask(*args) if @asker
    end

    def ask_yesno(*args)
      return true unless @asker
      @asker.ask_yesno(*args)
    end

    def self.each_supported_task
      MysqlTableManager::Task.constants.sort.each do |task_name|
        task_class = MysqlTableManager::Task.const_get(task_name)
        yield task_name, task_class.description
      end
    end

    def task_class(task_name)
      MysqlTableManager::Task.const_get(task_name)
    end

    def maintain_tables(task_name, direction, pattern=//, start=nil)
      task = task_class(task_name).new(self)

      tables = []
      @connection_manager.hosts.sort.each do |host|
        @connection_manager.list_tables(host, pattern).sort.each do |table|
          case
          when direction == :forward && task.applies?(host, table)
            tables << [host, table]
          when direction == :backward && task.unapplies?(host, table)
            tables << [host, table]
          end
        end
      end

      if start
        table_start_found = false
        until table_start_found
          host, table = tables.first
          if "#{host}/#{table}" == start
            table_start_found = true
          else
            tables.shift
          end
        end
      end

      if tables.empty?
        puts
        puts "No tables found for #{task_name}!"
        exit
      end

      puts
      puts "Found the following tables to #{task_name}:"
      tables.each do |host, table|
        puts "  #{host}/#{table}"
      end
      puts

      unless ask_yesno("Apply #{task_name} (#{direction}) to #{tables.size} tables above?")
        puts "Exiting!"
        exit
      end

      table_count = 0
      tables.each do |host, table|
        table_count += 1

        log "#{host}/#{table} (#{table_count} of #{tables.size}): #{task_name}"
        if task.modifies?
          size_before = @connection_manager.table_size(host, table)
        end

        case direction
        when :forward
          task.apply(host, table)
        when :backward
          task.unapply(host, table)
        end

        if task.modifies?
          size_after = @connection_manager.table_size(host, table)
          log "%s/%s: ~%0.1fM rows, %0.1fG+%0.1fG -> %0.1fG+%0.1fG (%0.2f%%+%0.2f%%)" % [
            host, table,
            size_before["rows"].to_f / (1000**2),
            size_before["data"].to_f / (1024**3).to_f,
            size_before["index"].to_f / (1024**3).to_f,
            size_after["data"].to_f / (1024**3).to_f,
            size_after["index"].to_f / (1024**3).to_f,
            100.0 * (size_after["data"].to_f / size_before["data"].to_f),
            100.0 * (size_after["index"].to_f / size_before["index"].to_f),
          ]
        end
      end
    end
  end
end
