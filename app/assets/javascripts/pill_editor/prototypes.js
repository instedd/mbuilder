String.prototype.scan = function (regex) {
	if (!regex.global) throw "Scan Error";
	var self = this;
	var match, occurrences = [];
	while (match = regex.exec(self)) {
		match.shift();
		occurrences.push(match[0]);
	}
	return occurrences;
};

String.prototype.splice = function(index, remove, string) {
    return this.slice(0, index) + string + this.slice(index + Math.abs(remove));
};

Array.prototype.firstElement = function() {
    return this[0];
}

Array.prototype.lastElement = function() {
    return this[this.length - 1];
}

Array.prototype.lastIndex = function() {
    return this.length - 1;
}

Array.prototype.remove = function(element) {
	var index = this.indexOf(element);
	if(index != -1) {
		this.splice(index, 1);
	}
}