module UserCommands
  attr_reader :command, :attribute, :criteria, :criteria_two

  def process_user_commands
    @command = @choice[0]
    @attribute = @choice[1]
    @criteria = @choice[2]
    @criteria_two = @choice[3]

    case
    when command == 'help' || command == 'h'
      help(attribute)
    when command == 'load'
      load_command
    when command == 'find'
      find_command
    when command == 'queue'
      queue_command
    when quit?
      @messager.quit
      return 0
    end
  end

  def load_command
    if @attribute == nil
      loader
    else
      loader(@attribute)
    end
  end

  def queue_command
    case attribute
    when nil
      @messager.invalid_queue_command
    when 'print'
      queue_print
    when 'count'
      @messager.queue_size(@queue.results)
    when 'clear'
      @queue.clear
      @messager.queue_cleared
    when 'save'
      queue_save
    end
  end

  def queue_print
    if criteria.nil?
      @messager.print_queue(@queue)
    elsif criteria == 'by'
      queue_print_by
    end
  end

  def queue_print_by
    if has_directory_methods? && directory_is_populated?
      @messager.print_sorted_queue(@queue, criteria_two)
    else
      @messager.invalid_print
    end
  end

  def has_directory_methods?
    @directory.directory.first.methods.include?(criteria_two.to_sym)
  end

  def queue_save
    if criteria.nil?
      @messager.invalid_save
    else
      @queue.save(criteria_two)
      @messager.queue_saved
    end
  end

  def directory_is_populated?
    @directory.directory != nil
  end

  def find_command
    if attribute == nil
      @messager.invalid_find
    else
      directory_is_populated? ? find_by : @messager.no_directory_loaded
    end
  end

  def find_by
    element = @choice[2..-1].join(' ')

    if @directory.find_by(attribute.to_sym, element) != "invalid"
      @queue.results = @directory.find_by(attribute.to_sym, element)
      @messager.queue_loaded
    else
      @messager.invalid_search
    end
    
  end

  def loader(file_name = "event_attendees.csv")
    #!@directory.file_exist?("data/" +"#{file_name}")? ? @messager.file_does_not_exist : begin @directory.load_content(file_name); @messager.content_loaded end

    if !@directory.file_exist?("data/" +"#{file_name}")
      @messager.file_does_not_exist
    else
      @directory.load_content(file_name)
      @messager.content_loaded
    end
  end

  def help(param=nil)
    case param
    when nil
      @messager.list_commands
    when "queue"
      help_queue
    when "load"
      @messager.explain_load
    when "find"
      @messager.explain_find
    end
  end

  def help_queue
    if @choice[3] != nil
      param = @choice[2]+@choice[3]
    else
      param = @choice[2]
    end

    case param
    when nil
      @messager.explain_queue
    when 'count'
      @messager.explain_queue_count
    when 'printby'
      @messager.explain_queue_print_by
    when 'print'
      @messager.explain_queue_print
    when 'clear'
      @messager.explain_queue_clear
    when 'saveto'
      @messager.explain_queue_save_to
    else
      @messager.does_not_exist
    end

  end
end
