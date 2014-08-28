function KeyTracker(input) {

	var self = this;
	var _active = false;
	var _input;
	var _container;
	var _hiddenInput;
	var _deadKey;
	var _isMac;

	function init(input) {
		_input = input;
		_container = _input.container();
		_isMac = navigator.platform.match(/(Mac|iPhone|iPod|iPad)/i)? true : false;
		_hiddenInput = document.createElement("input")
		var hiddenInputContainer = _container.appendChild(document.createElement("div"));
		hiddenInputContainer.style.opacity = 0;
		hiddenInputContainer.style.width = 0;
		hiddenInputContainer.style.height = 0;
		hiddenInputContainer.style.overflows = "hidden";
		hiddenInputContainer.style.pointerEvents = "none";
		hiddenInputContainer.appendChild(_hiddenInput);
	}

	self.activate = function() {
		_active = true;
		_hiddenInput.focus();
		_hiddenInput.select();
		_hiddenInput.addEventListener("keypress", keyPressHandler);
		_hiddenInput.addEventListener("keydown", keyDownHandler);
		_hiddenInput.addEventListener("input", inputHandler);
	}

	self.deactivate = function() {
		_active = false;
		_hiddenInput.removeEventListener("keypress", keyPressHandler);
		_hiddenInput.removeEventListener("keydown", keyDownHandler);
		_hiddenInput.removeEventListener("input", inputHandler);
	}

	function select(shift, from, to) {
		if(shift) {
			if(_input.selection().length()) {
				_input.selection().set(_input.selection().from(), to);
			} else {
				_input.selection().set(from, to);
			}
		} else {
			_input.selection().clear();
		}
	}

	function insert(charCode) {
		var start = _input.selection().length()? _input.selection().start() : _input.caret();
		var remove = _input.selection().length();
		var char = String.fromCharCode(charCode);
		_input.selection().clear();
		_input.append(start, remove, char);
		_input.caret(start + 1, charCode != 13);
	}

	function getKeyCode(e) {
		return e.which? e.which : (e.keyCode? e.keyCode : (e.charCode? e.charCode : 0));
	}

	function keyPressHandler(e) {
		var keyCode = getKeyCode(e);
		switch(keyCode) {
			case 13://Enter
				break;
			default:
				insert(keyCode);
				break;
		}
		e.preventDefault();
	}

	function keyDownHandler(e) {
		var keyCode = getKeyCode(e);
		var start, remove;
		var caret = _input.caret();
		var preventDefault = true;
		switch(keyCode) {
			case 8://Backspace
				if(caret || _input.selection().length()) {
					start = _input.selection().length()? _input.selection().start() : caret - 1;
					remove = Math.max(1, _input.selection().length());
					caret = start;
					select(false);
					_input.append(start, remove);
					_input.caret(caret);
				}
				break;
			case 9://Tab
			case 27://Escape
				_input.focus(false);
				break;
			case 13://Enter
				insert(keyCode);
				break;
			case 35://End
				caret = Number.MAX_VALUE;
				select(e.shiftKey, _input.caret(), caret);
				_input.caret(caret);
				break;
			case 36://Home
				caret = 0;
				select(e.shiftKey, _input.caret(), caret);
				_input.caret(caret);
				break;
			case 37://Arrow left
				if((_isMac && e.altKey) || (!_isMac && e.ctrlKey)) {
					caret = _input.prevBoundary(caret - 1);
				} else {
					caret--;
				}
				select(e.shiftKey, _input.caret(), caret);
				_input.caret(caret);
				break;
			case 38://Arrow up
				_input.jump(-1);
				select(e.shiftKey, caret, _input.caret());
				break;
			case 39://Arrow right
				if((_isMac && e.altKey) || (!_isMac && e.ctrlKey)) {
					var nextBoundary = _input.nextBoundary(caret);
					if(nextBoundary != -1) {
						caret = nextBoundary + 1;
					} else {
						caret = Number.MAX_VALUE;
					}
				} else {
					caret++;
				}
				select(e.shiftKey, _input.caret(), caret);
				_input.caret(caret);
				break;
			case 40://Arrow down
				_input.jump(1);
				select(e.shiftKey, caret, _input.caret());
				break;
			case 46://Delete
				start = _input.selection().length()? _input.selection().start() : caret;
				remove = Math.max(1, _input.selection().length());
				caret = start;
				select(false);
				_input.append(start, remove);
				_input.caret(caret);
				break;
			default:
				preventDefault = false;
				break;
		}
		if(preventDefault) e.preventDefault();
	}

	function inputHandler(e) {
		if(_deadKey) {
			insert(_hiddenInput.value.charCodeAt(0));
			_hiddenInput.value = "";
		}
		_deadKey = _hiddenInput.value.length > 0;
	}

	init(input);
}