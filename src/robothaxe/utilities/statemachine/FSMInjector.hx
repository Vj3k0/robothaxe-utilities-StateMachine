package robothaxe.utilities.statemachine;

import robothaxe.event.IEventDispatcher;

/**
* Class FSMInjector injects state machine with states and transitions which
* are provided as entry argument.
**/
class FSMInjector {

    //---------------------------------------------------------------------
    //  Variables
    //---------------------------------------------------------------------

    /** @private The XML FSM definition **/
    private var fsm:Xml;

    /** @private The List of State objects **/
    private var stateList:Array<State>;

    @inject("mvcsEventDispatcher")
    /**
    * An event dispatcher used to communicate with interested actors.
    * This is typically the Robothaxe framework event dispatcher.
    **/
    public var eventDispatcher:IEventDispatcher;

    //---------------------------------------------------------------------
    //  Constructor
    //---------------------------------------------------------------------

    /**
    * Create new instance of FSMInjector.
    *
    * @param fsm XML which holds mappings of state machine.
    **/
    public function new(fsm:String) {
        this.fsm = Xml.parse(fsm).firstElement();
    }

    //---------------------------------------------------------------------
    //  State manipulation
    //---------------------------------------------------------------------

    /**
    * Inject the <code>StateMachine</code> into the Robothaxe apparatus.
    * <p>Creates the <code>StateMachine</code> instance, registers all the states. </p>
    */
    public function inject(stateMachine:StateMachine):Void {

        // Register all the states with the StateMachine
        var state:State;
        for (state in states) {
            stateMachine.registerState( state, isInitial( state.name ) );
        }

        // Register the StateMachine with the facade
        stateMachine.onRegister();
    }

    /**
    * Creates a <code>State</code> instance from its XML definition.
    *
    * @private
    */
    private function createState( stateDef:Xml ):State
    {
        // Create State object
        var name:String = stateDef.get("name");
        var exiting:String = stateDef.get("exiting");
        var entering:String = stateDef.get("entering");
        var changed:String = stateDef.get("changed");
        var state:State = new State( name, entering, exiting, changed );

        //Loop variable
        var transDef:Xml;

        // Create transitions
        for (transDef in stateDef.elementsNamed("transition")) {
            state.defineTrans( transDef.get("action"), transDef.get("target") );
        }

        return state;
    }

    /**
    * Verify if given state is the initial state.
    * @private
    */
    private function isInitial( stateName:String ):Bool {
        var initial:String = fsm.get('initial');
        return (stateName == initial);
    }

    //---------------------------------------------------------------------
    //  Properties
    //---------------------------------------------------------------------

    /**
    * Get the state definitions.
    *
    * <p>Creates and returns the array of State objects
    * from the FSM on first call, subsequently returns
    * the existing array.</p>
    */
    public var states(get_states, null):Array<State>;

    /** @private **/
    private function get_states():Array<State>
    {
        if (stateList == null) {
            stateList = new Array<State>();

            //Loop variables
            var stateDef:Xml;
            var state:State;

            //Loop for each state node, create state and put it to stateList
            for (stateDef in fsm.elementsNamed("state")) {
                state = createState(stateDef);
                stateList.push(state);
            }
        }
        return stateList;
    }

}
