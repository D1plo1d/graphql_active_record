class GraphQL::DefinitionHelpers::DefinedByConfig::DefinitionConfig
  def active_record_connection(name, opts = {})
    opts[:global_node_identification] ||= (
      GraphQL::ActiveRecord.global_node_identification
    )
    resolver = active_record_resolver_for name, opts
    # TODO: only add fields at the top level
    # Field
    field resolver.singular_name.to_sym do
      type resolver.type
      argument :id, types.String
      resolve -> (obj, args, ctx) {
        if args["id"].present?
          type, id = opts[:global_node_identification].from_global_id args["id"]
        else
          type, id = [nil, nil]
        end
        resolver.resolve_singular_field type, id, obj, args, ctx
      }
    end
    # Connection
    connection(name, -> {resolver.type.call.connection_type}) do
      resolve -> (obj, args, ctx) {
        resolver.resolve_connection obj, args, ctx
      }
    end
  end

  protected

  def active_record_resolver_for(name, opts)
    GraphQLActiveRecord::Resolver.new(name, opts)
  end

end