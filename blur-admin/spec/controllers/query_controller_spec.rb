require "spec_helper"

describe QueryController do

  before (:each) do
    @client = mock(Blur::Blur::Client)
    BlurThriftClient.stub!(:client).and_return(@client)
    
    set = Set.new ['deptNo', 'moreThanOneDepartment', 'name']
    @test_schema1 = Blur::Schema.new :columnFamilies => {'table1'=> set}
    @test_schema2 = Blur::Schema.new :columnFamilies => {'table1'=> set, 'table2' => set}
    @ability = Ability.new User.new
    @ability.stub!(:can?).and_return(true)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe "show" do
    it "renders the show template" do
      @client.should_receive(:tableList).and_return(['blah'])
      @client.should_receive(:schema).with('blah').and_return(Blur::Schema.new)
      get :show
      response.should render_template "show"
    end
    
    it "find and assign tables and columns" do
      @client.should_receive(:tableList).and_return(['table1'])
      @client.should_receive(:schema).with('table1').and_return(@test_schema1)
      get :show
      assigns(:tables).should == ['table1']
      assigns(:columns).should == @test_schema1
    end

    it "find and assign tables and columns when no tables are available" do
      @client.should_receive(:tableList).and_return([])
      get :show
      assigns(:tables).should == []
      assigns(:columns).should == nil
    end
  end
  
  describe "filters" do
    it "renders the filters template" do
      @client.should_receive(:schema).with('table1').and_return(Blur::Schema.new)
      get :filters, :table => 'table1'
      response.should render_template "filters"
    end

    it "should find and assign columns" do
      @client.should_receive(:schema).with('table1').and_return(@test_schema1)
      get :filters, :table => 'table1'
      assigns(:columns).should == @test_schema1
    end
  end

  describe "create" do
    before (:each) do
      test1_col1 = Blur::Column.new :name => 'deptNo', :values => ['val1', 'val2', 'val3']
      test1_col2 = Blur::Column.new :name => 'moreThanOneDepartment', :values => ['val1', 'val2', 'val3']
      test1_col3 = Blur::Column.new :name => 'name', :values => ['val1', 'val2', 'val3']
      @test1_cf1 =  Blur::ColumnFamily.new :records => {'key1' => [test1_col1, test1_col2, test1_col3]}, :family => 'table1'
      @test1_cf2 = Blur::ColumnFamily.new :records => {'key1' => [test1_col1], 'key2' => [test1_col1, test1_col2, test1_col3]}, :family => 'table2'

      test1_set1 = Set.new [@test1_cf1]
      test1_result1 = create_blur_result(:set => test1_set1)
      @test1_query = Blur::BlurResults.new :results => [test1_result1], :totalResults => 1

      test2_col1 = Blur::Column.new :name => 'deptNo', :values => ['val1', 'val2', 'val3']
      test2_col2 = Blur::Column.new :name => 'moreThanOneDepartment', :values => []
      test2_col3 = Blur::Column.new :name => 'name', :values => ['val1']
      @test2_cf1 = Blur::ColumnFamily.new :records => {'key1' => [test2_col1, test2_col2, test2_col3]}, :family => 'table1'
      @test2_cf2 = Blur::ColumnFamily.new :records => {'key1' => [test2_col1], 'key2' => [test2_col1, test2_col2, test2_col3]}, :family => 'table2'

      test2_set1 = Set.new [@test2_cf1]
      test2_set2 = Set.new [@test2_cf2]
      test2_result1 = create_blur_result(:set => test2_set1)
      test2_result2 = create_blur_result(:set => test2_set2)
      @test2_query = Blur::BlurResults.new :results => [test2_result1, test2_result2], :totalResults => 2
    end

    def create_blur_result(options)
      row = Blur::Row.new :id => 'string' , :columnFamilies => options[:set]
      rowresult = Blur::FetchRowResult.new :row => row
      fetchresult = Blur::FetchResult.new :rowResult => rowresult
      result = Blur::BlurResult.new :fetchResult => fetchresult
      result
    end
    
    it "renders the create template when column_family & record_count < count & families_include" do
      @client.should_receive(:query).and_return(@test1_query)
      @client.should_receive(:schema).with('table').and_return(@test_schema1)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["family_table1", "column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name"]
      response.should render_template "create"
    end
    
    it "renders the create template when column_family & record_count < count & !families_include" do
      @client.should_receive(:query).and_return(@test1_query)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name"]
      response.should render_template "create"
    end

    it "renders the create template when column_family & !record_count < count & families_include" do
      set2 = Set.new [@test2_cf2, @test2_cf1]
      test_result2 = create_blur_result(:set => set2)
      test_query = Blur::BlurResults.new :results => [test_result2], :totalResults => 1

      @client.should_receive(:query).and_return(test_query)
      @client.should_receive(:schema).with('table').and_return(@test_schema2)
      @client.should_receive(:schema).with('table').and_return(@test_schema2)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["family_table1", "column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name", "family_table2", "column_table2_deptNo", "column_table2_moreThanOneDepartment", "column_table2_name"]
      response.should render_template "create"
    end

    it "renders the create template when column_family & !record_count < count & !families_include" do
      set2 = Set.new [@test1_cf2, @test1_cf1]
      test_result2 = create_blur_result(:set => set2)
      test_query = Blur::BlurResults.new :results => [test_result2], :totalResults => 1

      @client.should_receive(:query).and_return(test_query)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name", "column_table2_deptNo", "column_table2_moreThanOneDepartment", "column_table2_name"]
      response.should render_template "create"
    end

    it "renders the create template when !column_family & families_include" do
      @client.should_receive(:query).and_return(@test2_query)
      @client.should_receive(:schema).with('table').and_return(@test_schema2)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["family_table1", "column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name"]
      response.should render_template "create"
    end

    it "renders the create template when !column_family & !families_include" do
      @client.should_receive(:query).and_return(@test2_query)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name"]
      response.should render_template "create"
    end

    it "renders the create template when superQueryOn is false" do
      @client.should_receive(:query).and_return(@test1_query)
      @client.should_receive(:schema).with('table').and_return(@test_schema1)
      get :create, :t => "table", :q => "query", :r => 25, :column_data => ["family_table1", "column_table1_deptNo", "column_table1_moreThanOneDepartment", "column_table1_name"], :s => false
      response.should render_template "create"
    end
  end
end
