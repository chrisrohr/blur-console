class BlurTablesController < ApplicationController
  before_filter :zookeepers,        :only => :index
  before_filter :current_zookeeper, :only => :index

  def index
    @blur_tables = @current_zookeeper.blur_tables
    @blur_tables.sort!{|t1,t2|t1 <=> t2}
  end

  def update
    @blur_table = BlurTable.find(params[:id])
    if params[:enable]
      @blur_table.enable
    elsif params[:disable]
      @blur_table.disable
    end

    respond_to do |format|
      format.html { render :partial => 'blur_table', :locals => {:blur_table => @blur_table }}
    end
  end

  def destroy
    @blur_table = BlurTable.find(params[:id])
    destroy_index = params[:delete_index] == 'true'
    @blur_table.destroy destroy_index

    respond_to do |format|
      format.js  { render :nothing => true }
    end
  end
end
