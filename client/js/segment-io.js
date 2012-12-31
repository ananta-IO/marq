var analytics = analytics || [];

analytics.load = function(apiKey) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.async = true;
    script.src = ('https:' === document.location.protocol ? 'https://' : 'http://') +
                 'd2dq2ahtl5zl1z.cloudfront.net' + '/analytics.js/v1/' + apiKey + '/analytics.min.js';
    var first = document.getElementsByTagName('script')[0];
    first.parentNode.insertBefore(script, first);
    var factory = function (type) {
        return function () {
            analytics.push([type].concat(Array.prototype.slice.call(arguments, 0)));
        };
    };
    var methods = ['identify', 'track'];
    for(var i = 0; i < methods.length; i++) {
        analytics[methods[i]]=factory(methods[i]);
    }
};

analytics.load('8tbzfxw');