require 'calculate-all/helpers'

module CalculateAllHashes
  module Querying
    delegate :calculate_all_hashes, to: :all
  end
end

module CalculateAllHashes
  # Method to aggregate function results in one request
  def calculate_all_hashes(*function_aliases, **functions, &block)

    # If only one function_alias is given, the result can be just a single value
    # So return [{ cash: 3 }] instead of [{ cash: { count: 3 }}]
    if function_aliases.size == 1 && functions == {}
      return_plain_values = true
    end

    # Convert the function_aliases to actual SQL
    functions.merge!(
      CalculateAll::Helpers.decode_function_aliases(function_aliases)
    )

    # Check if any functions are given
    if functions == {}
      raise ArgumentError, 'provide at least one function to calculate'
    end

    # If function is called without a group, the pluck method will still return
    # an array but it is an array with the final results instead of each group
    # The plain_rows boolean states how the results should be used
    if functions.size == 1 && group_values.size == 0
      plain_rows = true
    end

    # Final output hash
    results = {}

    # Fetch all the requested calculations from the database
    # Note the map(&:to_s). It is required since groupdate returns a
    # Groupdate::OrderHack instead of a string for the group_values which is not
    # accepted by ActiveRecord's pluck method.
    sql_snippets = group_values.map(&:to_s) + functions.values

    # Fix DEPRECATION WARNING:
    # Dangerous query method, will be disallowed in Rails 6.0
    # using Arel.sql() to silence the warning
    # https://github.com/rails/rails/commit/310c3a8f2d043f3d00d3f703052a1e160430a2c2
    pluck_to_hash(*sql_snippets.map { |sql| Arel.sql(sql) }).each do |data|
      timestamp = data[group_values.first]

      results[timestamp] ||= []
      result = {}

      f = functions.clone

      f.each do |(key, value)|
        result[key] = data[value]
      end

      results[timestamp] << result
    end

    results
  end
end

# Make the calculate_all method available for all ActiveRecord::Relations instances
ActiveRecord::Relation.include CalculateAllHashes

# Make the calculate_all method available for all ActiveRecord::Base classes
# You can for example call Orders.calculate_all(:count, :sum_cents)
ActiveRecord::Base.extend CalculateAllHashes::Querying

# A hack for groupdate since it checks if the calculate_all method is defined
# on the ActiveRecord::Calculations module. It is never called but it is just
# needed for the check.
ActiveRecord::Calculations.include CalculateAllHashes::Querying
