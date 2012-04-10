require "spec_helper"

describe ZookeepersController do
  describe "routing" do
    it "base and zookeepers routes to #index" do
      get("/").should route_to(:controller => "zookeepers", :action => "index")
      get("/zookeepers").should route_to(:controller => "zookeepers", :action => "index")
    end

    it "dashboard routes to #dashboard" do
      get("/zookeepers/dashboard").should route_to(:controller => "zookeepers", :action => "dashboard")
    end

    it "zookeepers with id routes to #show" do
      get("/zookeepers/1").should route_to(:controller => "zookeepers", :action => "show", :id => '1')
    end

    it "zookeepers with id and controller_id routes to #destroy_controller" do
      delete("/zookeepers/1/controller/1").should route_to(:controller => "zookeepers", :action => "destroy_controller", :id => '1', :controller_id => '1')
    end

    it "zookeepers with id and routes to #shards" do
      get("/zookeepers/1/shards").should route_to(:controller => "zookeepers", :action => "shards", :id => '1')
    end

    it "zookeepers with id and shard_id routes to #destroy_shard" do
      delete("/zookeepers/1/shard/1").should route_to(:controller => "zookeepers", :action => "destroy_shard", :id => '1', :shard_id => '1')
    end

    it "zookeepers with id and cluster_id routes to #destroy_cluster" do
      delete("/zookeepers/1/cluster/1").should route_to(:controller => "zookeepers", :action => "destroy_cluster", :id => '1', :cluster_id => '1')
    end

    it "delete zookeepers with id routes to #destroy_zookeeper" do
      delete("/zookeepers/1").should route_to(:controller => "zookeepers", :action => "destroy", :id => '1')
    end
  end
end