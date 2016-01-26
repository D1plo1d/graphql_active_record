module GraphQL::ActiveRecord::ASTNodeUtils
  # Recursively reduce nested connections for an ast node.
  # Reduces from the most nested connection to the top level ast_node.
  def self.reduce_ast(ast_node, node_info = {top_level_connection: true}, &block)
    # Find out if this node is (probably) a GraphQL Relay connection by checking
    # if its children contain edges and if edge's nodes contain a ast node
    # named "node".
    edges = ast_node.children
      .select{|child_node| child_node.name == "edges"}
      .first
    node_info[:is_connection] = (edges.try(:children)||[]).any? do |nested_node|
      nested_node.name == "node"
    end
    # Recursively find the connections inside of this node and record the
    # return values of the reducer on each child connnection
    nested_memos = []
    ast_node.children.each do |child_node|
      child_node_info = {top_level_connection: false}
      nested_memos += reduce_ast child_node, child_node_info, &block
    end
    # Run the reducer. The inner-most reducer will run first.
    return block.call(ast_node, node_info, nested_memos)
  end

  # Generate a list of connection names that can be used in a ActiveRecord
  # eager_load statement
  def self.eager_load_args_for(ast_node)
    reduce_ast(ast_node) do |ast_node, node_info, nested_connections|
      if node_info[:is_connection] && !node_info[:top_level_connection]
        if nested_connections.length > 0
          return [{ast_node.name => nested_connections}]
        else
          return [ast_node.name]
        end
      else
        return nested_connections
      end
    end
  end

  # Generate a nested hash of connection args that can be used in a ActiveRecord
  # where statement
  def self.where_args_for(ast_node)
    reduce_ast(ast_node) do |ast_node, node_info, nested_where_args|
      # passthrough for non-connections
      next nested_where_args.try :flatten unless node_info[:is_connection]
      # getting custom where args for this connection
      where_args = Hash[ast_node.arguments.map do |ast_arg|
        [ast_arg.key, ast_arg.value]
      end]
      # TODO: merging pagination args
      # TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
      # merging the where args for the nested connections
      nested_where_args.each {|h| where_args.merge! h}
      # returning the where args
      if node_info[:top_level_connection]
        next where_args
      else
        next {ast_node.name => where_args}
      end
    end
  end
end