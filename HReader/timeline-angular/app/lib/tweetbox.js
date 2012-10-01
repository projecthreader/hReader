
$.ajaxSetup({  
    dataType: "jsonp"  
});  
  
function getTweets() {  
    $.ajax("http://api.twitter.com/statuses/user_timeline/danwellman.json", {  
        success: function(data) {  
            var arr = [];  
                  
            for (var x = 0; x < 5; x++) {  
                var dataItem = {};  
                dataItem["tweetlink"] = data[x].id_str;  
                dataItem["timestamp"] = convertDate(data, x);  
                dataItem["text"] = breakTweet(data, x);  
                arr.push(dataItem);  
            }  
                  
            tweetData = arr;  
        }  
    });  
}  

      
//execute once all requests complete  
$.when(getTweets()).then(function(){  
          
    //apply templates     
});  