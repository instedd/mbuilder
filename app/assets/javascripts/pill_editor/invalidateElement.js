var InvalidateElement = (function () {

    function invalidate() {
        this.resetInterval();
        var self = this;
        this.interval = setInterval(function() {self.validate();}, 40);
    }

    function validate() {
        this.resetInterval();
        this.render();
    }

    function render() {
        throw("Abstract Method Error");
    }

    function resetInterval() {
        if(this.interval != undefined) {
            clearInterval(this.interval);
        }
        this.interval = undefined;
    }

    return function() {
        this.invalidate = invalidate;
        this.validate = validate;
        this.render = render;
        this.resetInterval = resetInterval;
        return this;
    }
})();