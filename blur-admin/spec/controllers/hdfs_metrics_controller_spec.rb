require 'spec_helper'

describe HdfsMetricsController do
  describe "actions" do
    before(:each) do
      # Universal Setup
      setup_tests

      @hdfs_index = FactoryGirl.create_list :hdfs, 2
      Hdfs.stub(:all).and_return(@hdfs_index)
      @hdfs = FactoryGirl.create :hdfs_with_stats
    end

    describe "GET index" do
      it "should set @hdfs_index to Hdfs.All and render index" do
        get :index
        assigns(:hdfs_index).should == @hdfs_index
        response.should render_template :index
      end
    end

    describe "GET stats" do
      it "with only id should return all within last minute" do
        get :stats, :id => @hdfs.id, :stat_min => 1, :format => :json
        assigns(:results).length.should == 1
        response.content_type.should == 'application/json'
      end

      it "with only return the correct properties" do
        get :stats, :id => @hdfs.id, :stat_min => 1, :format => :json
        assigns(:results)[0].attribute_names.should == %w[id created_at present_capacity dfs_used_real live_nodes dead_nodes under_replicated corrupt_blocks missing_blocks]
        response.content_type.should == 'application/json'
      end

      it "with stat_mins = 2 should return all within last 2 minutes" do
        get :stats, :id => @hdfs.id, :stat_min => 2, :format => :json
        assigns(:results).length.should == 2
        response.content_type.should == 'application/json'
      end

      it "with stat_mins = 2 should return all within the previous minute" do
        get :stats, :id => @hdfs.id, :stat_min => 2, :stat_max => 1, :format => :json
        assigns(:results).length.should == 1
        response.content_type.should == 'application/json'
      end

      it "with stat_id = @hdfs.hdfs_stats[1].id should return the last one" do
        get :stats, :id => @hdfs.id, :stat_id => @hdfs.hdfs_stats[1].id, :format => :json
        assigns(:results).length.should == 1
        response.content_type.should == 'application/json'
      end
    end
  end
end
