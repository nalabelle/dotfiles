~~~
//GmailApp max threads to search at once
var GMAILAPP_MAX_THREADS = 100;

function getTrashLabels() {
  var label_regex = /^AutoTrash\/(.*)$/;
  var days_regex = /^_Days=(\d+)$/;
  var labels = [];
  var days = 30;

  GmailApp.getUserLabels().forEach(function(label) {
    var label_name = label.getName();
    var matches = label_name.match(label_regex) || [null, null];
    var prune_label = matches[1];

    if(prune_label) {
      var days_match = prune_label.match(days_regex) || [null, null];
      if (days_match[1]) {
        days = days_match[1];
        Logger.log("Found days config: " + days + " days");
        return;
      }
      Logger.log("Found label for pruning: " + prune_label);
      labels.push(prune_label);
    }
  });

  return [days, labels.sort()];
}

function TrashScan() {
  var [trash_days, labels] = getTrashLabels();
  if (trash_days < 1) {
    throw "Err: No days";
  }
  var searches = [];
  labels.forEach(function(label) {
    searches.push('-is:starred older_than:'+trash_days+'d label:"'+label+'"');
  });
  searches.forEach(function(search) {
    Logger.log("Executing Search: " + search);
    var threads;
    while (threads = GmailApp.search(search, 0, GMAILAPP_MAX_THREADS)) {
      if(threads.length == 0) {
        break;
      }
      Logger.log("Deleting " + threads.length + " threads...");
      GmailApp.moveThreadsToTrash(threads);
    }
  });
}
~~~
