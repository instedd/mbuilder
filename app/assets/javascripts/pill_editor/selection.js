function Selection() {

	EventDispatcher.call(this);

	var self = this;
	var _limit = 0;
	var _length = 0;
	var _from, _to, _start, _end;

	self.set = function(from, to) {
		var empty = from == undefined || to == undefined;
		if(empty) {
			self.clear();
		} else {
			from = Math.max(0, Math.min(_limit, from));
			to = Math.max(0, Math.min(_limit, to));
			if(_from != from || _to != to) {
				_from = from;
				_to = to;
				_start = Math.min(_from, _to);
				_end = Math.max(_from, _to);
				_length = _end - _start || 0;
				self.dispatchEvent(new Event(Event.SELECT, {from:_from, to:_to, start:_start, end:_end, length:_length}));
			}
		}
	}

	self.clear = function() {
		if(_length) {
			_from = undefined;
			_to = undefined;
			_start = undefined;
			_end = undefined;
			_length = 0;
			self.dispatchEvent(new Event(Event.SELECT, {from:_from, to:_to, start:_start, end:_end, length:_length}));
		}
	}

	self.limit = function(value) {
		_limit = value;
		self.set(_from, _to);
	}

	self.from = function() {
		return _from;
	}

	self.to = function() {
		return _to;
	}

	self.start = function() {
		return _start;
	}

	self.end = function() {
		return _end;
	}

	self.length = function() {
		return _length;
	}
}