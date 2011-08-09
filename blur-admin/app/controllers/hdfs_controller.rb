class HdfsController < ApplicationController

  require 'hdfs_thrift_client'

  def index
    if Hdfs.all.length > 0
      hdfs_ids = Hdfs.select 'id, host, port'
      @files = {}
      @connections = {}
      hdfs_ids.each do |hdfs_id|
        @hdfs = HdfsThriftClient.client(hdfs_id.host, hdfs_id.port)
        @hdfs.ls('/').each do |file|
          @files[file] = get_files file
          @connections[file] = hdfs_id.id
        end
      end
    end
  end

  def files
    hdfs_model = Hdfs.find params[:connection]
    hdfs = HdfsThriftClient.client(hdfs_model.host, hdfs_model.port)
    file = params[:file].gsub(/[ *]/, ' ' => '/', '*' => '.')
    file_names_hash = {}

    if hdfs.exists? file
      file_names = hdfs.ls file
      if file_names.length == 1 and file == file_names[0]
        file_names.clear
      end
      file_names.each do |name|
        file_names_hash[name] = hdfs.stat name
      end
    end

    puts file_names_hash

   render :template=>'hdfs/files.html.haml', :layout => false, :locals => {:connection => params[:connection], :file_names_hash => file_names_hash}
  end

  def get_files curr_file
    curr_file_children_hash = {}
    if @hdfs.exists? curr_file
      curr_file_children = @hdfs.ls curr_file
      curr_file_children.each do |child|
        if !curr_file.eql? child
          curr_file_children_hash[child] = get_files child
        end
      end
    end
    curr_file_children_hash
  end
end
