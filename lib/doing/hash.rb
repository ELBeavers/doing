# frozen_string_literal: true

module Doing
  # Hash helpers
  class ::Hash
    ##
    ## Freeze all values in a hash
    ##
    ## @return     { description_of_the_return_value }
    ##
    def deep_freeze
      map { |k, v| v.is_a?(Hash) ? v.deep_freeze : v.freeze }.freeze
    end

    def deep_freeze!
      replace deep_freeze
    end

    # Turn all keys into string
    #
    # Return a copy of the hash where all its keys are strings
    def stringify_keys
      each_with_object({}) { |(k, v), hsh| hsh[k.to_s] = v.is_a?(Hash) ? v.stringify_keys : v }
    end

    # Turn all keys into symbols
    def symbolize_keys
      each_with_object({}) { |(k, v), hsh| hsh[k.to_sym] = v.is_a?(Hash) ? v.symbolize_keys : v }
    end

    # Set a nested hash value using an array
    #
    # @example `{}.deep_set(['one', 'two'], 'value')`
    # @example `=> { 'one' => { 'two' => 'value' } }
    #
    # @param      path   [Array] key path
    # @param      value  The value
    #
    def deep_set(path, value)
      obj = self
      path[0...-1].each do |k|
        unless obj.key?(k)
          obj[k] = {}
        end
        obj = obj[k]
      end
      obj[path.last] = value
      self
    end
  end
end
