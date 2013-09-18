/*
 *	CM.JS v1.02
 *	cmjs.timseverien.nl
 */

(function(){window.CM={set:function(c,a,b,d,e){c=escape(c)+"=";var f=escape;a="object"!==typeof a||!JSON.stringify?a:JSON.stringify(a);a=c+f(a);b&&(b.constructor===Number?a+=";max-age="+b:b.constructor===String?a+=";expires="+b:b.constructor===Date&&(a+=";expires="+b.toUTCString()));a+=";path="+(d?d:"/");e&&(a+=";domain="+e);document.cookie=a},setObject:function(c,a,b,d){for(var e in c)CM.set(e,c[e],expires,b,d)},get:function(c){return CM.getObject()[c]},getObject:function(){var c=document.cookie.split(/;\s?/i),a={},b,d;for(d in c)if(b=c[d].split("="),!(1>=b.length)){var e=a,f=unescape(b[0]),g;a:{b=unescape(b[1]);try{g=JSON.parse(b);break a}catch(h){}g=b}e[f]=g}return a},unset:function(c){document.cookie=c+"=; expires="+(new Date(0)).toUTCString()},clear:function(){var c=CM.getObject(),a;for(a in c)CM.unset(a)}}})();