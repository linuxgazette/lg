// ------------------------------------------------------------
// Image description - image area annotation script
// Copyleft by M.Kanzaki, under GPL
// original: 2003-12-11
// revised : 2004-01-17, 2005-05-21
// -----------------------------------------------------------*/

if(navigator.userAgent.match(/Safari/)){
	document.write("<style type='text/css'>a.box img {display:none}</style>");
}

function showHide(btn){
	var d=document.getElementById("imgdesc");
	var bt = btn.firstChild.data;
	if(bt == "Show Annotation"){
		d.style.display = "block";
		btn.firstChild.data = "Hide Annotation";
	}else{
		d.style.display = "none";
		btn.firstChild.data = "Show Annotation";
	}
}

//to adjust Moz 1.2.1
function fixmoz(){
	var im,v,d,divs = document.getElementsByTagName("div");
	for(var i=0,n=divs.length; i < n; i++){
		d = divs.item(i);
		if(d.className == 'resregion'){
			im = d.getElementsByTagName("img").item(0);
			if(im.style.clip){
				return;
			}else{
				v = d.getElementsByTagName("var");
				im.style.position = "absolute";
				im.style.clip = v.item(0).firstChild.data;
				im.style.marginTop = v.item(1).firstChild.data;
				im.style.marginLeft = v.item(2).firstChild.data;
			}
		}
	}
}
