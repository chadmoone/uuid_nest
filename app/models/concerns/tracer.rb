module Tracer extend ActiveSupport::Concern
  included do
    unless (const_defined?(:TRACER_INIT))
      
      # Prevent redefining constants when Rails reloads
      TRACER_INIT = true;

      # Formatting Options
      CLEAR       = "\e[0m"
      BOLD        = "\e[1m"
      UNDERSCORE  = "\e[4m"
      BLINK       = "\e[5m"
      REVERSE     = "\e[7m"
      CONCEALED   = "\e[8m"

      # Foreground Colors
      BLACK   = "\e[30m"
      RED     = "\e[31m"
      GREEN   = "\e[32m"
      YELLOW  = "\e[33m"
      BLUE    = "\e[34m"
      MAGENTA = "\e[35m"
      CYAN    = "\e[36m"
      WHITE   = "\e[37m"

      # Background Colors
      BLACK_BG   = "\e[40m"
      RED_BG     = "\e[41m"
      GREEN_BG   = "\e[42m"
      YELLOW_BG  = "\e[43m"
      BLUE_BG    = "\e[44m"
      MAGENTA_BG = "\e[45m"
      CYAN_BG    = "\e[46m"
      WHITE_BG   = "\e[47m"
    end

    after_initialize do |o|
      send_log "#{o.class}\n  -after_initialize(#{o.id}) - new_record? #{self.new_record?}", RED, YELLOW_BG
      puts "------\n"
      send_log Thread.current.backtrace.join("\n")
    end
   
    after_find do |o|
      send_log "#{o.class}\n  -after_find(#{o.id}) - new_record? #{self.new_record?}", RED, YELLOW_BG

      puts "------\n"
      send_log Thread.current.backtrace.join("\n")
    end


    def assign_nested_attributes_for_one_to_one_association(association_name, attributes)
      send_log "#{self.class}(#{self.id})\n  -assign_nested_attributes_for_one_to_one_association\n  -association_name:#{association_name}, attributes:#{attributes.inspect}\n  - new_record? #{self.new_record?}", BLUE, WHITE_BG
      options = self.nested_attributes_options[association_name]
      send_log "  options:#{options}", BLACK, MAGENTA_BG

      association = association(association_name)
      send_log "  association:#{association.inspect}", BLACK, MAGENTA_BG
      super
    end

    def assign_nested_attributes_for_collection_association(association_name, attributes_collection)
      send_log "#{self.class}(#{self.id})\n  -assign_nested_attributes_for_collection_association\n  -association_name:#{association_name}, attributes_collection:#{attributes_collection.inspect}\n  - new_record? #{self.new_record?}", BLUE, WHITE_BG
      
      
      options = self.nested_attributes_options[association_name]
      send_log "  options:#{options}", BLACK, MAGENTA_BG

      unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
        raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
      end

      check_record_limit!(options[:limit], attributes_collection)

      if attributes_collection.is_a? Hash
        keys = attributes_collection.keys
        attributes_collection = if keys.include?('id') || keys.include?(:id)
          [attributes_collection]
        else
          attributes_collection.values
        end
      end

      association = association(association_name)
      send_log "  association:#{association.inspect}", BLACK, MAGENTA_BG
      puts association.options[:primary_key]
      puts association.options.has_key? :primary_key
      

      pk_name = association.options.has_key?(:primary_key) ? association.options[:primary_key].to_s : 'id'
      
      

      existing_records = if association.loaded?
        association.target
      else
        attribute_ids = attributes_collection.map {|a| a[pk_name] || a[pk_name.to_sym] }.compact
        attribute_ids.empty? ? [] : association.scope.where(association.klass.primary_key => attribute_ids)
      end

      attributes_collection.each do |attributes|
        attributes = attributes.with_indifferent_access

        if attributes[pk_name].blank?
          unless reject_new_record?(association_name, attributes)
            association.build(attributes.except(*UNASSIGNABLE_KEYS))
          end
        elsif existing_record = existing_records.detect { |record| record.id.to_s == attributes[pk_name].to_s }
          unless association.loaded? || call_reject_if(association_name, attributes)
            # Make sure we are operating on the actual object which is in the association's
            # proxy_target array (either by finding it, or adding it if not found)
            target_record = association.target.detect { |record| record == existing_record }

            if target_record
              existing_record = target_record
            else
              association.add_to_target(existing_record)
            end
          end

          if !call_reject_if(association_name, attributes)
            assign_to_or_mark_for_destruction(existing_record, attributes, options[:allow_destroy])
          end
        else
          raise_nested_attributes_record_not_found!(association_name, attributes[pk_name])
        end
      end

      super
    end

    

    def create_or_update
      # raise ReadOnlyRecord if readonly?
      # result = new_record? ? create_record : update_record
      # result != false
      send_log "#{self.class}(#{self.id})\n  -create_or_update - new_record? #{self.new_record?}", BLUE, WHITE_BG
      super
    end


    def initialize(attributes = nil)
      # defaults = self.class.column_defaults.dup
      # defaults.each { |k, v| defaults[k] = v.dup if v.duplicable? }

      # @attributes   = self.class.initialize_attributes(defaults)
      # @columns_hash = self.class.column_types.dup

      # init_internals
      # init_changed_attributes
      # ensure_proper_type
      # populate_with_current_scope_attributes

      # assign_attributes(attributes) if attributes

      # yield self if block_given?
      # run_callbacks :initialize unless _initialize_callbacks.empty?
      send_log "#{self.class}\n  -initialize(attributes=#{attributes}) - new_record? #{self.new_record?}", BLUE, WHITE_BG
      # puts "------\n"
      # send_log Thread.current.backtrace.join("\n")
      super
    end



    # Updates its receiver just like +update+ but calls <tt>save!</tt> instead
    # of +save+, so an exception is raised if the record is invalid.
    def update!(attributes)
      # The following transaction covers any possible database side-effects of the
      # attributes assignment. For example, setting the IDs of a child collection.
      # with_transaction_returning_status do
      #   assign_attributes(attributes)
      #   save!
      # end
      send_log "#{self.class}(#{self.id})\n  -update!(attributes=#{attributes}) - new_record? #{self.new_record?}", BLUE, WHITE_BG
      super
    end




    def send_log(s, color=nil, bg_color=nil, formatting=nil)
      formatting ||= BOLD
      color ||= WHITE
      bg_color ||= BLUE_BG
      logger.debug  "#{formatting unless formatting.nil?}#{color unless color.nil?}#{bg_color unless bg_color.nil?}#{s}#{CLEAR}"
#      logger.debug  "#{BOLD}#{BLINK}#{YELLOW_BG}#{MAGENTA}#{s}#{CLEAR}"
    end


  end
end