class BasicInteraction
  class Logger
    def log(message)
      puts Time.now.strftime("%F %T ") + message
      $stdout.flush
    end
  end

  class Asker
    def ask(prompt = nil, echo = true)
      print "#{prompt} " if prompt
      $stdout.flush
    
      system "stty -echo" if not echo
      response = $stdin.gets.sub(/\n$/, "")
      system "stty echo" if not echo
      puts if not echo
    
      response
    end

    def ask_yesno(*args)
      while true
        case ask(*args)
        when /^ye?s?/i
          return true
        when /^no?/i
          return false
        end    
      end
    end  
  end
end