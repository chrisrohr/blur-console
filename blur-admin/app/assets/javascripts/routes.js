(function(){

  var defaults = {
    prefix: '',
    format: ''
  };
  
  var Utils = {

    serialize: function(obj){
      if (obj === null) {return '';}
      var s = [];
      for (prop in obj){
        if (obj[prop]) {
          if (obj[prop] instanceof Array) {
            for (var i=0; i < obj[prop].length; i++) {
              key = prop + encodeURIComponent("[]");
              s.push(key + "=" + encodeURIComponent(obj[prop][i].toString()));
            }
          } else {
            s.push(prop + "=" + encodeURIComponent(obj[prop].toString()));
          }
        }
      }
      if (s.length === 0) {
        return '';
      }
      return "?" + s.join('&');
    },

    clean_path: function(path) {
      return path.replace(/\/+/g, "/").replace(/[\)\(]/g, "").replace(/\.$/m, '').replace(/\/$/m, '');
    },

    extract: function(name, options) {
      var o = undefined;
      if (options.hasOwnProperty(name)) {
        o = options[name];
        delete options[name];
      } else if (defaults.hasOwnProperty(name)) {
        o = defaults[name];
      }
      return o;
    },

    extract_format: function(options) {
      var format = options.hasOwnProperty("format") ? options.format : defaults.format;
      delete options.format;
      return format ? "." + format : "";
    },

    extract_anchor: function(options) {
      var anchor = options.hasOwnProperty("anchor") ? options.anchor : null;
      delete options.anchor;
      return anchor ? "#" + anchor : "";
    },

    extract_options: function(number_of_params, args) {
      if (args.length > number_of_params) {
        return typeof(args[args.length-1]) == "object" ?  args.pop() : {};
      } else {
        return {};
      }
    },

    path_identifier: function(object) {
      if (!object) {
        return "";
      }
      if (typeof(object) == "object") {
        return ((typeof(object.to_param) == "function" && object.to_param()) || object.to_param || object.id || object).toString();
      } else {
        return object.toString();
      }
    },

    build_path: function(number_of_params, parts, optional_params, args) {
      args = Array.prototype.slice.call(args);
      var result = Utils.get_prefix();
      var opts = Utils.extract_options(number_of_params, args);
      if (args.length > number_of_params) {
        throw new Error("Too many parameters provided for path");
      }
      var params_count = 0, optional_params_count = 0;
      for (var i=0; i < parts.length; i++) {
        var part = parts[i];
        if (Utils.optional_part(part)) {
          var name = optional_params[optional_params_count];
          optional_params_count++;
          // try and find the option in opts
          var optional = Utils.extract(name, opts);
          if (Utils.specified(optional)) {
            result += part;
            result += Utils.path_identifier(optional);
          }
        } else {
          result += part;
          if (params_count < number_of_params) {
            params_count++;
            var value = args.shift();
            if (Utils.specified(value)) {
              result += Utils.path_identifier(value);
            } else {
              throw new Error("Insufficient parameters to build path");
            }
          }
        }
      }
      var format = Utils.extract_format(opts);
      var anchor = Utils.extract_anchor(opts);
      return Utils.clean_path(result + format + anchor) + Utils.serialize(opts);
    },

    specified: function(value) {
      return !(value === undefined || value === null);
    },

    optional_part: function(part) {
      return part.match(/\(/);
    },

    get_prefix: function(){
      var prefix = defaults.prefix;

      if( prefix !== "" ){
        prefix = prefix.match('\/$') ? prefix : ( prefix + '/');
      }
      
      return prefix;
    }

  };

  window.Routes = {
// hdfs_metrics => /hdfs_metrics(.:format)
  hdfs_metrics_path: function(options) {
  return Utils.build_path(0, ["/hdfs_metrics"], ["format"], arguments)
  },
// hdfs_stats => /hdfs_metrics/:id/stats(.:format)
  hdfs_stats_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs_metrics/", "/stats"], ["format"], arguments)
  },
// user_sessions => /user_sessions(.:format)
  user_sessions_path: function(options) {
  return Utils.build_path(0, ["/user_sessions"], ["format"], arguments)
  },
// login => /login(.:format)
  login_path: function(options) {
  return Utils.build_path(0, ["/login"], ["format"], arguments)
  },
// logout => /logout(.:format)
  logout_path: function(options) {
  return Utils.build_path(0, ["/logout"], ["format"], arguments)
  },
// user_preference => /users/:user_id/preferences/:pref_type(.:format)
  user_preference_path: function(_user_id, _pref_type, options) {
  return Utils.build_path(2, ["/users/", "/preferences/"], ["format"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(0, ["/users"], ["format"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(0, ["/users/new"], ["format"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/edit"], ["format"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/"], ["format"], arguments)
  },
// search => /search(.:format)
  search_path: function(options) {
  return Utils.build_path(0, ["/search"], ["format"], arguments)
  },
// new_search => /search/new(.:format)
  new_search_path: function(options) {
  return Utils.build_path(0, ["/search/new"], ["format"], arguments)
  },
// edit_search => /search/edit(.:format)
  edit_search_path: function(options) {
  return Utils.build_path(0, ["/search/edit"], ["format"], arguments)
  },
// search_load => /search/load/:search_id(.:format)
  search_load_path: function(_search_id, options) {
  return Utils.build_path(1, ["/search/load/"], ["format"], arguments)
  },
// delete_search => /search/delete/:search_id/:blur_table(.:format)
  delete_search_path: function(_search_id, _blur_table, options) {
  return Utils.build_path(2, ["/search/delete/", "/"], ["format"], arguments)
  },
// fetch_results => /search/:search_id/:blur_table(.:format)
  fetch_results_path: function(_search_id, _blur_table, options) {
  return Utils.build_path(2, ["/search/", "/"], ["format"], arguments)
  },
// search_save => /search/save(.:format)
  search_save_path: function(options) {
  return Utils.build_path(0, ["/search/save"], ["format"], arguments)
  },
// update_search => /search/:search_id(.:format)
  update_search_path: function(_search_id, options) {
  return Utils.build_path(1, ["/search/"], ["format"], arguments)
  },
// search_filters => /search/:blur_table_id/filters(.:format)
  search_filters_path: function(_blur_table_id, options) {
  return Utils.build_path(1, ["/search/", "/filters"], ["format"], arguments)
  },
// zookeepers => /zookeepers(.:format)
  zookeepers_path: function(options) {
  return Utils.build_path(0, ["/zookeepers"], ["format"], arguments)
  },
// zookeeper => /zookeeper(/:id)(.:format)
  zookeeper_path: function(options) {
  return Utils.build_path(0, ["/zookeeper(/", ")"], ["id", "format"], arguments)
  },
// dashboard => /zookeepers/dashboard(.:format)
  dashboard_path: function(options) {
  return Utils.build_path(0, ["/zookeepers/dashboard"], ["format"], arguments)
  },
// destroy_controller => /zookeepers/:id/controller/:controller_id(.:format)
  destroy_controller_path: function(_id, _controller_id, options) {
  return Utils.build_path(2, ["/zookeepers/", "/controller/"], ["format"], arguments)
  },
// destroy_shard => /zookeepers/:id/shard/:shard_id(.:format)
  destroy_shard_path: function(_id, _shard_id, options) {
  return Utils.build_path(2, ["/zookeepers/", "/shard/"], ["format"], arguments)
  },
// destroy_cluster => /zookeepers/:id/cluster/:cluster_id(.:format)
  destroy_cluster_path: function(_id, _cluster_id, options) {
  return Utils.build_path(2, ["/zookeepers/", "/cluster/"], ["format"], arguments)
  },
// destroy_zookeeper => /zookeepers/:id(.:format)
  destroy_zookeeper_path: function(_id, options) {
  return Utils.build_path(1, ["/zookeepers/"], ["format"], arguments)
  },
// blur_tables_index => /blur_tables(/:id)(.:format)
  blur_tables_index_path: function(options) {
  return Utils.build_path(0, ["/blur_tables(/", ")"], ["id", "format"], arguments)
  },
// blur_tables_enable_selected => /blur_tables/enable(.:format)
  blur_tables_enable_selected_path: function(options) {
  return Utils.build_path(0, ["/blur_tables/enable"], ["format"], arguments)
  },
// blur_tables_disable_selected => /blur_tables/disable(.:format)
  blur_tables_disable_selected_path: function(options) {
  return Utils.build_path(0, ["/blur_tables/disable"], ["format"], arguments)
  },
// blur_tables_forget_selected => /blur_tables/forget(.:format)
  blur_tables_forget_selected_path: function(options) {
  return Utils.build_path(0, ["/blur_tables/forget"], ["format"], arguments)
  },
// blur_tables_destroy_selected => /blur_tables(.:format)
  blur_tables_destroy_selected_path: function(options) {
  return Utils.build_path(0, ["/blur_tables"], ["format"], arguments)
  },
// blur_tables_hosts => /blur_tables/:id/hosts(.:format)
  blur_tables_hosts_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_tables/", "/hosts"], ["format"], arguments)
  },
// blur_tables_schema => /blur_tables/:id/schema(.:format)
  blur_tables_schema_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_tables/", "/schema"], ["format"], arguments)
  },
// blur_tables_reload => /blur_tables/reload(.:format)
  blur_tables_reload_path: function(options) {
  return Utils.build_path(0, ["/blur_tables/reload"], ["format"], arguments)
  },
// blur_tables_terms => /blur_tables/:id/terms(.:format)
  blur_tables_terms_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_tables/", "/terms"], ["format"], arguments)
  },
// refresh => /blur_queries/refresh/:time_length(.:format)
  refresh_path: function(_time_length, options) {
  return Utils.build_path(1, ["/blur_queries/refresh/"], ["format"], arguments)
  },
// more_info_blur_query => /blur_queries/:id/more_info(.:format)
  more_info_blur_query_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_queries/", "/more_info"], ["format"], arguments)
  },
// times_blur_query => /blur_queries/:id/times(.:format)
  times_blur_query_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_queries/", "/times"], ["format"], arguments)
  },
// blur_queries => /blur_queries(.:format)
  blur_queries_path: function(options) {
  return Utils.build_path(0, ["/blur_queries"], ["format"], arguments)
  },
// blur_query => /blur_queries/:id(.:format)
  blur_query_path: function(_id, options) {
  return Utils.build_path(1, ["/blur_queries/"], ["format"], arguments)
  },
// hdfs => /hdfs(/:id(/show(*fs_path)))(.:format)
  hdfs_path: function(options) {
  return Utils.build_path(0, ["/hdfs(/", "(/show(*fs_path)))"], ["fs_path", "id", "format"], arguments)
  },
// hdfs_info => /hdfs/:id/info(.:format)
  hdfs_info_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/info"], ["format"], arguments)
  },
// hdfs_folder_info => /hdfs/:id/folder_info(.:format)
  hdfs_folder_info_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/folder_info"], ["format"], arguments)
  },
