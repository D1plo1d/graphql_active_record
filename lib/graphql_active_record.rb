require "graphql"
require "graphql/relay"

module GraphQL::ActiveRecord
  require "graphql_active_record/ast_node_utils.rb"
  require "graphql_active_record/resolver.rb"
  require "graphql_active_record/definition_config.rb"

  def self.global_node_identification=(val)
    @global_node_identification = val
  end

  def self.global_node_identification
    @global_node_identification
  end

end
