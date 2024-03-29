(function( $ ){
  $.widget('ui.osxFinder',{
    options: {
        lockFirst : true,
        width : 250,
        baseUrl : '/'
      },
    _create: function() {
      var self = this,
        o = self.options,
        el = self.element;
      el.addClass('osxFinder');
      el.children('ul').each(function() {
        var divWrapper = self._createInnerWindow();
        $(this).wrap(divWrapper);
      });
      el.on('click', 'div.innerWindow > ul > li', function(e) {
        e.preventDefault();
        var evtEl = $(this);
        if(!evtEl.hasClass('osxSelected')) {
          // To eliminate bouncing we will save the next sibling
          // and then delete all other siblings to the right
          var nextSibling = evtEl.parents('div.innerWindow').next('.innerWindow');
          if (nextSibling.length > 0){
            nextSibling.nextAll('.innerWindow').remove();
            nextSibling.html('<div> Loading...</div>');
          } else {
            nextSibling = null;
          }
          evtEl.addClass('osxSelected').siblings().removeClass('osxSelected');
          var url = evtEl.children('a').attr('href');
          self._requestNextFinderWindow(url, true, nextSibling);
          self._trigger("navigated", null, {'url':url.replace(/expand|file_info/, 'show')});
        }
      });
      self._trigger("done");
    },
    _createInnerWindow: function() {
      var currentCount = this.element.children('div.innerWindow').size();
      var width = this.options.width;
      return $('<div/>').addClass('innerWindow').css({
        'width': width,
        'left': (currentCount * (width + 1)) + 2,
        'top' : 2
      });
    },
    _ensureLastWindowVisible: function() {
      var currentCount = this.element.children('div').size();
      var innerWidth = currentCount * (this.options.width + 2);
      var pluginWidth = this.element.innerWidth();
      if(innerWidth > pluginWidth) {
        this.element.animate({scrollLeft:innerWidth-pluginWidth}, 'slow');
      }
    },
    _requestNextFinderWindow: function(url, async, givenInnerWindow){
      var self = this;
      var innerWindow = givenInnerWindow || this._createInnerWindow();
      $.ajax(url, {
        async: async,
        success:function(data) {
          innerWindow.html(data);
          self.element.append(innerWindow);
          self._ensureLastWindowVisible();
          self._trigger("added", null,{"innerWindow":innerWindow,"url":url + "/"});
        },
        error: function(data) {
          innerWindow.html("error retrieving [" + url + "]");
          self.element.append(innerWindow);
        }
      });
      return innerWindow;
    },
    navigateToPath: function(path, id, silence) {
      // Take the path array and build the folder directory
      var buildFileTreeFromPath = function(pathPieces, currentPath){
        for( pieceIndex in pathPieces ){
          var piece = unescape(pathPieces[pieceIndex]);
          currentPath += '/' + piece;
          // Find the folder
          var selectedFolder = el.find('li[hdfs_path="' + currentPath + '"]');
          // Path does not exist
          if(!selectedFolder.length > 0){
            throw "Folder does not exist";
          }
          // If the folder is not already selected
          if(!selectedFolder.hasClass('osxSelected')){
            if (selectedFolder.siblings('.osxSelected').length > 0){
              selectedFolder.closest('.innerWindow').nextAll('.innerWindow').remove();
            }
            // Select the folder and build its children
            selectedFolder.addClass('osxSelected').siblings().removeClass('osxSelected');
            var url = selectedFolder.find('a').attr('href');
            self._requestNextFinderWindow(url, false);
          }
        }
        // Once we have setup the file, remove anything lower in the tree (for backs)
        newBranch = selectedFolder.closest('.innerWindow').next('.innerWindow');
        newBranch.find('.osxSelected').removeClass('osxSelected');
        newBranch.nextAll('.innerWindow').remove();
        return currentPath;
      }
      
      var el = this.element;
      var self = this;
      var hdfsId = id || el.find('#top_level > .osxSelected').attr('hdfs_id');
      var pathPieces = path.split('/').filter(function(member){return member !== '';});     
      var currentPath = '';
      
      if (id){
        // If id is defined we need to navigate to the specified hdfs
        var selectedHdfs = el.find('#top_level li[hdfs_id=' + id + ']');
        if(!selectedHdfs.hasClass('osxSelected')){
          el.find('.innerWindow:not(:first-child)').remove();
          selectedHdfs.addClass('osxSelected');
          self._requestNextFinderWindow('/hdfs/' + hdfsId + '/expand', false);
        } 
      } else {
        // This is for calls to /hdfs
        if(pathPieces.length <= 0){
          root = $('#top_level').closest('.innerWindow');
          root.nextAll('.innerWindow').remove();
          root.find('.osxSelected').removeClass('osxSelected');
        }
      }
      //If the path array has pieces, build and navigate to the path
      if(pathPieces.length > 0){
        currentPath = buildFileTreeFromPath(pathPieces, currentPath);
        // url to be placed in the nav bar
        var navBarUrl = '/hdfs/' + hdfsId + '/show' + currentPath;
        // Silence the navigated trigger to prevent duplicate history entries
        if(!silence){
          self._trigger("navigated", null, {'url':navBarUrl});
        }
      //Otherwise we are at /hdfs/#/show so set the ui to the selected hdfs
      } else {
        root = $('#top_level').closest('.innerWindow');
        lowestBranch = root.nextAll('.innerWindow').first();
        lowestBranch.find('.osxSelected').removeClass('osxSelected');
        root.nextAll('.innerWindow').remove();
        root.parent().append(lowestBranch);
      }
      // Always make sure they can see the last window
      self._ensureLastWindowVisible();
    }
  });

})( jQuery );