title: Rio.JS and AJAX pitfalls pitfalls
date: 10-03-2013
template: article.jade
author: gadr90

This saturday, I've been to the [Rio.JS][1] conference, a Rio de Janeiro-based Javascript developer event. I would like to congratulate the organizers for the effort, as I am sure that pulling such an event is no easy feat, and the formation of a local community is a noble intent. 

One of the presenters, [Hugo Roque][3] asked for feedback on his [lecture][2]. Here, I'll try and offer some opinions on his proposed solutions which I hope will be helpful.

<span class="more"></span>

Let's start at the beginning.  
       
### If you suspect your public knows the basics of your subject, be quick presenting it.

At a javascript developer conference, I feel there is no need to explain the uses or benefits of AJAX. This technology is sufficiently [old and commonplace][4] that the time would be better used with more advanced discussion.  

### Save a reference to your jqXHR object

One of the common pitfalls of asynchronous communication is the lack of user feedback, *e.g.*, no *loading* hint is shown after a user presses a button that needs communication and/or processing. To avoid making multiple requests as a result of the user clicking the button multiple times, the presenter recommends the following:

    $("a").one("click", function (event) { 
        $.get("http://site.com", function (html) {
            //do something
        });
        event.preventDefault();
    });

According to the jQuery documentation, with the `one` method,

    "the handler is unbound after its first invocation."
    
This isn't very useful if your button is ever going to be clicked again. A nicer way to achieve the same effect is by saving a reference to the [jqXHR][5] object which is returned by any ajax call, and reacting to it's existence:

    var myRequestToken = undefined;
    $('#my-button').click(function (e) {
        if (myRequestToken) {
            // There is a request going on - ignore this click.
            return false;
        }
        // Save a reference to the jqXHR. It is also a promise! (more on that soon)
        myRequestToken = $.get('/promises/are/awesome/');
        
        // After the request is done and returns the data successfuly, run this function.
        myRequestToken.done(function (data) { 
            // Do something
        });
        
        // The request is complete - either with success or failure. 
        // Anyway, clean the reference and enable a new click.        
        myRequestToken.always(function (data) {
            myRequestToken = undefined;
        });    
    });
    
In this fashion, we have enabled the button to be clicked again after any communication is done. 
This, however, doesn't solve the UX problem. Which leads us to...


### Be economic with your DOM manipulation

Adding and removing DOM is one of the most common use cases for Javascript, and is also one of the nastiest. Manipulating the DOM in a imperative fashion is a fast-track to pain. This is why the community is currently drowning on a multitude of [MVC frameworks][6], [templating engines][7] and whatnot.

One of the classic misuses of jQuery is adding an arbitrary `img` tag after an event:

    $("a").one("click", function (event) {
    	var img = $("<img src='images/loading.gif'>");
    	img.appendTo(document.body);
    	$.get("http://site.com", function () {
    		// faz alguma coisa
    		img.remove();
    	});
    });

This has the added disadvantage of starting to load the image only after the node is appended. That means a user on a slow connection will continue to receive no feedback on your ajax button, because the loading image will not appear until it itself is loaded. 

The solution can be, in fact, much simpler: 

    // CSS
    .hide { display: none; }
    .active { display: block; }
    
    // In the DOM
    <img src="images/loading.gif" id="my-button-spinner" class="hide"/>
    
    // Activate loading
    $('#my-button-spinner').addClass('active');
    
    // Hide loading
    $('#my-button-spinner').removeClass('active');

This is, of course, considering you are not using one of the template or MVC frameworks which will present their own solutions.
 

### Use Promises, not callbacks.

One of the "recent" advancements in the Javascript is the growing usage of the [Promises][8] pattern. There is a plethora of tutorials and implementations to be found by Googling, and I suggest you get up to speed if you haven't so far.

Promises can be found in lots of places - including jQuery. In fact, the `jqXHR` implements a Promise interface. This enables us to do some interesting things with it:

    var firstAsyncCall = $.get('/some/info/1');
    var secondAsyncCall = $.get('/some/info/2');
    // Only act when both calls are completed successfully!
    $.when(firstAsyncCall, secondAsyncCall).done(function(result1, result2){
        // Act on both results.
    });

This is but a simple example of what you can accomplish with promises. So, stop using `success` and `error` callbacks and get to know the `done`, `fail` and `always` family of methods in the jqXHR.


### Conclusion

Delivering a presentation is a hard task for most, and I thank Hugo for his effort. I hope he is not offended by this post and I'm looking forward for his next talk.


[1]: http://www.riojs.org/
[2]: http://www.slideshare.net/hugolnx/apresentacao-17070731
[3]: http://hugolnx.com/
[4]: http://en.wikipedia.org/wiki/Ajax_(programming)#History
[5]: http://api.jquery.com/jQuery.ajax/#jqXHR
[6]: http://addyosmani.github.com/todomvc/
[7]: http://garann.github.com/template-chooser/
[8]: http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/
