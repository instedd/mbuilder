function mousePosition(e) {
	var mouse = {};
	if (e.pageX || e.pageY) { 
	  mouse.x = e.pageX;
	  mouse.y = e.pageY;
	} else { 
	  mouse.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft; 
	  mouse.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop; 
	} 
	return mouse;
}