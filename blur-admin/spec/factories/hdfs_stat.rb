FactoryGirl.define do
  factory :hdfs_stat do
    config_capacity       { 100000 + rand(10000) }
    present_capacity      { config_capacity - rand(50000) }
    dfs_used_real         { rand 50000 }
    dfs_used_logical      { rand 50000 }
    dfs_remaining         { present_capacity - dfs_used_real }
    dfs_used_percent      { (present_capacity - dfs_used_real) / present_capacity }
    under_replicated      { rand 5 }
    corrupt_blocks        { rand 5 }
    missing_blocks        { rand 5 }
    total_nodes           { rand 5 }
    dead_nodes            { rand 5 }
    sequence(:created_at, 0) {|n| ((n % 3) + 0.9).minute.ago }
  end
end