// hdfs_slow_folder_info => /hdfs/:id/slow_folder_info(.:format)
  hdfs_slow_folder_info_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/slow_folder_info"], ["format"], arguments)
  },
// hdfs_expand => /hdfs/:id/expand(*fs_path)
  hdfs_expand_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/expand(*fs_path)"], ["fs_path"], arguments)
  },
// hdfs_file_info => /hdfs/:id/file_info(*fs_path)
  hdfs_file_info_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/file_info(*fs_path)"], ["fs_path"], arguments)
  },
// hdfs_move => /hdfs/:id/move(.:format)
  hdfs_move_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/move"], ["format"], arguments)
  },
// hdfs_mkdir => /hdfs/:id/mkdir(.:format)
  hdfs_mkdir_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/mkdir"], ["format"], arguments)
  },
// hdfs_delete => /hdfs/:id/delete_file(.:format)
  hdfs_delete_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/delete_file"], ["format"], arguments)
  },
// hdfs_upload_form => /hdfs/:id/upload_form(.:format)
  hdfs_upload_form_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/upload_form"], ["format"], arguments)
  },
// hdfs_upload => /hdfs/:id/upload(.:format)
  hdfs_upload_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/upload"], ["format"], arguments)
  },
// hdfs_structure => /hdfs/:id/structure(.:format)
  hdfs_structure_path: function(_id, options) {
  return Utils.build_path(1, ["/hdfs/", "/structure"], ["format"], arguments)
  },
// help => /help/:tab(.:format)
  help_path: function(_tab, options) {
  return Utils.build_path(1, ["/help/"], ["format"], arguments)
  },
// root => /
  root_path: function(options) {
  return Utils.build_path(0, ["/"], [], arguments)
  },
// rails_info_properties => /rails/info/properties(.:format)
  rails_info_properties_path: function(options) {
  return Utils.build_path(0, ["/rails/info/properties"], ["format"], arguments)
  }}
;
  window.Routes.options = defaults;
})();
