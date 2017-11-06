module PostgresqlUuidQuotingPatch
  extend ActiveSupport::Concern

  included do
    def _type_cast_with_quoting(value)
      if value.is_a?(UUIDTools::UUID)
        value.to_s
      else
        _type_cast_without_quoting(value)
      end
    end

    alias_method_chain :_type_cast, :quoting
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, PostgresqlUuidQuotingPatch
