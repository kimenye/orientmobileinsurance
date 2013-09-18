function isIphone5(){
    function iOSVersion(){
        var agent = window.navigator.userAgent,
            start = agent.indexOf( 'OS ' );
        console.log("Agent : ", agent);
        if( (agent.indexOf( 'iPhone' ) > -1) && start > -1)
            return window.Number( agent.substr( start + 3, 3 ).replace( '_', '.' ) );
        else return 0;
    }
    return iOSVersion() >= 6 && window.devicePixelRatio >= 2 && screen.availHeight==548 ? true : false;
}

$(function(){
    //check if the device is an iPhone5
    CM.set('device.isPhone5', isIphone5());
});