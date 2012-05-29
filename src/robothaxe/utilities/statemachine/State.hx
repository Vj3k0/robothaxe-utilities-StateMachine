package robothaxe.utilities.statemachine;

/**
* Class State represents one state in state machine and holds information
* about possible transitions to other states from current one.
**/
class State {

    //---------------------------------------------------------------------
    //  Variables
    //---------------------------------------------------------------------

    /** @private Transition map of actions to target states **/
    private var transitions:Dynamic;

    //---------------------------------------------------------------------
    //  Constructor
    //---------------------------------------------------------------------

    /**
    * Create new instance of State object.
    *
    * @param id         The id of the state.
    * @param entering   An optional event name to be sent when entering this state.
    * @param exiting    An optional event name to be sent when exiting this state.
    * @param changed    An optional event name to be sent when fully transitioned to this state.
    */
    public function new( name:String, ?entering:String=null, ?exiting:String=null, ?changed:String=null ) {
        this.name = name;
        if (entering != null) this.entering = entering;
        if (exiting != null) this.exiting = exiting;
        if (changed != null) this.changed = changed;

        transitions = {};
    }

    //---------------------------------------------------------------------
    //  Transition manipulation
    //---------------------------------------------------------------------

    /**
    * Define a transition.
    *
    * @param action The name of the StateMachine.ACTION event type.
    * @param target The name of the target state to transition to.
    */
    public function defineTrans( action:String, target:String ):Void
    {
        if ( getTarget( action ) != null ) return;
        //transitions[ action ] = target;
        Reflect.setField(transitions, action, target);
    }

    /**
    * Remove a previously defined transition.
    */
    public function removeTrans( action:String ):Void
    {
        //transitions[ action ] = null;
        Reflect.deleteField(transitions, action);
    }

    //---------------------------------------------------------------------
    //  State manipulation
    //---------------------------------------------------------------------

    /**
    * Get the target state name for a given action.
    */
    public function getTarget( action:String ):String
    {
        //return transitions[ action ];
        return Reflect.field(transitions, action);
    }

    //---------------------------------------------------------------------
    //  Properties
    //---------------------------------------------------------------------

    /**
    * The state name.
    **/
    public var name:String;

    /**
    * The notification to dispatch when entering the state.
    **/
    public var entering:String;

    /**
    * The notification to dispatch when exiting the state.
    **/
    public var exiting:String;

    /**
    * The notification to dispatch when the state has actually changed.
    **/
    public var changed:String;

}
