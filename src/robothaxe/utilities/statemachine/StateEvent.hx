package robothaxe.utilities.statemachine;

import robothaxe.event.Event;

class StateEvent extends Event {

    public inline static var CHANGED:String = "changed";
    public inline static var ACTION:String = "action";
    public inline static var CANCEL:String = "cancel";

    public var action:String;
    public var data:Dynamic;

    public function new(type:String, action:String = null, data:Dynamic = null) {
        this.action = action;
        this.data = data;

        super(type, false, false);
    }

    override public function clone() : Event
    {
        return new StateEvent(type, action, data);
    }
}
