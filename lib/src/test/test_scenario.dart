
class TestScenario{
  
  final String _scenarioGroupId;
  final String _scenarioId;
  final TestScenarioStatus _status;

  TestScenario(String scenarioGroupId, String scenarioId, TestScenarioStatus status)
   : _scenarioGroupId = scenarioGroupId,
   _scenarioId = scenarioId,
   _status = status;
  
  TestScenario.from(Map<String,dynamic> json) : this(
    json['scenarioGroupId'],
    json['scenarioId'],
    json['status'] == null ? null : TestScenarioStatus.from(json['status'])
  );

  String get scenarioGroupId => _scenarioGroupId;
  String get scenarioId => _scenarioId;
  TestScenarioStatus get status => _status;
}


class TestScenarioStatus{
  final String _currentActionId;
  final Map<String,bool> _actionResultMap;
  final Map<String,bool> _actionEndMap;
  final TestScenarioState _state;
  final String _stateString;
  final DateTime _endTime;
  final Exception _exception;

  TestScenarioStatus(
    String currentActionId,
    Map<String,bool> actionResultMap,
    Map<String,bool> actionEndMap,
    TestScenarioState state,
    String stateString,
    DateTime endTime,
    Exception exception
  ) : _currentActionId = currentActionId,
   _actionResultMap = actionResultMap,
   _actionEndMap = actionEndMap,
   _state = state,
   _stateString = stateString,
   _endTime = endTime,
   _exception = exception;

  TestScenarioStatus.from(Map<String,dynamic> json)
  : this(
    json['currentActionId'],
    json['actionResultMap'] == null ? null : Map.from(json['actionResultMap']),
    json['actionEndMap'] == null ? null : Map.from(json['actionEndMap']),
    _toTestScenarioGroupState(json['state']?? 0),
    json['stateString'],
    json['endTime'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['endTime']['time']??0),
    json['throwable'] == null ? null : Exception(json['throwable']['message'])
  );

  String get currentActionId => _currentActionId;
  Map<String,bool> get actionResultMap => _actionResultMap;
  bool getActionResult(String actionId) => _actionResultMap == null ? null : _actionResultMap[actionId];
  Map<String,bool> get actionEndMap => _actionEndMap;
  bool isActionEnd(String actionId) => _actionEndMap == null ? null : _actionEndMap[actionId];
  TestScenarioState get state => _state;
  String get stateString => _stateString;
  DateTime get endTime => _endTime;
  Exception get exception => _exception;

  static TestScenarioState _toTestScenarioGroupState(int value){
    switch(value){
      case 1:
        return TestScenarioState.STARTED;
      case 2:
        return TestScenarioState.END;
      case 3:
        return TestScenarioState.CANCELED;
      case 4:
        return TestScenarioState.ERROR;
      case 0:
      default:
        return TestScenarioState.INITIAL;
    }
  }
}

enum TestScenarioState{
  INITIAL,
  STARTED,
  END,
  CANCELED,
  ERROR
}
