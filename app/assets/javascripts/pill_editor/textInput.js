function TextInput(container) {

	EventDispatcher.call(this);
	InvalidateElement.call(this);

	var self = this;
	var _container;
	var _wrapper;
	var _display;
	var _selection;
	var _keyTracker;
	var _clipboard;
	var _caret = 0;
	var _elements = [];
	var _focus;
	var _plumb;
	var _margin;
	var _autoExpand;
	var _minHeight;
	var _scrollHeight = 0;
	var _dragTarget;
	var _displayHiddenCharacters;
	var _debug;

	function init(container) {
		_selection = new Selection();
		_selection.addEventListener(Event.SELECT, selectHandler);
		_keyTracker = new KeyTracker(self, _selection);
		_clipboard = new Clipboard(self, _selection);
		_display = new TextDisplay();
		_container = container;
    _container.addEventListener("mousedown", mouseHandler);
    _container.addEventListener("dragover", mouseHandler);
    _container.addEventListener("drop", mouseHandler);
		_container.addEventListener("dblclick", doubleClickHandler);
		_container.addEventListener("contextmenu", contextMenuHandler);
    _container.addEventListener("mousemove", function(){
      if (self.isForeignObjectDragged()) {
        trackMousePositionForDrop();
      }
    });
		_wrapper = _container.appendChild(document.createElement("div"));
		_wrapper.style.cursor = "text";
		_wrapper.id = "wrapper";
		_wrapper.appendChild(_display.source());
		self.invalidate();
		self.margin(5);
		self.displayHiddenCharacters(false);
	}

  self.isForeignObjectDragged = function() {
    return false;
  }

	self.focus = function(value) {
		if(!arguments.length) {
			return _focus;
		} else {
			_focus = value;
			if(_focus) {
				document.addEventListener("mousedown", clickOutsideHandler);
				_container.className = "svgInput svgInput-focus";
				_display.focus(true);
				_keyTracker.activate();
				_clipboard.activate();
			} else {
				document.removeEventListener("mousedown", clickOutsideHandler);
				_container.className = "svgInput";
				_display.focus(false);
				_keyTracker.deactivate();
				_clipboard.deactivate();
			}
		}
	}

	self.margin = function(value) {
		if(!arguments.length) {
			return _margin;
		} else {
			_margin = value;
			self.invalidate();
		}
	}

	self.autoExpand = function(value) {
		if(!arguments.length) {
			return _autoExpand;
		} else {
			_autoExpand = value;
			self.invalidate();
		}
	}

	self.displayHiddenCharacters = function(value) {
		if(!arguments.length) {
			return _displayHiddenCharacters;
		} else {
			_displayHiddenCharacters = value;
			self.invalidate();
		}
	}

	self.width = function() {
		var style = window.getComputedStyle(_container);
		return Number(style.getPropertyValue("width").match(/\d+/));
	}

	self.height = function() {
		var style = window.getComputedStyle(_container);
		return Number(style.getPropertyValue("height").match(/\d+/));
	}

	self.data = function(value) {
		if(!arguments.length) {
			var data = [];
			_elements.forEach(function(element) {
				switch(element.type()) {
					case "character":
						if(typeof data.lastElement() != "string") {
							data.push("");
						}
						data[data.lastIndex()] = data.lastElement() + element.text();
						break;
					case "pill":
						data.push(element.toJson());
						break;
				}
			});
			return data;
		} else {
			_elements = [];
			var info = "";
			value.forEach(function(block) {
				switch(typeof block) {
					case "string":
						var text = sanitize(block).split("");
						text.forEach(function(entry) {
							_elements.push(new Character(entry));
						});
						info += block;
						break;
					case "object":
						_elements.push(new Pill(block.id, sanitize(block.label), sanitize(block.text), block.hasMenu, block.data));
						info += "(" + (block.text || block.label) + ")";
						break;
				}
			});
			self.caret(Number.MAX_VALUE, false);
			_selection.limit(_elements.length);
			self.invalidate();
			self.dispatchEvent(new Event(Event.CHANGE, info));
		}
	}

	self.append = function(start, remove, text) {
		_elements.splice(start, remove);
		if(text != undefined) {
			var insert = [];
			text = sanitize(text).split("");
			text.forEach(function(entry) {
				insert.push(new Character(entry));
			});
			_elements.splice.apply(_elements, [start, 0].concat(insert));
		}
		_selection.limit(_elements.length);
		self.render(start);
		self.dispatchEvent(new Event(Event.CHANGE, text));
	}

	self.get = function(from, to) {
		var string = "";
		for(var index = from; index < to && index < _elements.length; index++) {
			var element = _elements[index];
			string += element.text();
		}
		return string;
	}

	self.caret = function(value, insertBefore, persistPlumb) {
		if(!arguments.length) {
			return _caret;
		} else {
			_caret = Math.max(0, Math.min(_elements.length, value));
			_display.moveCaret(_caret, insertBefore);
			var position = _display.caretPosition();
			if(_container.scrollLeft > position.x) {
				_container.scrollLeft = position.x;
			} else if(_container.scrollLeft + _container.clientWidth - _margin * 2 < position.x) {
				_container.scrollLeft = position.x + _margin * 2 - _container.clientWidth;
			}
			if(_container.scrollTop > position.y - _display.fontSize()) {
				_container.scrollTop = position.y - _display.fontSize();
			} else if(_container.scrollTop + _container.clientHeight - _margin * 2 < position.y) {
				_container.scrollTop = position.y + _margin * 2 - _container.clientHeight;
			}
			if(!persistPlumb) {
				_plumb = undefined;
			}
			if(self.debug()) console.log(self.toString());
		}
	}

	self.selection = function() {
		return _selection;
	}

	self.jump = function(value) {
		var point = _display.caretPosition();
		_plumb = _plumb || point.x;
		point.x = _plumb;
		point.y += value * _display.lineHeight();
		var nearestPosition = _display.nearestPosition(point, false);
		self.caret(nearestPosition.index, nearestPosition.insertBefore, true);
	}

	self.prevBoundary = function(value) {
		value = Math.max(0, Math.min(_elements.length - 1, value));
		var boundary = value;
		if(_elements[value].text().match(/\s/)) {
			while (_elements[boundary].text().match(/\s/) && boundary > 0) {
				boundary--;
			}
		}
		while (boundary > 0 && _elements[boundary - 1].toString().match(/\S/)) {
			boundary--;
		}
		return boundary;
	}

	self.nextBoundary = function(value) {
		value = Math.max(0, Math.min(_elements.length - 1, value));
		var boundary = value;
		if(_elements[value].text().match(/\s/)) {
			while (boundary < _elements.length && _elements[boundary].text().match(/\s/)) {
				boundary++;
			}
		}
		while (boundary < _elements.length && _elements[boundary].text().match(/\S/)) {
			boundary++;
		}
		return boundary;
	}

	self.getPillById = function(id) {
		var pill;
		_elements.every(function(element) {
			if(element.type() == "pill" && element.id() == id) {
				pill = element;
			}
			return pill == undefined;
		});
		return pill;
	}

	self.breakPill = function(pill, replaceText) {
		replaceText = replaceText || pill.text();
		self.append(_elements.indexOf(pill), 1, replaceText);
	}

  self.selectionText = function(start, end) {
    var text = "";
    for (var index = start; index < end; index++) {
      var element = _elements[index];
      text += element.text();
    }
    return text;
  }

	self.createPill = function() {
		var text = self.selectionText(_selection.start(), _selection.end());
		if(self.GUIDgenerator != undefined) {
			var id = self.GUIDgenerator();
		}
		_elements.splice(_selection.start(), _selection.length(), new Pill(id, undefined, text));
		_selection.clear();
		self.invalidate();
	}

  self.insertPillAtCaret = function(id, label, text, hasMenu, data) {
    _elements.splice(_caret, 0, new Pill(id, sanitize(label), sanitize(text), hasMenu, data));
    self.invalidate();
    //BUG: caret is not leaft on drop position
    self.dispatchEvent(new Event(Event.CHANGE));
  }

	self.render = function(start) {
		var innerWidth = self.width() - _margin * 2;
		var innerHeight = self.height() - _margin * 2;
		_elements.forEach(function(element) {
			element.displayHiddenCharacters(self.displayHiddenCharacters());
		});
		_minHeight = _minHeight || self.height();
		_display.render(_elements, innerWidth, innerHeight, start);
		var overflowX = _elements.length && _display.width() > innerWidth;
		var overflowY = _elements.length && _display.height() > innerHeight && !_autoExpand;
		if(overflowX) {
			_scrollHeight = _scrollHeight || _minHeight - _container.clientHeight;
		}
		var width = overflowY? _container.clientWidth - _margin * 2 : innerWidth;
		var height = overflowX? _container.clientHeight - _margin * 2 : innerHeight;
		if(overflowX || overflowY) {
			_display.render(_elements, width, height, start);
		}
		if(_selection.length()) {
			_display.drawSelection(_selection.start(), _selection.end());
		} else {
			_display.clearSelection();
		}
		if(!overflowX) _container.scrollLeft = 0;
		if(!overflowY) _container.scrollTop = 0;
		_wrapper.style.padding = _margin + "px 0px 0px " + _margin + "px";
		_wrapper.style.width = (_display.width() + _margin) + "px";
		_wrapper.style.height = (_display.height() + _margin) + "px";
		_container.style.overflowX = overflowX? "scroll" : "hidden";
		_container.style.overflowY = overflowY && !_autoExpand? "scroll" : "hidden";
		if(_autoExpand) {
			var contentHeight = _display.computedHeight() + _margin * 2 + (overflowX? _scrollHeight : 0);
			_container.style.height = Math.max(_minHeight, contentHeight) + "px";
			_container.scrollTop = 0;
		}
	}

	self.toString = function() {
		var string = "";
		var caret = _caret;
		var start = _selection.start();
		var end = _selection.end();
		var index = 0;
		_elements.forEach(function(element) {
			switch(element.type()) {
				case "pill":
					string += element.toString();
					var offset = element.toString().length - 1;
					caret += caret > index? offset : 0;
					start += start > index? offset : 0;
					end += end > index? offset : 0;
					break;
				case "character":
					string += element.toString();
					break;
			}
			index++;
		});
		if(_selection.length()) {
			string = string.splice(end, 0, "]").splice(start, 0, "[");
		} else {
			string = string.splice(caret, 0, "|");
		}
		return string;
	}

	self.debug = function(value) {
		if (!arguments.length) {
			return _debug;
		} else {
			_debug = value;
			console.log(self.toString());
		}
	}

	function sanitize(text) {
		switch(typeof text) {
			case "string":
				text = text.replace(/\r\n|\r|\n/g, TextDisplay.RETURN).replace(/[^\S\r]/g, TextDisplay.NBSP);
				break;
			case "object":
				for (var node = text.firstChild; node != null; node = node.nextSibling) {
					node.textContent = sanitize(node.textContent);
				}
				break;
		}
		return text;
	}

  function trackMousePositionForDrop() {
    window.addEventListener("mousemove", mouseHandler);
    window.addEventListener("mouseup", mouseHandler);
    _selection.clear();
  }

	function mouseHandler(e) {
    e.preventDefault(); // avoid selection to start
		if(_container.contains(e.target)) {
			self.focus(true);
		} else {
      self.focus(false);
    }
		if(e.target == _container || e.button) return;
		var mouse = mousePosition(e);
		mouse.x -= _container.offsetLeft - _container.scrollLeft + _margin;
		mouse.y -= _container.offsetTop - _container.scrollTop + _margin;
		switch(e.type) {
			case "mousedown":
        $(document.activeElement).blur();
				if(e.target.textContent == TextDisplay.ARROW_DOWN) {
					e.stopImmediatePropagation();
					var info = {};
					info.pill = self.getPillById(e.target.parentNode.parentNode.getAttribute("data-id"));
					var boundingBox = info.pill.source().getBBox();
					info.mouseX =  _container.offsetLeft + boundingBox.x + boundingBox.width + self.margin();
					info.mouseY =  _container.offsetTop + boundingBox.y + boundingBox.height + self.margin();
					info.eventAt = "arrow";
          self.dispatchEvent(new Event(Event.CONTEXT_MENU, info));
					return;
				}
        trackMousePositionForDrop();
        _dragTarget = null;
				if(_container.contains(e.target) && e.target.parentNode.getAttribute("type") == "pill") {
					_dragTarget = e.target.parentNode;
          var pill = self.getPillById(_dragTarget.getAttribute("data-id"));
					var bounds = _dragTarget.getBBox();
					var phantom = document.createElement("div");
					var svg = phantom.appendChild(document.createElementNS("http://www.w3.org/2000/svg","svg"));
					svg.style.position = "absolute";
					svg.style.left = (bounds.x - mouse.x + _margin) + "px";
					svg.style.top = (bounds.y - mouse.y + _margin) + "px";
					var clone = svg.appendChild(_dragTarget.cloneNode(true));
					phantom.style.width = bounds.width + "px";
          phantom.style.height = bounds.height + "px";
          phantom.style.pointerEvents = "none"
					for (var index = clone.childElementCount - 1; index >= 0; index--) {
						var child = clone.childNodes[index];
						child.setAttribute("x", 0);
						child.setAttribute("y", _display.fontSize());
					}
					_wrapper.style.cursor = "move";
					self.dispatchEvent(new Event(Event.DRAG, {pill:pill.toJson(), phantom:phantom, mouseX:mouse.x + _container.offsetLeft - _container.scrollLeft, mouseY:mouse.y + _container.offsetTop - _container.scrollTop}));
				}
				break;
			case "mouseup":
      case "drop":
        _wrapper.style.cursor = "text";
				window.removeEventListener("mousemove", mouseHandler);
				window.removeEventListener("mouseup", mouseHandler);
				break;
		}
		var caret;
		var insertBefore = false;
		var index = e.target.getAttribute("data-index");
		if(_container.contains(e.target) && index) {
			var element = _elements[index];
			caret = Number(index) + (mouse.x > (element.x() + element.source().getBBox().width / 2)? 1 : 0);
			insertBefore = element.source().parentNode.nextSibling == undefined;
		} else {
			var contour = _dragTarget != null;
			var nearestPosition = _display.nearestPosition(mouse, contour);
			caret = nearestPosition.index;
			insertBefore = nearestPosition.insertBefore;
		}
		switch(e.type) {
			case "mousedown":
				if(e.shiftKey) {
					if(_selection.length()) {
						_selection.set(_selection.from(), caret);
					} else {
						_selection.set(_caret, caret);
					}
				} else {
					_selection.clear();
				}
				self.caret(caret, insertBefore);
				break;
      case "dragover":
        self.caret(caret, insertBefore);
        break;
      case "mousemove":
				if(_dragTarget == null && !self.isForeignObjectDragged()) {
					_selection.set(_caret, caret);
				} else {
					self.caret(caret, insertBefore);
				}
				break;
      case "mouseup":
			case "drop":
				self.caret(caret, insertBefore);
				if(_dragTarget != null) {
					var index = Number(_dragTarget.getAttribute("data-index"));
					if(0 <= mouse.x && mouse.x <= self.width() && 0 <= mouse.y && mouse.y <= self.height()) {
						var element = _elements[index];
						_elements.splice(index, 1);
						if(_caret > index) {
							self.caret(_caret - 1, insertBefore);
						}
						_elements.splice(_caret, 0, element);
						self.render();
						index = _caret;
					}
					_dragTarget = null;
					self.caret(index + 1, insertBefore);
					document.body.style.cursor = "auto";
					self.dispatchEvent(new Event(Event.DROP, {pill:element, dropZone:e.target}));
				} else {
          // outside drop. without a _dragTarget
          self.dispatchEvent(new Event(Event.DROP, {pill:null}));
        }
				break;
		}
	}

	function doubleClickHandler(e) {
		if(e.target.getAttribute("data-index")) {
			var firstNode = e.target.parentNode.firstChild;
			var lastNode = e.target.parentNode.lastChild;
			if(firstNode.textContent.match(TextDisplay.NBSP)) {
				if(firstNode.parentNode.previousSibling) {
					firstNode = firstNode.parentNode.previousSibling.firstChild;
				}
			} else {
				if(lastNode.parentNode.nextSibling) {
					lastNode = lastNode.parentNode.nextSibling.lastChild;
				}
			}
			_selection.set(Number(firstNode.getAttribute("data-index")), Number(lastNode.getAttribute("data-index")) + 1);
		}
	}

	function contextMenuHandler(e) {
		var isPill = false;
		var node = e.target;
		while(node.parentNode) {
			isPill = node.parentNode.getAttribute && node.parentNode.getAttribute("type") == "pill";
			if(isPill) {
				break;
			} else {
				node = node.parentNode;
			}
		}
		if(isPill) {
			var mouse = mousePosition(e);
			var info = {};
			info.pill = self.getPillById(e.target.parentNode.getAttribute("data-id"));
			info.mouseX = mouse.x;
			info.mouseY = mouse.y;
			info.eventAt = "pill";
			self.dispatchEvent(new Event(Event.CONTEXT_MENU, info));
		}
		e.preventDefault();
	}

	function clickOutsideHandler(e) {
		if(!_container.contains(e.target)) {
			self.focus(false);
		}
	}

	function selectHandler(e) {
		if(e.info.length) {
			_display.drawSelection(e.info.start, e.info.end);
		} else {
			_display.clearSelection();
		}
		self.dispatchEvent(e);
	}

	init(container);
}
