
function TextDisplay() {

	EventDispatcher.call(this);

	var self = this;
	var _width;
	var _height;
	var _computedWidth;
	var _computedHeight;
	var _fontSize;
	var _lineHeight;
	var _svg;
	var _textFlow;
	var _selectionArea;
	var _IBeam;
	var _IBeamInterval;
	var _focus;
	var _elements = [];
	var _elementsWidth = [];

	function init() {
		_elementsWidth = []
		_fontSize = fontSize("char");
		_lineHeight = _fontSize * 1.2;
		_svg = document.createElementNS("http://www.w3.org/2000/svg","svg");
		_selectionArea = _svg.appendChild(document.createElementNS("http://www.w3.org/2000/svg","g"));
		_selectionArea.setAttribute("fill", "#0066ff");
		_textFlow = _svg.appendChild(document.createElementNS("http://www.w3.org/2000/svg","g"));
		_IBeam = document.createElementNS("http://www.w3.org/2000/svg","rect");
		_IBeam.setAttribute("width", "1");
		_IBeam.setAttribute("style", "fill:#000000;");
		_IBeam.setAttribute("pointer-events", "none");
		self.focus(false);
	}

	self.width = function() {
		return _width;
	}

	self.height = function() {
		return _height;
	}

	self.computedWidth = function() {
		return _computedWidth;
	}

	self.computedHeight = function() {
		return _computedHeight;
	}

	self.source = function() {
		return _svg;
	}

	self.drawSelection = function(start, end) {
		self.clearSelection();
		_IBeam.setAttribute("opacity", "0");
		var path = _selectionArea.appendChild(document.createElementNS("http://www.w3.org/2000/svg", "path"));
		path.setAttribute("d", selectionPath(start, end));
		for (var index = start; index < end && index < _elements.length; index++) {
			_elements[index].focus(true);
		}
	}

	self.clearSelection = function() {
		while(_selectionArea.firstChild) {
			_selectionArea.removeChild(_selectionArea.firstChild);
		}
		_elements.forEach(function(element) {
			element.focus(false);
		});
		_IBeam.setAttribute("opacity", "1");
	}

	self.moveCaret = function (value, insertBefore) {
		var x = 0;
		var y = 0;
		if(_elements.length) {
			var element = _elements[Math.max(0, Math.min(_elements.lastIndex(), value - (insertBefore? 1 : 0)))];
			x = element.x() + (value == _elements.length || insertBefore? _elementsWidth[element.toString()] : 0);
			y = element.y() - _fontSize;
		}
		_IBeam.setAttribute("x", x || 0);
		_IBeam.setAttribute("y", y || 0);
		_IBeam.setAttribute("height", _lineHeight);
		setIBeam(true);
	}

	self.nearestPosition = function(point, contour) {
		var nearestPosition = {index:0, insertBefore:false};
		if(!_elements.length) return nearestPosition;
		function elementByLine(line, x) {
			for (var blockIndex = line.childElementCount - 1; blockIndex >= 0; blockIndex--) {
				block = line.childNodes[blockIndex];
				for (var elementIndex = block.childElementCount - 1; elementIndex >= 0; elementIndex--) {
					var element = block.childNodes[elementIndex];
					var index = Number(element.getAttribute("data-index"));
					var left = _elements[index].x();
					var right = left + _elementsWidth[_elements[index].toString()];
					if(x > right || x > left || element == line.firstChild.firstChild) {
						return _elements[index];
					}
				}
			}
		}
		var before = point.y <= 0;
		var after = point.y > _elements.lastElement().y();
		if(before) {
			element = elementByLine(_textFlow.firstChild, point.x);
		} else if (after) {
			element = elementByLine(_textFlow.lastChild, point.x);
		} else {
			for (var index = _textFlow.childElementCount - 1; index >= 0; index--) {
				var line = _textFlow.childNodes[index];
				var top = index * _lineHeight;
				var bottom = top + _lineHeight;
				var match = point.y > top && point.y <= bottom;
				if (match) {
					if(contour) {
						element = _elements[(point.x <= line.offsetLeft? line.firstChild.firstChild : line.lastChild.lastChild).getAttribute("data-index")];
					} else {
						element = elementByLine(line, point.x);
					}
					nearestPosition.insertBefore = element.source() == line.lastChild.lastChild && line != _textFlow.lastChild;
					break;
				}
			}
		}
		nearestPosition.index = _elements.indexOf(element) + (point.x > (element.x() + _elementsWidth[element.toString()] / 2)? 1 : 0);
		return nearestPosition;
	}

	self.caretPosition = function() {
		return {x:Number(_IBeam.getAttribute("x")), y:Number(_IBeam.getAttribute("y")) + _fontSize};
	}

	self.focus = function(value) {
		_focus = value;
		setIBeam(_focus);
		if(_focus) {
			_svg.appendChild(_IBeam);
		} else {
			if(_IBeam.parentNode) {
				_svg.removeChild(_IBeam);
			}
		}
	}

	self.lineHeight = function() {
		return _lineHeight;
	}

	self.fontSize = function() {
		return _fontSize;
	}

	self.render = function(elements, width, height, start) {
		if(!arguments.length) {
			elements = _elements;
			width = _width;
			height = _height;
		}
		start = start || 0;
		_elements = elements.concat(new Character(TextDisplay.ZWSP));
		var line, block, blockElements, element, lastElement, index, length, breakable, x, y;
		clear(start);
		_computedWidth = 0;
		length = _textFlow.childElementCount;
		for (index = 0; index < length; index++) {
			line = _textFlow.childNodes[index];
			lastElement = _elements[Number(line.lastChild.lastChild.getAttribute("data-index"))];
			_computedWidth = Math.max(_computedWidth, lastElement.x() + _elementsWidth[lastElement.toString()]);
		}
		start = lastElement? lastElement.index() + 1 : 0;
		length = _elements.length;
		lastElement = undefined;
		line = undefined;
		for(index = start; index < length; index++) {
			element = _elements[index];
			var boundary = block == undefined || element.toString().match(/\s/) || lastElement.type() == "pill" || lastElement.text().match(/\s/);
			var overflow = x > width;
			var carriageReturn = lastElement != undefined? lastElement.text() == TextDisplay.RETURN : false;
			breakable = breakable || (lastElement != undefined? lastElement.type() != "pill" && lastElement.text().match(/\s/) != null : false);
			if(line == undefined || carriageReturn || (overflow && breakable)) {
				y = _fontSize + _lineHeight * _textFlow.childElementCount;
				breakable = false;
				line = _textFlow.appendChild(document.createElementNS("http://www.w3.org/2000/svg", "g"));
				line.setAttribute("data-index", _textFlow.childElementCount - 1);
				if(blockElements && !carriageReturn) {
					var offsetX = blockElements.firstElement().x();
					blockElements.forEach(function(blockElement) {
						blockElement.offset(-offsetX, _lineHeight);
					});
					line.appendChild(block);
					x -= offsetX;
				} else {
					x = 0;
				}
			}
			if(element.type() == "pill" || boundary) {
				blockElements = [];
				block = line.appendChild(document.createElementNS("http://www.w3.org/2000/svg", "g"));
			}
			blockElements.push(element);
			block.appendChild(element.source());
			var key = element.toString();
			if(_elementsWidth[key] == undefined) {
				var boundingBox = element.draw();
				_elementsWidth[key] = boundingBox.width - (bowser.firefox && _fontSize < 16? 3 : 0);
				_lineHeight = _lineHeight || boundingBox.height;
			} else {
				element.draw(_elementsWidth[key]);
			}
			element.move(x, y);
			element.index(index);
			x += _elementsWidth[key];
			if(lastElement != undefined && (lastElement.type() == "pill" || !lastElement.text().match(/\s/))) {
				_computedWidth = Math.max(_computedWidth, lastElement.x() + _elementsWidth[lastElement.toString()]);
			}
			lastElement = element;
		};
		_computedWidth = Math.max(x, _computedWidth);
		_width = Math.max(_computedWidth, width);
		_computedHeight = y;
		_height = Math.max(_computedHeight, height);
	}

	function clear(element) {
		element = Math.max(element - 1, 0);
		var start = 0;
		if(_elements[element].source().parentNode) {
			start = Number(_elements[element].source().parentNode.parentNode.getAttribute("data-index"));
		}
		for (index = _textFlow.childElementCount - 1; index >= start; index--) {
			var line = _textFlow.childNodes[index];
			_textFlow.removeChild(line);
		}
	}

	function selectionPath(start, end) {
		var from = _elements[start];
		var to = _elements[end - 1];
		var range = [Number(from.source().parentNode.parentNode.getAttribute("data-index")), Number(to.source().parentNode.parentNode.getAttribute("data-index"))];
		var path = ""; 
		for (var index = range[0]; index <= range[1]; index++) {
			var line = _textFlow.childNodes[index];
			var last = _elements[line.lastChild.lastChild.getAttribute("data-index")];
			var rect = {left:0, top:0 + index * _lineHeight, right:last.x() + _elementsWidth[last.toString()], bottom:(index + 1) * _lineHeight};
			if(index == range[0]) {
				rect.left = from.x();
			}
			if(index == range[1]) {
				rect.right = to.x() + _elementsWidth[to.toString()];
			}
			rect.left = Math.round(rect.left);
			rect.top = Math.round(rect.top);
			rect.right = Math.round(rect.right);
			rect.bottom = Math.round(rect.bottom);
			path += "M" + rect.left + " " + rect.top;
			path += "L" + rect.right + " " + rect.top;
			path += "L" + rect.right + " " + rect.bottom;
			path += "L" + rect.left + " " + rect.bottom + "Z";
		}
		return path;
	}

	function toogleIBeam() {
		if(_IBeam.parentNode) {
			_svg.removeChild(_IBeam);
		} else {
			_svg.appendChild(_IBeam);
		}
	}

	function setIBeam(value) {
		window.clearInterval(_IBeamInterval);
		if(value && _focus) {
			_IBeamInterval = window.setInterval(toogleIBeam, 500);
			_svg.appendChild(_IBeam);
		} else if(_IBeam.parentNode) {
			_svg.removeChild(_IBeam);
		}
	}

	function fontSize(TextClass) {
		var text = document.body.appendChild(document.createElement("div"));
		text.setAttribute("class", TextClass);
		text.textContent = "X";
		var fontSize = window.getComputedStyle(text).getPropertyValue("font-size");
		document.body.removeChild(text);
		return Number(fontSize.match(/\d+/));
	}

	init();
}
TextDisplay.RETURN = "\u000D";
TextDisplay.ZWSP = "\u200B";
TextDisplay.NBSP = "\u00A0";
TextDisplay.PILCROW = "\u00B6";
TextDisplay.BULLET = "\u2022";
TextDisplay.ARROW_DOWN = "\u25BC";