package robothaxe.utilities.statemachine;

import robothaxe.event.IEventDispatcher;

/**
* Class StateMachine represents finite-state machine with mapped states
* and transitions from FSMInjector class.
* State machine is updated through events because eventDispatcher instance is shared.
**/
class StateMachine {

    //---------------------------------------------------------------------
    //  Variables
    //---------------------------------------------------------------------

    /** @private Map of States objects by name. **/
    private var states:Dynamic;

    /** @private The initial state of the FSM. **/
    private var initial:State;

    /** @private The transition has been canceled. **/
    private var canceled:Bool;

    /** @private Current state in which is state machine. **/
    private var _currentState:State;

    //---------------------------------------------------------------------
    //  Constructor
    //---------------------------------------------------------------------

    /**
    * Create new instance of StateMachine.
    *
    * @param eventDispatcher An event dispatcher used to communicate with interested actors.
    * This is typically the Robothaxe framework event dispatcher.
    *
    */
    public function new(eventDispatcher:IEventDispatcher) {
        this.eventDispatcher = eventDispatcher;

        states = {};
    }

    /**
    * Register state machine with the facade.
    **/
    public function onRegister():Void
    {
        eventDispatcher.addEventListener( StateEvent.ACTION, handleStateAction );
        eventDispatcher.addEventListener( StateEvent.CANCEL, handleStateCancel );
        if ( initial != null ) transitionTo( initial, null );
    }

    //---------------------------------------------------------------------
    //  Handlers
    //---------------------------------------------------------------------

    /** @private Transition to new state if action is mapped in current state. **/
    private function handleStateAction(event:StateEvent):Void
    {
        var newStateTarget:String = _currentState.getTarget( event.action );

        if (newStateTarget == null) return;

        var newState:State = Reflect.field(states, newStateTarget);
        if( newState != null )
            transitionTo( newState, event.data );
    }

    /** @private Cancel transition. **/
    private function handleStateCancel(event:StateEvent):Void
    {
        canceled = true;
    }

    //---------------------------------------------------------------------
    //  State manipulation
    //---------------------------------------------------------------------

    /**
    * Registers the entry and exit commands for a given state.
    *
    * @param state The state to which to register the above commands.
    * @param initial Bool telling if this is the initial state of the system.
    */
    public function registerState( state:State, initial:Bool=false ):Void
    {
        if ( state == null || Reflect.field(states, state.name) != null ) return;
        Reflect.setField(states, state.name, state);
        if ( initial ) this.initial = state;
    }

    /**
    * Remove a state mapping.
    *
    * <p>Removes the entry and exit commands for a given state
    * as well as the state mapping itself.</p>
    *
    * @param stateName Name of the state to remove from state machine.
    */
    public function removeState( stateName:String ):Void
    {
        var state:State = cast(Reflect.field(states, stateName), State);
        if ( state == null ) return;
        Reflect.deleteField(states, stateName);
    }

    /**
    * Transitions to the given state from the current state.
    *
    * <p>Sends the <code>exiting</code> StateEvent for the current state
    * followed by the <code>entering</code> StateEvent for the new state.
    * Once finally transitioned to the new state, the <code>changed</code>
    * StateEvent for the new state is sent.</p>
    *
    * <p>
    * If a data parameter is provided, it is included as the body of all
    * three state-specific transition notes.</p>
    *
    * <p>Finally, when all the state-specific transition notes have been
    * sent, a <code>StateEvent.CHANGED</code> event is sent, with the
    * new <code>State</code> object as the <code>body</code> and the name of the
    * new state in the <code>type</code>.</p>
    *
    * @param nextState  The next State to transition to.
    * @param data       An optional object that was sent in the <code>StateEvent.ACTION</code> event.
    *
    * @private
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

    //---------------------------------------------------------------------
    //  Properties
    //---------------------------------------------------------------------

    /**
    * Current state name of state machine.
    **/
    public var currentStateName(get_currentStateName, null):String;

    /** @private **/
    private function get_currentStateName():String
    {
        return _currentState.name;
    }

    /**
    * An event dispatcher used to communicate with interested actors.
    * This is typically the Robothaxe framework event dispatcher.
    **/
    public var eventDispatcher:IEventDispatcher;


}
