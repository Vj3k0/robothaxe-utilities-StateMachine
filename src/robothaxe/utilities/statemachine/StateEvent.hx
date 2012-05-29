package robothaxe.utilities.statemachine;

import robothaxe.event.Event;

/**
* Class StateEvent represents event object which is dispatched when
* state machine changed state or if it should be updated.
**/
class StateEvent extends Event {

    //---------------------------------------------------------------------
    //  Constants
    //---------------------------------------------------------------------

    /**
    * State has been changed.
    **/
    public inline static var CHANGED:String = "changed";

    /**
    * Action has been performed in current state.
    **/
    public inline static var ACTION:String = "action";

    /**
    * Cancel transition.
    **/
    public inline static var CANCEL:String = "cancel";

    //---------------------------------------------------------------------
    //  Constructor
    //---------------------------------------------------------------------

    /**
    * Create new instance of StateEvent which is dispatched whenever state is modified.
    *
    * @param type   The type of the event.
    * @param action Action to perform depending on type of event.
    * @param data   An optional object that was sent in event.
    **/
    public function new(type:String, action:String = null, data:Dynamic = null) {
        this.action = action;
        this.data = data;

        super(type, false, false);
    }

    //---------------------------------------------------------------------
    //  Override
    //---------------------------------------------------------------------

    /** @inheritDoc **/
    override public function clone() : Event
    {
        return new StateEvent(type, action, data);
    }

    //---------------------------------------------------------------------
    //  Properties
    //---------------------------------------------------------------------

    /**
    * Action to perform depending on type of the event.
    **/
    public var action:String;
    /**
    * An optional object that was sent in event.
    **/
    public var data:Dynamic;

}
