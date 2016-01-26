class ASTNodeMock
  def initialize(opts)
    @opts
  end

  def name
    @opts[:name] || "turbo_poneys_with_fire"
  end

  def children
    @opts[:children] || []
  end

end