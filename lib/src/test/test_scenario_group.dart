
class TestScenarioGroup{
  
  final String _scenarioGroupId;
  final TestScenarioGroupStatus _status;

  TestScenarioGroup(String scenarioGroupId, TestScenarioGroupStatus status)
   : _scenarioGroupId = scenarioGroupId,
   _status = status;
  
  TestScenarioGroup.from(Map<String,dynamic> json) : this(
    json['scenarioGroupId'],
    json['status'] == null ? null : TestScenarioGroupStatus.from(json['status'])
  );

  String get scenarioGroupId => _scenarioGroupId;
  TestScenarioGroupStatus get status => _status;
}


class TestScenarioGroupStatus{
  final String _currentActionId;
  final Map<String,bool> _actionResultMap;
  final Map<String,bool> _actionEndMap;
  final TestScenarioGroupState _state;
  final String _stateString;
  final DateTime _endTime;
  final Exception _exception;

  TestScenarioGroupStatus(
    String currentActionId,
    Map<String,bool> actionResultMap,
    Map<String,bool> actionEndMap,
    TestScenarioGroupState state,
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

  TestScenarioGroupStatus.from(Map<String,dynamic> json)
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
  TestScenarioGroupState get state => _state;
  String get stateString => _stateString;
  DateTime get endTime => _endTime;
  Exception get exception => _exception;

  static TestScenarioGroupState _toTestScenarioGroupState(int value){
    switch(value){
      case 1:
        return TestScenarioGroupState.STARTED;
      case 2:
        return TestScenarioGroupState.END;
      case 4:
        return TestScenarioGroupState.ERROR;
      case 0:
      default:
        return TestScenarioGroupState.INITIAL;
    }
  }
}

enum TestScenarioGroupState{
  INITIAL,
  STARTED,
  END,
  ERROR
}
