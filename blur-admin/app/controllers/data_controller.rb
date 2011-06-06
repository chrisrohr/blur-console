class DataController < ApplicationController
  before_filter :setup_thrift
  before_filter :table_name, :only => [:update, :destroy_table]
  after_filter :close_thrift

  def show
    bq = Blur::BlurQuery.new :queryStr => '*', :fetch => 1, :superQueryOn => false
    @tables = @client.tableList.sort
    @tdesc = {}
    @tschema = {}
    @tserver = {}
    @tcount = {}
    @tables.each do |table|
      @tdesc[table] = @client.describe(table)
      @tschema[table] = @client.schema(table).columnFamilies
      @tserver[table] = @client.shardServerLayout(table)
      @tcount[table] = @client.query(table, bq).totalResults
    end
  end

  #TODO: Add feedback to enable / disable on view
  def update
    action = params[:operation]
    if action == 'enable'
      @client.enableTable table_name
    elsif action == 'disable'
      @client.disableTable table_name
    end

    render :json => @client.describe(table_name).isEnabled
  end

  #TODO: Add feedback to delete button on view
  def destroy 
    # TODO: Uncomment below when we can create a table
    #client.removeTable(params[:name], false)
    render :json => !@client.tableList.include?(table_name)
  end

  protected

  def table_name
    table_name = params[:id]
  end

end
