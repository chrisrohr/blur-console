class HdfsController < ApplicationController

  require 'hdfs_thrift_client'

  def index
    if Hdfs.all.length > 0
      @hdfs_ids = Hdfs.select 'id'
      puts '******************'
      puts HdfsThriftClient.client(@hdfs_ids.first.id).inspect
      #puts HdfsThriftClient.client
    end

    temp_files
  end

  def files
    #@file_name = params[:file]
    @file_names = params[:files].split(',') if params[:files] != 'none'

   render :template=>'hdfs/files.html.haml', :layout => false
  end

  def temp_files
    @files = {
      'root1' => {
        'file1' => {'element1' => {}},
        'file2' => {'element2' => {}, 'element3' => {}, 'element4' => {}},
        'file3' => {'element5' => {}, 'element6' => {}} },
      'root2' => {
        'file4' => {'element7' => {'element8' => {'element9' => {'element10' => {}}}}},
        'file5' => {'element11' => {}, 'element12' => {}, 'element13' => {}},
        'file6' => {'element14' => {}, 'element15' => {}}
        }
      }
  end

end