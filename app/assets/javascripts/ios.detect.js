function isIphone5(){
    function iOSVersion(){
        var agent = window.navigator.userAgent,
            start = agent.indexOf( 'OS ' );
        if( (agent.indexOf( 'iPhone' ) > -1) && start > -1)
            return window.Number( agent.substr( start + 3, 3 ).replace( '_', '.' ) );
        else return 0;
    }
    return iOSVersion() >= 6 && window.devicePixelRatio >= 2 && screen.availHeight==548 ? true : false;
}

function detectIOSVersion() {
    var version = parseFloat(
        ('' + (/CPU.*OS ([0-9_]{1,5})|(CPU like).*AppleWebKit.*Mobile/i.exec(navigator.userAgent) || [0,''])[1])
            .replace('undefined', '3_2').replace('_', '.').replace('_', '')
    ) || false;
}

$(function(){
    //check if the device is an iPhone5
    CM.set('device.isPhone5', isIphone5());
    CM.set('device.iOS', detectIOSVersion());
    CM.set('device.devicePixelRatio', window.devicePixelRatio);
    CM.set('device.availHeight', screen.availHeight);
    CM.set('window.screen.height', window.screen.height);
});