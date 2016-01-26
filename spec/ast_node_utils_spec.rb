require 'spec_helper'
require "ostruct"

describe GraphQL::ActiveRecord::ASTNodeUtils do
  describe "#eager_load_args_for" do
    it "returns a nested array of associations" do
      association_name = "cats"
      # build a node with a nested connection
      edges = OpenStruct.new(
        name: association_name,
        children: [OpenStruct.new(name: "edges", children: [])]
      )
      ast_node = OpenStruct.new(
        name: "super_bosskiller_89",
        children: [edges]
      )

      result = GraphQL::ActiveRecord::ASTNodeUtils.eager_load_args_for ast_node

      expect(result).to eq [association_name]
    end
  end

  describe "#where_args_for" do
    it "composes nested queries" do
      # See: http://sequel.jeremyevans.net/rdoc/files/doc/querying_rdoc.html#label-Table-2FDataset+to+Join
      pending "a rewrite to Sequel"
      fail
    end
  end
end
