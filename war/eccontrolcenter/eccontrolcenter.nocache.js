function eccontrolcenter(){var O='bootstrap',P='begin',Q='gwt.codesvr.eccontrolcenter=',R='gwt.codesvr=',S='eccontrolcenter',T='startup',U='DUMMY',V=0,W=1,X='iframe',Y='javascript:""',Z='position:absolute; width:0; height:0; border:none; left: -1000px;',$=' top: -1000px;',_='CSS1Compat',ab='<!doctype html>',bb='',cb='<html><head><\/head><body><\/body><\/html>',db='undefined',eb='DOMContentLoaded',fb=50,gb='Chrome',hb='eval("',ib='");',jb='script',kb='javascript',lb='moduleStartup',mb='moduleRequested',nb='Failed to load ',ob='head',pb='meta',qb='name',rb='eccontrolcenter::',sb='::',tb='gwt:property',ub='content',vb='=',wb='gwt:onPropertyErrorFn',xb='Bad handler "',yb='" for "gwt:onPropertyErrorFn"',zb='gwt:onLoadErrorFn',Ab='" for "gwt:onLoadErrorFn"',Bb='#',Cb='?',Db='/',Eb='img',Fb='clear.cache.gif',Gb='baseUrl',Hb='eccontrolcenter.nocache.js',Ib='base',Jb='//',Kb='gxt.device',Lb='tablet',Mb='desktop',Nb=2,Ob='gxt.user.agent',Pb='edge/',Qb='edge',Rb='chrome',Sb='trident',Tb='msie',Ub=11,Vb='ie11',Wb=10,Xb='ie10',Yb=9,Zb='ie9',$b=8,_b='ie8',ac='safari',bc='version/3',cc='safari3',dc='version/4',ec='safari4',fc='safari5',gc='gecko',hc='rv:1.8',ic='gecko1_8',jc='gecko1_9',kc='adobeair',lc='air',mc=3,nc=4,oc=5,pc=6,qc=7,rc='user.agent',sc='webkit',tc='user.agent.os',uc='macintosh',vc='mac os x',wc='mac',xc='linux',yc='windows',zc='win32',Ac='unknown',Bc='selectingPermutation',Cc='eccontrolcenter.devmode.js',Dc="GWT module 'eccontrolcenter' may need to be (re)compiled",Ec=':',Fc='.cache.js',Gc='link',Hc='rel',Ic='stylesheet',Jc='href',Kc='loadExternalRefs',Lc='gwt/standard/standard.css',Mc='end',Nc='http:',Oc='file:',Pc='_gwt_dummy_',Qc='__gwtDevModeHook:eccontrolcenter',Rc='Ignoring non-whitelisted Dev Mode URL: ',Sc=':moduleBase';var o=window;var p=document;r(O,P);function q(){var a=o.location.search;return a.indexOf(Q)!=-1||a.indexOf(R)!=-1}
function r(a,b){if(o.__gwtStatsEvent){o.__gwtStatsEvent({moduleName:S,sessionId:o.__gwtStatsSessionId,subSystem:T,evtGroup:a,millis:(new Date).getTime(),type:b})}}
eccontrolcenter.__sendStats=r;eccontrolcenter.__moduleName=S;eccontrolcenter.__errFn=null;eccontrolcenter.__moduleBase=U;eccontrolcenter.__softPermutationId=V;eccontrolcenter.__computePropValue=null;eccontrolcenter.__getPropMap=null;eccontrolcenter.__installRunAsyncCode=function(){};eccontrolcenter.__gwtStartLoadingFragment=function(){return null};eccontrolcenter.__gwt_isKnownPropertyValue=function(){return false};eccontrolcenter.__gwt_getMetaProperty=function(){return null};var s=null;var t=o.__gwt_activeModules=o.__gwt_activeModules||{};t[S]={moduleName:S};eccontrolcenter.__moduleStartupDone=function(e){var f=t[S].bindings;t[S].bindings=function(){var a=f?f():{};var b=e[eccontrolcenter.__softPermutationId];for(var c=V;c<b.length;c++){var d=b[c];a[d[V]]=d[W]}return a}};var u;function v(){w();return u}
function w(){if(u){return}var a=p.createElement(X);a.src=Y;a.id=S;a.style.cssText=Z+$;a.tabIndex=-1;p.body.appendChild(a);u=a.contentDocument;if(!u){u=a.contentWindow.document}u.open();var b=document.compatMode==_?ab:bb;u.write(b+cb);u.close()}
function A(k){function l(a){function b(){if(typeof p.readyState==db){return typeof p.body!=db&&p.body!=null}return /loaded|complete/.test(p.readyState)}
var c=b();if(c){a();return}function d(){if(!c){c=true;a();if(p.removeEventListener){p.removeEventListener(eb,d,false)}if(e){clearInterval(e)}}}
if(p.addEventListener){p.addEventListener(eb,d,false)}var e=setInterval(function(){if(b()){d()}},fb)}
function m(c){function d(a,b){a.removeChild(b)}
var e=v();var f=e.body;var g;if(navigator.userAgent.indexOf(gb)>-1&&window.JSON){var h=e.createDocumentFragment();h.appendChild(e.createTextNode(hb));for(var i=V;i<c.length;i++){var j=window.JSON.stringify(c[i]);h.appendChild(e.createTextNode(j.substring(W,j.length-W)))}h.appendChild(e.createTextNode(ib));g=e.createElement(jb);g.language=kb;g.appendChild(h);f.appendChild(g);d(f,g)}else{for(var i=V;i<c.length;i++){g=e.createElement(jb);g.language=kb;g.text=c[i];f.appendChild(g);d(f,g)}}}
eccontrolcenter.onScriptDownloaded=function(a){l(function(){m(a)})};r(lb,mb);var n=p.createElement(jb);n.src=k;if(eccontrolcenter.__errFn){n.onerror=function(){eccontrolcenter.__errFn(S,new Error(nb+code))}}p.getElementsByTagName(ob)[V].appendChild(n)}
eccontrolcenter.__startLoadingFragment=function(a){return D(a)};eccontrolcenter.__installRunAsyncCode=function(a){var b=v();var c=b.body;var d=b.createElement(jb);d.language=kb;d.text=a;c.appendChild(d);c.removeChild(d)};function B(){var c={};var d;var e;var f=p.getElementsByTagName(pb);for(var g=V,h=f.length;g<h;++g){var i=f[g],j=i.getAttribute(qb),k;if(j){j=j.replace(rb,bb);if(j.indexOf(sb)>=V){continue}if(j==tb){k=i.getAttribute(ub);if(k){var l,m=k.indexOf(vb);if(m>=V){j=k.substring(V,m);l=k.substring(m+W)}else{j=k;l=bb}c[j]=l}}else if(j==wb){k=i.getAttribute(ub);if(k){try{d=eval(k)}catch(a){alert(xb+k+yb)}}}else if(j==zb){k=i.getAttribute(ub);if(k){try{e=eval(k)}catch(a){alert(xb+k+Ab)}}}}}__gwt_getMetaProperty=function(a){var b=c[a];return b==null?null:b};s=d;eccontrolcenter.__errFn=e}
function C(){function e(a){var b=a.lastIndexOf(Bb);if(b==-1){b=a.length}var c=a.indexOf(Cb);if(c==-1){c=a.length}var d=a.lastIndexOf(Db,Math.min(c,b));return d>=V?a.substring(V,d+W):bb}
function f(a){if(a.match(/^\w+:\/\//)){}else{var b=p.createElement(Eb);b.src=a+Fb;a=e(b.src)}return a}
function g(){var a=__gwt_getMetaProperty(Gb);if(a!=null){return a}return bb}
function h(){var a=p.getElementsByTagName(jb);for(var b=V;b<a.length;++b){if(a[b].src.indexOf(Hb)!=-1){return e(a[b].src)}}return bb}
function i(){var a=p.getElementsByTagName(Ib);if(a.length>V){return a[a.length-W].href}return bb}
function j(){var a=p.location;return a.href==a.protocol+Jb+a.host+a.pathname+a.search+a.hash}
var k=g();if(k==bb){k=h()}if(k==bb){k=i()}if(k==bb&&j()){k=e(p.location.href)}k=f(k);return k}
function D(a){if(a.match(/^\//)){return a}if(a.match(/^[a-zA-Z]+:\/\//)){return a}return eccontrolcenter.__moduleBase+a}
function F(){var f=[];var g=V;var h=[];var i=[];function j(a){var b=i[a](),c=h[a];if(b in c){return b}var d=[];for(var e in c){d[c[e]]=e}if(s){s(a,d,b)}throw null}
i[Kb]=function(){var a=navigator.userAgent;if(a.match(/Android/i)){return Lb}else if(a.match(/BlackBerry/i)){return Lb}else if(a.match(/iPhone|iPad|iPod/i)){return Lb}else if(a.match(/IEMobile/i)){return Lb}else if(a.match(/Tablet PC/i)){return Lb}return Mb};h[Kb]={desktop:V,phone:W,tablet:Nb};i[Ob]=function(){var a=navigator.userAgent.toLowerCase();if(a.indexOf(Pb)!=-1)return Qb;if(a.indexOf(Rb)!=-1)return Rb;if(a.indexOf(Sb)!=-1||a.indexOf(Tb)!=-1){if(p.documentMode>=Ub)return Vb;if(p.documentMode>=Wb)return Xb;if(p.documentMode>=Yb)return Zb;if(p.documentMode>=$b)return _b;return Xb}if(a.indexOf(ac)!=-1){if(a.indexOf(bc)!=-1)return cc;if(a.indexOf(dc)!=-1)return ec;return fc}if(a.indexOf(gc)!=-1){if(a.indexOf(hc)!=-1)return ic;return jc}if(a.indexOf(kc)!=-1)return lc;return null};h[Ob]={air:V,chrome:W,edge:Nb,gecko1_8:mc,gecko1_9:nc,ie10:oc,ie11:pc,ie8:qc,ie9:$b,safari3:Yb,safari4:Wb,safari5:Ub};i[rc]=function(){var a=navigator.userAgent.toLowerCase();var b=p.documentMode;if(function(){return a.indexOf(sc)!=-1}())return ac;if(function(){return a.indexOf(Tb)!=-1&&(b>=Wb&&b<Ub)}())return Xb;if(function(){return a.indexOf(Tb)!=-1&&(b>=Yb&&b<Ub)}())return Zb;if(function(){return a.indexOf(Tb)!=-1&&(b>=$b&&b<Ub)}())return _b;if(function(){return a.indexOf(gc)!=-1||b>=Ub}())return ic;return bb};h[rc]={gecko1_8:V,ie10:W,ie8:Nb,ie9:mc,safari:nc};i[tc]=function(){var a=o.navigator.userAgent.toLowerCase();if(a.indexOf(uc)!=-1||a.indexOf(vc)!=-1){return wc}if(a.indexOf(xc)!=-1){return xc}if(a.indexOf(yc)!=-1||a.indexOf(zc)!=-1){return yc}return Ac};h[tc]={linux:V,mac:W,unknown:Nb,windows:mc};__gwt_isKnownPropertyValue=function(a,b){return b in h[a]};eccontrolcenter.__getPropMap=function(){var a={};for(var b in h){if(h.hasOwnProperty(b)){a[b]=j(b)}}return a};eccontrolcenter.__computePropValue=j;o.__gwt_activeModules[S].bindings=eccontrolcenter.__getPropMap;r(O,Bc);if(q()){return D(Cc)}var k;try{alert(Dc);return;var l=k.indexOf(Ec);if(l!=-1){g=parseInt(k.substring(l+W),Wb);k=k.substring(V,l)}}catch(a){}eccontrolcenter.__softPermutationId=g;return D(k+Fc)}
function G(){if(!o.__gwt_stylesLoaded){o.__gwt_stylesLoaded={}}function c(a){if(!__gwt_stylesLoaded[a]){var b=p.createElement(Gc);b.setAttribute(Hc,Ic);b.setAttribute(Jc,D(a));p.getElementsByTagName(ob)[V].appendChild(b);__gwt_stylesLoaded[a]=true}}
r(Kc,P);c(Lc);r(Kc,Mc)}
B();eccontrolcenter.__moduleBase=C();t[S].moduleBase=eccontrolcenter.__moduleBase;var H=F();if(o){var I=!!(o.location.protocol==Nc||o.location.protocol==Oc);o.__gwt_activeModules[S].canRedirect=I;function J(){var b=Pc;try{o.sessionStorage.setItem(b,b);o.sessionStorage.removeItem(b);return true}catch(a){return false}}
if(I&&J()){var K=Qc;var L=o.sessionStorage[K];if(!/^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?\/.*$/.test(L)){if(L&&(window.console&&console.log)){console.log(Rc+L)}L=bb}if(L&&!o[K]){o[K]=true;o[K+Sc]=C();var M=p.createElement(jb);M.src=L;var N=p.getElementsByTagName(ob)[V];N.insertBefore(M,N.firstElementChild||N.children[V]);return false}}}G();r(O,Mc);A(H);return true}
eccontrolcenter.succeeded=eccontrolcenter();