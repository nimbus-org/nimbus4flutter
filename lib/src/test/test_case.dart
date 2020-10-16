
class TestCase{
  
  final String _scenarioGroupId;
  final String _scenarioId;
  final String _testCaseId;
  final TestCaseStatus _status;

  TestCase(String scenarioGroupId, String scenarioId, String testCaseId, TestCaseStatus status)
   : _scenarioGroupId = scenarioGroupId,
   _scenarioId = scenarioId,
   _testCaseId = testCaseId,
   _status = status;
  
  TestCase.from(Map<String,dynamic> json) : this(
    json['scenarioGroupId'],
    json['scenarioId'],
    json['testCaseId'],
    json['status'] == null ? null : TestCaseStatus.from(json['status'])
  );

  String get scenarioGroupId => _scenarioGroupId;
  String get scenarioId => _scenarioId;
  String get testCaseId => _testCaseId;
  TestCaseStatus get status => _status;
}


class TestCaseStatus{
  final String _currentActionId;
  final Map<String,bool> _actionResultMap;
  final Map<String,bool> _actionEndMap;
  final TestCaseState _state;
  final String _stateString;
  final DateTime _endTime;
  final Exception _exception;

  TestCaseStatus(
    String currentActionId,
    Map<String,bool> actionResultMap,
    Map<String,bool> actionEndMap,
    TestCaseState state,
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

  TestCaseStatus.from(Map<String,dynamic> json)
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
  TestCaseState get state => _state;
  String get stateString => _stateString;
  DateTime get endTime => _endTime;
  Exception get exception => _exception;

  static TestCaseState _toTestScenarioGroupState(int value){
    switch(value){
      case 1:
        return TestCaseState.STARTED;
      case 2:
        return TestCaseState.END;
      case 3:
        return TestCaseState.CANCELED;
      case 4:
        return TestCaseState.ERROR;
      case 0:
      default:
        return TestCaseState.INITIAL;
    }
  }
}

enum TestCaseState{
  INITIAL,
  STARTED,
  END,
  CANCELED,
  ERROR
}
