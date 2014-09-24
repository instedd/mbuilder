var EventDispatcher = (function () {

	function addEventListener (type, callback) {
		if(this.listeners[type] == undefined) {
			this.listeners[type] = [];
		}
		if(this.listeners[type].indexOf(callback) == -1) {
			this.listeners[type].push(callback);
		}
	}

	function removeEventListener(type, callback) {
		if(this.listeners[type] != undefined) {
			var index = this.listeners[type].indexOf(callback);
			if (index != -1) {
			    this.listeners[type].splice(index, 1);
			}
		}
	}

	function willTrigger(type, callback) {
		var willTrigger = false;
		if(this.listeners[type] != undefined) {
			willTrigger = this.listeners[type].indexOf(callback) != -1;
		}
		return willTrigger;
	}

	function hasEventListener(type) {
		var hasEventListener = false;
		if(this.listeners[type] != undefined) {
			hasEventListener = this.listeners[type].length > 0;
		}
		return hasEventListener;
	}

	function dispatchEvent(event) {
		event.target = this;
		if(this.listeners[event.type] != undefined) {
			this.listeners[event.type].forEach(function(entry) {
				entry(event);
			});
		}
	}

	return function() {
		this.listeners = [];
		this.addEventListener = addEventListener;
		this.removeEventListener = removeEventListener;
		this.willTrigger = willTrigger;
		this.hasEventListener = hasEventListener;
		this.dispatchEvent = dispatchEvent;
		return this;
	}
})();

function Event(type, info) {
	this.type = type;
	this.info = info;
};

Event.CHANGE = "change";
Event.SELECT = "select";
Event.DRAG = "drag";
Event.DROP = "drop";
Event.CONTEXT_MENU = "contextMenu";
Event.SELECTION_COMPLETE = "selectionComplete"
