package robothaxe.utilities.statemachine.tests;

import robothaxe.utilities.statemachine.StateEvent;
import robothaxe.utilities.statemachine.StateMachine;
import robothaxe.event.EventDispatcher;
import robothaxe.utilities.statemachine.FSMInjector;
import robothaxe.event.IEventDispatcher;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


/**
* Auto generated MassiveUnit Test Class 
*/
class StateMachineTest 
{

    private var eventDispatcher:IEventDispatcher;
    private var fsmInjector:FSMInjector;

    ////////
    // State Machine Constants and Vars
    ///////
    private inline static var STARTING:String = "state/starting";
    private inline static var START:String = "event/start";
    private inline static var START_ENTERING:String = "action/start/entering";
    private inline static var STARTED:String = "action/completed/start";
    private inline static var START_FAILED:String = "action/start/failed";

    private inline static var CONSTRUCTING:String = "state/constructing";
    private inline static var CONSTRUCT:String = "event/construct";
    private inline static var CONSTRUCT_ENTERING:String = "action/construct/entering";
    private inline static var CONSTRUCTED:String = "action/completed/construction";
    private inline static var CONSTRUCTION_EXIT:String = "event/construction/exit";
    private inline static var CONSTRUCTION_FAILED:String = "action/contruction/failed";

    private inline static var NAVIGATING:String = "state/navigating";
    private inline static var NAVIGATE:String = "event/navigate";

    private inline static var FAILING:String = "state/failing";
    private inline static var FAIL:String = "event/fail";

    private var fsmOneState:String;
    private var fsm:String;

    public function new() { }

    @BeforeClass
    public function beforeClass():Void
    {
        fsmOneState =
            '<fsm initial="' + STARTING + '">' +
                '<!-- THE INITIAL STATE -->' +
                '<state name="' + STARTING + '" entering="' + START_ENTERING + '">' +
                '</state>' +
            '</fsm>';

        fsm =
            '<fsm initial="' + STARTING + '">' +

                '<!-- THE INITIAL STATE -->' +
                '<state name="' + STARTING + '">' +

                    '<transition action="' + STARTED + '" target="' + CONSTRUCTING + '"/>' +

                    '<transition action="' + START_FAILED + '" target="' + FAILING + '"/>' +
                '</state>' +

                '<!-- DOING SOME WORK -->' +
                '<state name="' + CONSTRUCTING + '" changed="' + CONSTRUCT + '" exiting="' + CONSTRUCTION_EXIT + '" entering="' + CONSTRUCT_ENTERING + '">' +

                    '<transition action="' + CONSTRUCTED + '" target="' + NAVIGATING + '"/>' +

                    '<transition action="' + CONSTRUCTION_FAILED + '"target="' + FAILING + '"/>' +

                '</state>' +

                '<!-- READY TO ACCEPT BROWSER OR USER NAVIGATION -->' +
                '<state name="' + NAVIGATING + '" changed="' + NAVIGATE + '"/>' +

                    '<!-- REPORT FAILURE FROM ANY STATE -->' +
                '<state name="' + FAILING + '" changed="' + FAIL + '"/>' +

                '</fsm>';
    }

    @Before
	public function setup():Void
	{
        eventDispatcher = new EventDispatcher();
        fsmInjector = new FSMInjector(this.fsm);
        fsmInjector.eventDispatcher = eventDispatcher;
	}
	
	@After
	public function tearDown():Void
	{
        eventDispatcher = null;
        fsmInjector.eventDispatcher = null;
        fsmInjector = null;
	}
	

    @Test
    public function fsmIsInitialized():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector.inject(stateMachine);
        Assert.isType(stateMachine, StateMachine);
        Assert.areEqual(STARTING, stateMachine.currentStateName);
    }

    @Test
    public function advanceToNextState():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector.inject(stateMachine);
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, STARTED ) );
        Assert.areEqual(CONSTRUCTING, stateMachine.currentStateName);
    }

    @Test
    public function constructionStateFailure():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector.inject(stateMachine);
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, STARTED ) );
        Assert.areEqual(CONSTRUCTING, stateMachine.currentStateName);
        eventDispatcher.dispatchEvent(new StateEvent( StateEvent.ACTION, CONSTRUCTION_FAILED ));
        Assert.areEqual(FAILING, stateMachine.currentStateName);
    }

    @Test
    public function stateMachineComplete():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector.inject(stateMachine);
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, STARTED ) );
        Assert.areEqual(CONSTRUCTING, stateMachine.currentStateName);
        eventDispatcher.dispatchEvent(new StateEvent( StateEvent.ACTION, CONSTRUCTED ));
        Assert.areEqual(NAVIGATING, stateMachine.currentStateName);
    }

    @Test
    public function cancelStateChange():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector.inject(stateMachine);
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, STARTED ) );
        Assert.areEqual(CONSTRUCTING, stateMachine.currentStateName);

        //listen for CONSTRUCTION_EXIT and block transition to next state
        eventDispatcher.addEventListener( CONSTRUCTION_EXIT, function (event:StateEvent):Void { eventDispatcher.dispatchEvent(new StateEvent( StateEvent.CANCEL)); } );

        //attempt to complete construction
        eventDispatcher.dispatchEvent(new StateEvent( StateEvent.ACTION, CONSTRUCTED ));
        Assert.areEqual(CONSTRUCTING, stateMachine.currentStateName);
    }

    @Test
    public function singleStateInConfigurationShouldBeAtThatStateInitially():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector = new FSMInjector(fsmOneState);
        fsmInjector.inject(stateMachine);
        Assert.areEqual(STARTING, stateMachine.currentStateName);
    }

    @Test
    public function singleStateInConfigurationShouldStayInStateOnCompletionEvent():Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        fsmInjector = new FSMInjector(fsmOneState);
        fsmInjector.inject(stateMachine);

        eventDispatcher.dispatchEvent(new StateEvent(StateEvent.ACTION, STARTED));
        Assert.areEqual(STARTING, stateMachine.currentStateName);
    }

    @AsyncTest
    public function stateTransitionPassesData(factory:AsyncFactory):Void
    {
        var stateMachine:StateMachine = new StateMachine(eventDispatcher);
        var data:Dynamic = {value:"someData"};
        Reflect.setField(data, "value", "someData");
        fsmInjector.inject(stateMachine);
        var handler:Dynamic = factory.createHandler(this, handleStateChange, 200);
        eventDispatcher.addEventListener(StateEvent.ACTION, handler);
        //Async.handleEvent(this, eventDispatcher, StateEvent.ACTION, handleStateChange );
        eventDispatcher.dispatchEvent( new StateEvent( StateEvent.ACTION, STARTED, data) );
    }

    private function handleStateChange(event:StateEvent):Void
    {
        Assert.isTrue( cast(Reflect.field(event.data, "value"), String) == "someData" );
    }

}