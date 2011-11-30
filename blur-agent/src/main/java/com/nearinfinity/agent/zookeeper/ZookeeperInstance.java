package com.nearinfinity.agent.zookeeper;

import java.io.IOException;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;
import org.springframework.jdbc.core.JdbcTemplate;

import com.nearinfinity.agent.zookeeper.collectors.ClusterCollector;
import com.nearinfinity.agent.zookeeper.collectors.ControllerCollector;

public class ZookeeperInstance implements InstanceManager, Runnable {
	private String name;
	private String url;
	private int instanceId;
	private JdbcTemplate jdbc;
	private ZooKeeper zk;
	private Watcher watcher;
	private Properties props;
	
	private static final Log log = LogFactory.getLog(ZookeeperInstance.class);
	
	public ZookeeperInstance(String name, String url, JdbcTemplate jdbc, Properties props) {
		this.name = name;
		this.url = url;
		this.jdbc = jdbc;
		this.props = props;
		
		initializeZkInstanceModel();
		resetConnection();
	}
	
	private void initializeZkInstanceModel() {
		String blurConnection = props.getProperty("blur." + name + ".url");
		
		int updatedCount = jdbc.update("update zookeepers set url=?, blur_urls=? where name=?", url, blurConnection, name);
		
		if (updatedCount == 0) {
			jdbc.update("insert into zookeepers (name, url, blur_urls) values (?, ?, ?)", name, url, blurConnection);
		}
		
		instanceId = jdbc.queryForInt("select id from zookeepers where name = ?", new Object[]{name});
	}

	@Override
	public void resetConnection() {
		updateZookeeperStatus(false);
		zk = null;
	}

	@Override
	public void run() {	
		while(true) {
			if (zk == null) {
				try {
					watcher = new ZookeeperWatcher(this);
					zk = new ZooKeeper(url, 3000, watcher);
				} catch (IOException e) {
					watcher = null;
					zk = null;
				}
			}
			
			if (zk == null) {
				log.info("Instance is not online.  Going to sleep for 30 seconds and try again.");
				updateZookeeperStatus(false);
				try {
					Thread.sleep(30000);
				} catch (InterruptedException e) {
					log.info("Exiting Zookeeper instance");
					return;
				}
			} else {
				updateZookeeperStatus(true);
				runInitialRegistration();
				try {
					synchronized(watcher) {
						watcher.wait();
					}
					log.info("Zookeeper Watcher was woken up, time to do work.");
				} catch (InterruptedException e) {
					log.info("Exiting Zookeeper instance");
					return;
				}
			}
		}
	}
	
	private void updateZookeeperStatus(boolean online) {
		jdbc.update("update zookeepers set status=? where id=?", (online ? 1 : 0), instanceId);
	}

	@Override
	public ZooKeeper getInstance() {
		return zk;
	}
	
	@Override
	public int getInstanceId() {
		return instanceId;
	}
	
	@Override
	public JdbcTemplate getJdbc() {
		return jdbc;
	}
	
	public String getName() {
		return name;
	}
	
	private void runInitialRegistration() {
		ControllerCollector.collect(this);
		ClusterCollector.collect(this);
	}

}
