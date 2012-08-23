class ZookeepersController < ApplicationController
  before_filter :set_zookeeper_with_preference, :only => :index
  before_filter :set_show_zookeeper, :only => :show
  before_filter :current_zookeeper, :only => :show


  QUERY = "
    select
      z.name,
      z.status,
      z.id,
      v.controller_version,
      c.controller_offline_node,
      c.controller_total,
      v.shard_version,
      s.shard_offline_node,
      s.shard_total,
      q.long_running_queries
    from
      zookeepers z,
      (select z1.id, count(distinct c1.blur_version) as controller_version, count(distinct s1.blur_version) as shard_version from zookeepers z1 left join controllers c1 on (z1.id = c1.zookeeper_id), zookeepers z2 left join clusters c2 on (z2.id = c2.zookeeper_id) left join shards s1 on (c2.id = s1.cluster_id) where z1.id = z2.id group by z1.id) v,
      (select z2.id, CAST(sum(if(c3.status = 0, 1, 0)) AS SIGNED) as controller_offline_node, count(c3.id) as controller_total from zookeepers z2 left join controllers c3 on (z2.id = c3.zookeeper_id) group by z2.id) c,
      (select z3.id, CAST(sum(if(s2.status = 0, 1, 0)) AS SIGNED) as shard_offline_node, count(s2.id) as shard_total from zookeepers z3 left join clusters c4 on (z3.id = c4.zookeeper_id) left join shards s2 on (c4.id = s2.cluster_id) group by z3.id) s,
      (select z4.id, CAST(sum(if(q1.state = 0 and q1.created_at < date_sub(utc_timestamp(), interval 1 minute), 1, 0)) AS SIGNED) as long_running_queries from zookeepers z4 left join clusters c5 on (z4.id = c5.zookeeper_id) left join blur_tables t1 on (c5.id = t1.cluster_id) left join blur_queries q1 on (t1.id = q1.blur_table_id) group by z4.id) q
    where
      z.id = v.id and
      z.id = c.id and
      z.id = s.id and
      z.id = q.id
    order by
      z.id
  "

  def index
    set_zookeeper Zookeeper.first.id if Zookeeper.count == 1
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @current_zookeeper, :methods => [:clusters, :controllers] }
    end
  end

  def dashboard
    zookeeper_results = []
    connection = ActiveRecord::Base.connection()
    connection.execute(QUERY).each(:as => :hash) { |row| zookeeper_results << row }
    render :json => zookeeper_results
  end

  def long_running_queries
    long_queries = Zookeeper.find(params[:id])
      .blur_queries.where('created_at < ? and state = ?', 1.minute.ago, 0)
      .collect{|query| query.summary(current_user)}
    render :json => long_queries
  end

  def shards
    shards = Zookeeper.find(params[:id]).clusters.find_by_id(params[:cluster_id]).shards
    render :json => shards, :except => :cluster_id
  end

  def destroy_shard
    shard = Zookeeper.find(params[:id]).shards.find_by_id(params[:shard_id])
    unless shard.nil?
      shard.destroy
      Audit.log_event(current_user, "Shard (#{shard.node_name}) was forgotten", "shard", "delete") if shard.destroyed?
    end
    render :json => shard
  end

  def destroy_cluster
    cluster = Zookeeper.find(params[:id]).clusters.find_by_id(params[:cluster_id])
    unless cluster.nil?
      cluster.destroy
      Audit.log_event(current_user, "Cluster (#{cluster.name}) was forgotten", "cluster", "delete") if cluster.destroyed?
    end
    render :json => cluster
  end

  def destroy_controller
    controller = Zookeeper.find(params[:id]).controllers.find_by_id(params[:controller_id])
    unless controller.nil?
      controller.destroy
      Audit.log_event(current_user, "Controller (#{controller.node_name}) was forgotten", "controller", "delete") if controller.destroyed?
    end
    render :json => controller
  end

  def destroy
    zookeeper = Zookeeper.find(params[:id])
    unless zookeeper.nil?
      zookeeper.destroy
      Audit.log_event(current_user, "Zookeeper (#{zookeeper.name}) was forgotten", "zookeeper", "delete") if zookeeper.destroyed?
    end
    render :json => zookeeper
  end
end
