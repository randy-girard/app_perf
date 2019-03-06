module PluckToHash
  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_to_hash(*keys)
      block_given = block_given?
      hash_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:hash_type, HashWithIndifferentAccess) : HashWithIndifferentAccess

      keys, formatted_keys = format_keys(keys)
      keys_one = keys.size == 1

      pluck(*keys).map do |row|
        value = hash_type[formatted_keys.zip(keys_one ? [row] : row)]
        block_given ? yield(value) : value
      end
    end

    def pluck_to_struct(*keys)
      struct_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:struct_type, Struct) : Struct
      block_given = block_given?
      keys, formatted_keys = format_keys(keys)
      keys_one = keys.size == 1

      struct = struct_type.new(*formatted_keys)
      pluck(*keys).map do |row|
        value = keys_one ? struct.new(*[row]) : struct.new(*row)
        block_given ? yield(value) : value
      end
    end

    private
      def get_correct_hash_type(hash, hash_type)
        hash_type == HashWithIndifferentAccess ? hash.with_indifferent_access : hash
      end

      def format_keys(keys)
        if keys.blank?
          [column_names, column_names]
        else
          [
            keys,
            keys.map do |k|
              case k
              when String
                k.split(/\bas\b/i)[-1].strip.to_sym
              when Symbol
                k
              end
            end
          ]
        end
      end

    alias_method :pluck_h, :pluck_to_hash
    alias_method :pluck_s, :pluck_to_struct
  end
end

ActiveRecord::Base.send(:include, PluckToHash)
