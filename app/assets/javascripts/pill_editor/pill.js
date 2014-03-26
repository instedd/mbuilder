function Pill(id, text, operator) {

	var self = this;
	var _type;
	var _x;
	var _y;
	var _id;
	var _label;
	var _text;
	var _textHolder;
	var _source;
	var _displayText;
	var _operator;
	var _background;
	var _index;
	var _focus;
	var _boundingBox;
	var _displayHiddenCharacters;

	function init(id, label, text, operator) {
		_type = "pill";
		_source = document.createElementNS("http://www.w3.org/2000/svg", "g");
		_source.setAttribute("type", _type);
		_source.setAttribute("z-index", "1");
		_background = _source.appendChild(document.createElementNS("http://www.w3.org/2000/svg", "rect"));
		_background.setAttribute("rx", 3);
		_background.setAttribute("ry", 3);
		_textHolder = _source.appendChild(document.createElementNS("http://www.w3.org/2000/svg", "text"));
		_textHolder.setAttribute("cursor", "move");
		self.focus(false);
		self.id(id);
		self.label(label);
		self.text(text);
		self.operator(operator);
		self.move(0, 0);
		self.index(0);
	}

	self.displayHiddenCharacters = function(value) {
		if(!arguments.length) {
			return _displayHiddenCharacters;
		} else {
			_displayHiddenCharacters = value;
		}
	}

	self.focus = function(value) {
		if(!arguments.length) {
			return _focus;
		} else {
			_focus = value;
			_textHolder.setAttribute("class", "char" + (_focus? " char-focus" : ""));
			_background.setAttribute("class", "pill" + (_focus? " pill-focus" : ""));
		}
	}

	self.index = function(value) {
		if(!arguments.length) {
			return _index;
		} else {
			_index = value;
			_source.setAttribute("data-index", _index);
		}
	}

	self.id = function(value) {
		if(!arguments.length) {
			return _id;
		} else {
			_id = value;
			_source.setAttribute("data-id", _id);
		}
	}

	self.label = function(value) {
		if(!arguments.length) {
			return _label;
		} else {
			_label = value;
			_boundingBox = undefined;
		}
	}

	self.text = function(value) {
		if(!arguments.length) {
			return _text;
		} else {
			_text = value;
			_boundingBox = undefined;
		}
	}

	self.operator = function(value) {
		if(!arguments.length) {
			return _operator;
		} else {
			_operator = value;
		}
	}

	self.x = function(value) {
		if(!arguments.length) {
			return _x;
		} else {
			_x = value;
			_textHolder.setAttribute("x", _x);
			_background.setAttribute("x", _x);
		}
	}

	self.y = function(value) {
		if(!arguments.length) {
			return _y;
		} else {
			_y = value;
			_textHolder.setAttribute("y", _y);
			_background.setAttribute("y", _y);
		}
	}

	self.draw = function() {
		if(_boundingBox == undefined) {
			var padding = 2;
			var text = self.label() || self.text();
			var node;
			switch(typeof text) {
				case "object":
					node = text.cloneNode(true);
					break;
				case "string":
					node = document.createElementNS("http://www.w3.org/2000/svg", "text");
					node.appendChild(document.createTextNode(text));
					break;
			}
			_textHolder.textContent = "";
			while (node.firstChild) {
				_textHolder.appendChild(parse(node.firstChild));
			}
			var arrow = document.createElementNS("http://www.w3.org/2000/svg", "tspan");
			arrow.textContent = TextDisplay.ARROW_DOWN;
			_textHolder.appendChild(arrow);
			var tempBoundingBox = _textHolder.getBBox();
			_boundingBox = {};
			for (var prop in tempBoundingBox) _boundingBox[prop] = tempBoundingBox[prop];
			_textHolder.setAttribute("transform", "translate(" + padding + ",0)");
			_textHolder.setAttribute("width", _boundingBox.width);
			_boundingBox.width = _boundingBox.width + padding * 2;
			_background.setAttribute("width", _boundingBox.width);
			_background.setAttribute("height", _boundingBox.height);
			_background.setAttribute("transform", "translate(0," + (_boundingBox.y - _y) + ")");
		}
		return _boundingBox;
	}

	self.move = function(x, y) {
		self.x(x);
		self.y(y);
	}

	self.offset = function(x, y) {
		self.move(_x + x, _y + y);
	}

	self.source = function() {
		return _source;
	}

	self.type = function() {
		return _type;
	}

	self.toString = function() {
		var text = "";
		var label = self.label();
		if(label) {
			switch(typeof label) {
				case "string":
					text = label;
					break;
				case "object":
					for (var node = label.firstChild; node != null; node = node.nextSibling) {
						text += parse(node.textContent);
					}
					break;
			}
		} else {
			text = self.text();
		}
		return "(" + text + ")";
	}

	function parse(text) {
		if(self.displayHiddenCharacters()) {
			switch(typeof text) {
				case "string":
					text = text.replace(/\r/g, TextDisplay.PILCROW + TextDisplay.RETURN).replace(/[^\S\r](?![^<>]*>)/g, TextDisplay.BULLET);
					break;
				case "object":
					for (var node = text.firstChild; node != null; node = node.nextSibling) {
						node.textContent = parse(node.textContent);
					}
					break;
			}
		}
		return text;
	}

	init(id, text, operator);
}