package robothaxe.utilities.statemachine;

import robothaxe.event.IEventDispatcher;

class StateMachine {

    /**
    * Map of States objects by name.
    */
    private var states:Dynamic;

    /**
    * The initial state of the FSM.
    */
    private var initial:State;

    /**
    * The transition has been canceled.
    */
    private var canceled:Bool;

    private var _currentState:State;

    public var eventDispatcher:IEventDispatcher;

    /**
    * StateMachine Constructor
    *
    * @param eventDispatcher an event dispatcher used to communicate with interested actors.
    * This is typically the Robothaxe framework event dispatcher.
    *
    */
    public function new(eventDispatcher:IEventDispatcher) {
        this.eventDispatcher = eventDispatcher;

        states = {};
    }

    public function onRegister():Void
    {
        eventDispatcher.addEventListener( StateEvent.ACTION, handleStateAction );
        eventDispatcher.addEventListener( StateEvent.CANCEL, handleStateCancel );
        if ( initial != null ) transitionTo( initial, null );
    }

    private function handleStateAction(event:StateEvent):Void
    {
        var newStateTarget:String = _currentState.getTarget( event.action );

        if (newStateTarget == null) return;

        var newState:State = Reflect.field(states, newStateTarget);
        if( newState != null )
            transitionTo( newState, event.data );
    }

    private function handleStateCancel(event:StateEvent):Void
    {
        canceled = true;
    }

    /**
    * Registers the entry and exit commands for a given state.
    *
    * @param state the state to which to register the above commands
    * @param initial boolean telling if this is the initial state of the system
    */
    public function registerState( state:State, initial:Bool=false ):Void
    {
        if ( state == null || Reflect.field(states, state.name) != null ) return;
        Reflect.setField(states, state.name, state);
        if ( initial ) this.initial = state;
    }

    /**
    * Remove a state mapping.
    * <P>
    * Removes the entry and exit commands for a given state
    * as well as the state mapping itself.</P>
    *
    * @param state
    */
    public function removeState( stateName:String ):Void
    {
        var state:State = cast(Reflect.field(states, stateName), State);
        if ( state == null ) return;
        Reflect.deleteField(states, stateName);
    }

    /**
    * Transitions to the given state from the current state.
    * <P>
    * Sends the <code>exiting</code> StateEvent for the current state
    * followed by the <code>entering</code> StateEvent for the new state.
    * Once finally transitioned to the new state, the <code>changed</code>
    * StateEvent for the new state is sent.</P>
    * <P>
    * If a data parameter is provided, it is included as the body of all
    * three state-specific transition notes.</P>
    * <P>
    * Finally, when all the state-specific transition notes have been
    * sent, a <code>StateEvent.CHANGED</code> event is sent, with the
    * new <code>State</code> object as the <code>body</code> and the name of the
    * new state in the <code>type</code>.
    *
    * @param nextState  The next State to transition to.
    * @param data       An optional object that was sent in the <code>StateEvent.ACTION</code> event
    */
    private function transitionTo( nextState:State, data:Dynamic=null ):Void
    {
        // Going nowhere?
        if ( nextState == null ) return;

        // Clear the cancel flag
        canceled = false;

        // Exit the current State
        if ( (_currentState != null) && (_currentState.exiting != null) ) eventDispatcher.dispatchEvent( new StateEvent( _currentState.exiting, null, data ));

        // Check to see whether the exiting guard has been canceled
        if ( canceled ) {
            canceled = false;
            return;
        }

        // Enter the next State
        if ( nextState.entering != null ) eventDispatcher.dispatchEvent( new StateEvent( nextState.entering, null, data ));


        // Check to see whether the entering guard has been canceled
        if ( canceled ) {
            canceled = false;
            return;
        }

        // change the current state only when both guards have been passed
        _currentState = nextState;

        // Send the notification configured to be sent when this specific state becomes current
        if ( nextState.changed != null ) eventDispatcher.dispatchEvent( new StateEvent( _currentState.changed, null, data ));

        // Notify the app generally that the state changed and what the new state is
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.CHANGED, _currentState.name));

    }


    public var currentStateName(get_currentStateName, null):String;

    public function get_currentStateName():String
    {
        return _currentState.name;
    }


}
