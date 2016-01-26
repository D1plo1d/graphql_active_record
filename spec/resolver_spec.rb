require 'spec_helper'
require 'ostruct'

describe GraphQL::ActiveRecord::Resolver do

  let(:ast_utils) do
    class_double("GraphQL::ActiveRecord::ASTNodeUtils")
      .as_stubbed_const(transfer_nested_constants: true)
  end

  describe "#resolve_singular_field" do
    let (:ctx) {OpenStruct.new(ast_node: nil)}

    context "without any models" do
      it "raises an error" do
        resolver = GraphQL::ActiveRecord::Resolver.new "User"

        expect{
          resolver.resolve_singular_field("User", nil, {}, {}, ctx)
        }.to raise_error
      end
    end

    context "with existing models" do
      let (:resolver) {GraphQL::ActiveRecord::Resolver.new "User"}

      before :each do
        3.times {User.create!}
        expect(resolver).to receive(:base_query_for).and_return User.all
      end

      it "returns the first model given a nil id" do
        result = resolver.resolve_singular_field("User", nil, {}, {}, ctx)

        expect(result.id).to eq User.first!.id
      end

      it "decodes the global id and looks up the model given an id" do
        user = User.second!

        result = resolver.resolve_singular_field("User", user.id, {}, {}, ctx)

        expect(result.id).to eq user.id
      end

      it "errors given an invalid id" do
        expect{
          resolver.resolve_singular_field("User", User.last!.id + 99, {}, {}, ctx)
        }.to raise_error
      end

    end
  end

  describe "#resolve_connection" do
    let (:ctx) {OpenStruct.new(ast_node: nil)}

    context "as a top level query" do

      it "returns a query for all models given no args" do
        resolver = GraphQL::ActiveRecord::Resolver.new "User"
        3.times {User.create!}
        expect(resolver).to receive(:base_query_for).and_return User.all

        result = resolver.resolve_connection({}, {}, ctx)

        expect(result.count).to eq 3
      end

      it "returns a paginated query given pagination args" do
        pending "pagination"
        fail

        resolver = GraphQL::ActiveRecord::Resolver.new "User"
        3.times {User.create!}
        expect(resolver).to receive(:base_query_for).and_return User.all
        first_cursor = "TODO!"
        args = {after: first_cursor, first: 2}

        result = resolver.resolve_connection({}, args, ctx)

        expect(result.count).to eq 2
      end

    end

    context "as a query inside another activerecord connection" do
      it "returns activerecord association on it's parent object" do
        resolver = GraphQL::ActiveRecord::Resolver.new("Pet")
        user = User.create!
        pet = Pet.create! user: user
        expect(resolver).to receive(:base_query_for).and_return Pet.all

        result = resolver.resolve_connection(user, {}, ctx)

        expect(result.class.to_s).to eq(
          "Pet::ActiveRecord_Associations_CollectionProxy"
        )
      end

    end
  end

  describe "#base_query_for" do
    it "returns a query for all models" do
      expect(ast_utils).to receive(:eager_load_args_for).and_return nil
      expect(ast_utils).to receive(:where_args_for).and_return nil
      resolver = GraphQL::ActiveRecord::Resolver.new "User"
      3.times {User.create!}

      result = resolver.base_query_for nil

      expect(result.count).to eq 3
    end

    context "given a :query option" do
      it "returns models matching the :query option" do
        expect(ast_utils).to receive(:eager_load_args_for).and_return nil
        expect(ast_utils).to receive(:where_args_for).and_return nil
        resolver = GraphQL::ActiveRecord::Resolver.new("User",
          query: ->{User.where age: 5}
        )
        3.times {User.create! age: 5}
        2.times {User.create! age: 10}

        result = resolver.base_query_for nil

        expect(result.count).to eq 3
      end
    end

    context "given a non-empty ASTNodeUtils.eager_load_args_for" do
      it "eager loads the args" do
        expect(ast_utils).to receive(:eager_load_args_for).and_return(
          [:pets]
        )
        expect(ast_utils).to receive(:where_args_for).and_return nil
        resolver = GraphQL::ActiveRecord::Resolver.new "User"
        3.times {Pet.create! user: User.create!}

        result = resolver.base_query_for nil

        expect(result.first!.pets.loaded?).to eq true
      end
    end

    context "given a non-empty ASTNodeUtils.where_args_for" do
      it "filters the models by those where args" do
        expect(ast_utils).to receive(:eager_load_args_for).and_return nil
        expect(ast_utils).to receive(:where_args_for).and_return(
          {pets: {age: 12}}
        )
        resolver = GraphQL::ActiveRecord::Resolver.new "User"
        3.times {Pet.create! age: 12, user: User.create!}
        2.times {Pet.create! age: 3, user: User.create!}

        result = resolver.base_query_for nil

        expect(result.count).to eq 3
      end
    end

  end

end