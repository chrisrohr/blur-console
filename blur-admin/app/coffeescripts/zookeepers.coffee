$(document).ready ->
  # Updates all fields on the dashboard
  load_dashboard = () ->
    $.getJSON '/zookeepers/dashboard', (data) ->
      #console.log(data)

      # Displays a warning message if 1 or more queries have been running for over a minute
      long_queries = parseInt ( data.long_queries )
      if long_queries < 1
        query_message = '<div></div>'
      else if long_queries == 1
        query_message = '<div>1 query has been running for more than a minute</div>'
      else
        query_message = '<div>' + data.long_queries + ' queries have been running for more than a minute</div>'
      $('.warning').html(query_message)

      # Updates the fields for each zookeeper
      zookeepers = data.zookeepers
      $.each( zookeepers, ->
        zookeeper_table = $('#zookeepers').find("#" + this.id )

        # Updates the header showing the zookeeper status
        current_zookeeper = $('#' + zookeeper_table[0].id).find("th")
        if this.status == "1"
          current_zookeeper.removeClass('ui-state-error')
          current_zookeeper.addClass('ui-state-highlight')
          current_zookeeper.find('.zookeeper-status').html('<div> - Online</div>')
        else
          current_zookeeper.removeClass('ui-state-highlight')
          current_zookeeper.addClass('ui-state-error')
          current_zookeeper.find('.zookeeper-status').html('<div> - Offline</div>')

        # Updates the fields for the zookeeper's shards
        status_shards = $('#' + zookeeper_table[0].id).find(".stat-shard")
        bv_shards = $('#' + zookeeper_table[0].id).find(".bv-shard")

        if this.shard_total == "0"
          status_shards.find('.shards-online').removeClass('ui-state-highlight')
          status_shards.find('.shards-online').addClass('grey_div')
          status_shards.find('.shards-online > .number').html('<div>0</div>')
          status_shards.find('.shards-online > .word').html('<div>Shards Online</div>')
          bv_shards.find('.shards-bv').removeClass('ui-state-highlight, ui-state-error')
          bv_shards.find('.shards-bv').addClass('grey_div')
          bv_shards.find('.shards-bv').html('<div>No Shards Available</div>')

        else
          number_shards_online = parseInt(this.shard_total) - parseInt(this.shard_disabled_node) - parseInt(this.shard_offline_node)
          if number_shards_online > 0
            status_shards.find('.shards-online').removeClass('grey_div')
            status_shards.find('.shards-online').addClass('ui-state-highlight')
            status_shards.find('.shards-online > .number').html('<div>' + number_shards_online + '</div>')
          else
            status_shards.find('.shards-online').removeClass('ui-state-highlight')
            status_shards.find('.shards-online').addClass('grey_div')
            status_shards.find('.shards-online > .number').html('<div>0</div>')
          if number_shards_online == 1
            status_shards.find('.shards-online > .word').html('<div>Shard Online</div>')
          else
            status_shards.find('.shards-online > .word').html('<div>Shards Online</div>')

          if this.shard_disabled_node != "0"
            status_shards.find('.shards-disabled').removeClass('grey_div')
            status_shards.find('.shards-disabled').addClass('ui-state-yellow')
            status_shards.find('.shards-disabled > .number').html('<div>' + this.shard_disabled_node + '</div>')
          else
            status_shards.find('.shards-disabled').removeClass('ui-state-yellow')
            status_shards.find('.shards-disabled').addClass('grey_div')
            status_shards.find('.shards-disabled > .number').html('<div>0</div>')
          if this.shard_disabled_node == "1"
            status_shards.find('.shards-disabled > .word').html('<div>Shard Disabled</div>')
          else
            status_shards.find('.shards-disabled > .word').html('<div>Shards Disabled</div>')

          if this.shard_offline_node != "0"
            status_shards.find('.shards-offline').removeClass('grey_div')
            status_shards.find('.shards-offline').addClass('ui-state-error')
            status_shards.find('.shards-offline > .number').html('<div>' + this.shard_offline_node + '</div>')
          else
            status_shards.find('.shards-offline').removeClass('ui-state-error')
            status_shards.find('.shards-offline').addClass('grey_div')
            status_shards.find('.shards-offline > .number').html('<div>0</div>')
          if this.shard_offline_node == "1"
            status_shards.find('.shards-offline > .word').html('<div>Shard Offline</div>')
          else
            status_shards.find('.shards-offline > .word').html('<div>Shards Offline</div>')

          if parseInt(this.shard_version, 10) == 1
            bv_shards.find('.shards-bv').removeClass('grey_div, ui-state-error')
            bv_shards.find('.shards-bv').addClass('ui-state-highlight')
            bv_shards.find('.shards-bv').html('<div>Consistent Blur Versions</div>')
          else if parseInt(this.shard_version, 10) > 1
            bv_shards.find('.shards-bv').removeClass('grey_div, ui-state-highlight')
            bv_shards.find('.shards-bv').addClass('ui-state-error')
            bv_shards.find('.shards-bv').html('<div>Inconsistent Blur Versions</div>')

        # Updates the fields for the zookeeper's controllers
        status_controllers = $('#' + zookeeper_table[0].id).find(".stat-cont")
        bv_controllers = $('#' + zookeeper_table[0].id).find(".bv-cont")

        if this.controller_total == "0"
          status_controllers.find('.controllers-online').removeClass('ui-state-highlight')
          status_controllers.find('.controllers-online').addClass('grey_div')
          status_controllers.find('.controllers-online > .number').html('<div>0</div>')
          status_controllers.find('.controllers-online > .word').html('<div>Controllers Online</div>')
          bv_controllers.find('.controllers-bv').removeClass('ui-state-highlight, ui-state-error')
          bv_controllers.find('.controllers-bv').addClass('grey_div')
          bv_controllers.find('.controllers-bv').html('<div>No Controllers Available</div>')

        else
          number_controllers_online = parseInt(this.controller_total) - parseInt(this.controller_disabled_node) - parseInt(this.controller_offline_node)
          if number_controllers_online > 0
            status_controllers.find('.controllers-online').removeClass('grey_div')
            status_controllers.find('.controllers-online').addClass('ui-state-highlight')
            status_controllers.find('.controllers-online > .number').html('<div>' + number_controllers_online + '</div>')
          else
            status_controllers.find('.controllers-online').removeClass('ui-state-highlight')
            status_controllers.find('.controllers-online').addClass('grey_div')
            status_controllers.find('.controllers-online > .number').html('<div>0</div>')
          if number_controllers_online == 1
            status_controllers.find('.controllers-online > .word').html('<div>Controller Online</div>')
          else
            status_controllers.find('.controllers-online > .word').html('<div>Controllers Online</div>')

          if this.controller_disabled_node != "0"
            status_controllers.find('.controllers-disabled').removeClass('grey_div')
            status_controllers.find('.controllers-disabled').addClass('ui-state-yellow')
            status_controllers.find('.controllers-disabled > .number').html('<div>' + this.controller_disabled_node + '</div>')
          else
            status_controllers.find('.controllers-disabled').removeClass('ui-state-yellow')
            status_controllers.find('.controllers-disabled').addClass('grey_div')
            status_controllers.find('.controllers-disabled > .number').html('<div>0</div>')
          if this.controller_disabled_node == "1"
            status_controllers.find('.controllers-disabled > .word').html('<div>Controller Disabled</div>')
          else
            status_controllers.find('.controllers-disabled > .word').html('<div>Controllers Disabled</div>')

          if this.controller_offline_node != "0"
            status_controllers.find('.controllers-offline').removeClass('grey_div')
            status_controllers.find('.controllers-offline').addClass('ui-state-error')
            status_controllers.find('.controllers-offline > .number').html('<div>' + this.controller_offline_node + '</div>')
          else
            status_controllers.find('.controllers-offline').removeClass('ui-state-error')
            status_controllers.find('.controllers-offline').addClass('grey_div')
            status_controllers.find('.controllers-offline > .number').html('<div>0</div>')
          if this.controller_offline_node == "1"
            status_controllers.find('.controllers-offline > .word').html('<div>Controller Offline</div>')
          else
            status_controllers.find('.controllers-offline > .word').html('<div>Controllers Offline</div>')

          if parseInt(this.controller_version, 10) == 1
            bv_controllers.find('.controllers-bv').removeClass('grey_div, ui-state-error')
            bv_controllers.find('.controllers-bv').addClass('ui-state-highlight')
            bv_controllers.find('.controllers-bv').html('<div>Consistent Blur Versions</div>')
          else if parseInt(this.controller_version, 10) > 1
            bv_controllers.find('.controllers-bv').removeClass('grey_div, ui-state-highlight')
            bv_controllers.find('.controllers-bv').addClass('ui-state-error')
            bv_controllers.find('.controllers-bv').html('<div>Inconsistent Blur Versions</div>')

        $('#zookeepers_wrapper').show()
      )

    # Sets auto updates to run every minute
    setTimeout(load_dashboard, 5000)

  load_dashboard()
