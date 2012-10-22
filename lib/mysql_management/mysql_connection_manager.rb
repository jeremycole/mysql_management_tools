require 'mysql'

class MysqlConnectionManager
  class HostNotRegistered < Exception; end

  def initialize(logger, asker=nil)
    @logger = logger
    @asker  = asker
    @options = {
      :verbose  => true,
      :confirm  => false,
      :dry_run  => false,
    }
    @hosts = {}
    @connection_cache = {}
    
    @default_user = nil
    @default_password = nil
    @default_db = nil
  end

  def log(*args)
    @logger.log(*args) if @options[:verbose]
  end

  def ask(*args)
    return true unless @asker
    @asker.ask(*args)
  end

  def ask_yesno(*args)
    return true unless @asker
    @asker.ask_yesno(*args)
  end

  def set_options(options)
    options.each do |key, value|
      unless @options.has_key? key
        raise "Unknown option #{key}"
      end
      @options[key] = value
    end

    @options
  end

  def set_default_credentials(user, password, db)
    @default_user     = user
    @default_password = password
    @default_db       = db

    nil
  end

  def add_host(host, user=nil, password=nil, db=nil)
    @hosts[host] = {
      :user     => user       || @default_user,
      :password => password   || @default_password,
      :db       => db         || @default_db,
    }

    connect(host)
    @hosts.size
  end

  def connect(host)
    raise HostNotRegistered unless @hosts[host]

    log "#{host} -> Connecting to MySQL"

    @connection_cache[host] = Mysql.new(
      host,
      @hosts[host][:user],
      @hosts[host][:password],
      @hosts[host][:db]
    )

    @connection_cache.size
  end

  def yield_with_retry(host, retries = 5)
    while retries > 0
      begin
        return yield
      rescue Mysql::Error
        log "#{host} -> Error %d" % @connection_cache[host].errno
        # ERROR 2006 (HY000): MySQL server has gone away
        if @connection_cache[host].errno == 2006
          connect host
          retries -= 1
        else
          raise
        end
      end
    end
  end

  def query(host, query)
    log "#{host} -> #{query}"
  
    yield_with_retry(host) do
      @connection_cache[host].query(query)
    end
  end

  def modifying_query(host, query)
    if @options[:dry_run]
      log("#{host} -> (dry run) #{query}")
    else
      if !@options[:confirm] ||
        (@options[:confirm] && ask_yesno("#{host} -> #{query}\nExecute query?"))
        query(host, query)
      end
    end
  end

  def list_tables(host, pattern = //)
    log "#{host} -> Listing tables"
  
    tables = yield_with_retry(host) do
      @connection_cache[host].list_tables
    end
  
    tables.select { |name| name =~ pattern }.sort
  end

  def list_columns(host, table)
    column_list_query = 
      "SELECT column_name FROM information_schema.columns " +
      "WHERE table_schema = database() AND table_name = '#{table}'"

    if result = query(host, column_list_query)
      columns = []
      result.each_hash do |row|
        columns << row['column_name']
      end

      columns
    end
  end

  def show_create_table(host, table)
    show_query = "SHOW CREATE TABLE `#{table}`"

    if result = query(host, show_query)
      if create_table = result.fetch_hash
        create_table["Create Table"]
      end
    end
  end

  def table_status(host, table)
    table_status_query = "SHOW TABLE STATUS LIKE '#{table.gsub('_', '\_')}'"

    if result = query(host, table_status_query)
      if status = result.fetch_hash
        status
      end
    end
  end

  def table_size(host, table, exact_count=false)
    if status = table_status(host, table)
      {
        "rows"  => exact_count ? count_table(host, table) : status["Rows"].to_i,
        "data"  => status["Data_length"].to_i,
        "index" => status["Index_length"].to_i,
        "total" => status["Data_length"].to_i + status["Index_length"].to_i,
      }
    end
  end

  def count_table(host, name)
    count_query = "SELECT COUNT(*) AS row_count FROM `#{name}`"

    if result = query(host, count_query)
      if status = result.fetch_hash
        status["row_count"].to_i
      end
    end
  end

  def rename_table(host, old_name, new_name)
    modifying_query host, "RENAME TABLE `#{old_name}` TO `#{new_name}`"
  end

  def drop_table(host, name)
    modifying_query host, "DROP TABLE IF EXISTS `#{name}`"
  end

  def truncate_table(host, name)
    modifying_query host, "TRUNCATE TABLE `#{name}`"
  end

  def compact_table(host, name)
    # This should perhaps check the table's storage engine and use that here
    # but since we only care about InnoDB for the moment, this will suffice.
    modifying_query host, "ALTER TABLE `#{name}` ENGINE=InnoDB"
  end

  def hosts
    @hosts.keys.sort
  end

end