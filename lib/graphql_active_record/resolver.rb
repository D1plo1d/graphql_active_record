class GraphQL::ActiveRecord::Resolver

  attr_reader :assoc_singular_name, :assoc_class_name, :type

  def initialize(name, opts={})
    unless name.present?
      raise "requires a name"
    end
    name = name.to_s.downcase
    @assoc_plural_name = name.pluralize
    @assoc_singular_name = name.singularize
    @assoc_class_name = @assoc_singular_name.classify
    opts[:type] ||= -> {"#{@assoc_singular_name}_type".classify.constantize}
    opts[:query] ||= -> {@assoc_class_name.constantize.all}
    @type = opts[:type]
    # TODO: queries can only be used at top level connections so we should
    # throw an error when they are added to lower level connections (for now).
    # This is because they are not attached to the ast_node for the
    # ast_node_utils to find.
    @query = opts[:query]
  end

  def resolve_singular_field(type, id, obj, args, ctx)
    query = base_query_for(ctx.ast_node)
    if id.present?
      # # TODO: Reimplement Security
      # if assoc_class_name != type.to_s
      #   raise(
      #     "id does not have correct type " +
      #     "(expected: #{assoc_class_name}, got: #{type.to_s})"
      #   )
      # end
      query = query.where(id: id)
    end
    return query.first!
  end

  def resolve_connection(obj, args, ctx)
    # Nested connections/ActiveRecord associations
    if obj.is_a?(ActiveRecord::Base)
      return obj.send @assoc_plural_name
    # Top level connections
    else
      query = base_query_for(ctx.ast_node)
      return query
    end
  end

  def base_query_for(ast_node)
    query = @query.call
    eager_load_args = GraphQL::ActiveRecord::ASTNodeUtils.eager_load_args_for(
      ast_node
    )
    query = query.eager_load *eager_load_args if eager_load_args.present?
    query = query.where(
      GraphQL::ActiveRecord::ASTNodeUtils.where_args_for ast_node
    )
    return query
  end

end