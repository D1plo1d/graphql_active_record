Gem::Specification.new do |spec|
  spec.name = "graphql_active_record"
  spec.summary = "ActiveRecord bindings for GraphQL Relay"
  spec.version = "0.0.1"
  spec.licenses = ['MIT']
  spec.authors = ['Rob Gilson']
  spec.files = Dir['lib/*']
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", "~> 4.2.5"
  spec.add_development_dependency "sqlite3"
  spec.add_runtime_dependency "graphql", ["= 0.10.9 "]
  spec.add_runtime_dependency "graphql-relay", ["= 0.6.1 "]

end
