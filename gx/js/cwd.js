function getkey(e)
{
  if (window.event)
    return window.event.keyCode;
  else if (e)
    return e.which;
  else
    return null;
}
x=-1;y=-1;d=false;

function curcell() {
  if (x<0) {return null;}
  return document.getElementById("cwd").rows[y].cells[x];
}

function highlight() {
  c=curcell();
  if (c) {
    c.className="highlight";
  }
}

function unhighlight() {
  c=curcell();
  if (c) {
    c.className="cell";
  }
}

function keypress(key) {
  cwd=document.getElementById("cwd");
  if (x<0) return true;
  if ( key==null || key==0 || key==9 || key==13 || key==27)
    return true;
  unhighlight();
  if (key == 8) {
    if (d) {y--} else {x--};
    if (y<0) {x=-1;};
    if (x<0) {y=-1;};
    if (x>=0) {
      curcell().childNodes[3].innerHTML="";
      highlight();
    }
    return false;
  }
  curcell().childNodes[3].innerHTML=String.fromCharCode(key);
  if (key == 32) {
    highlight();
    return false;
  }
  if (d) {
    y++;
    if (y>=cwd.rows.length) {
      x=-1; y=-1;
      return false;
    }
  } else {
    x++;
    if (x>=cwd.rows[y].cells.length) {
      x=-1; y=-1;
      return false;
    }
  }
  if (curcell().className != "cell") {
    x=-1;y=-1;
    return false;
  }
  highlight();
  return false;
}

function setxy(ax,ay) {
  unhighlight();
  x=ax;y=ay;
  highlight();
}

function unset() {
  unhighlight();
  x=-1;y=-1;
}

function setxyd(ax,ay,ad) {
  setxy(ax,ay);
  if (ad==0) {
    d=true;
  } else if (ad==1) {
    d=false;
  }
}

function chgdir() {
  d=!d;
}