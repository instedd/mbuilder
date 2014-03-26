function Clipboard(input) {

	var self = this;
	var _input;
	var _active;
	var _clipboardContainer;
	var _clipboard;

	function init(input) {
		_input = input;
		_clipboardContainer = document.createElement("div");
		_clipboardContainer.setAttribute("style", "position:fixed;left:0px;top: 0px;width:0px;height:0px;z-index:100;display:none;opacity:0;");
		_clipboard = _clipboardContainer.appendChild(document.createElement("textarea"));
	}

	self.activate = function() {
		_active = true;
		document.addEventListener("keydown", keyDownHandler);
	}

	self.deactivate = function() {
		_active = false;
		document.removeEventListener("keydown", keyDownHandler);
	}

	function keyDownHandler(e) {
		var selection = (window.getSelection? window.getSelection().toString() : (document.selection? document.selection.createRange().text : "")).length > 0;
			console.log("down", window.getSelection())
		if(!selection && (e.ctrlKey || e.metaKey)) {
			document.body.appendChild(_clipboardContainer);
			_clipboardContainer.style.display = "block";
			switch(e.keyCode) {
				case 65://A
					_input.selection().set(0, Number.MAX_VALUE);
					e.preventDefault();
					break;
				case 67://C
					if(_input.selection().length()) {
						_clipboard.value = _input.get(_input.selection().start(), _input.selection().end());
						_clipboard.focus();
						_clipboard.select();
						setTimeout(function () {
							_clipboard.blur();
						}, 10);
					}
					break
				case 86://V
					_clipboardContainer.appendChild(_clipboard);
					_clipboard.focus();
					setTimeout(function () {
						var start = _input.selection().length()? _input.selection().start() : _input.caret();
						var remove = _input.selection().length();
						_input.append(start, remove, _clipboard.value);
						_input.caret(start + _clipboard.value.length);
						_input.selection().clear();
						_clipboard.value = "";
						_clipboard.blur();
						_clipboardContainer.style.display = "none";
						if(_clipboardContainer.parentNode) document.body.removeChild(_clipboardContainer);
					}, 10);
					break;
				case 88://X
					if(_input.selection().length()) {
						_clipboard.value = _input.get(_input.selection().start(), _input.selection().end());
						_clipboard.focus();
						_clipboard.select();
						_input.append(_input.selection().start(), _input.selection().length());
						_input.caret(_input.caret());
						setTimeout(function () {
							_clipboard.blur();
						}, 10);
					}
					break;
			}
		}
	}

	init(input);
}
		