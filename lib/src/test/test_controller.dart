import '../../nimbus4flutter.dart';

abstract class TestController{

  final String _apiServerName;
  final String _host;
  final int _port;
  final String _scheme;
  final ApiServerUriBuilder? _uriBuilder;
  
  TestController(
    {
      String apiServerName = "TestController",
      String host = "localhost",
      int port = 8080,
      String scheme = "http",
      ApiServerUriBuilder? uriBuilder
    }
  ) : _apiServerName = apiServerName,
      _host = host,
      _port = port,
      _scheme = scheme,
      _uriBuilder = uriBuilder
  {
    ApiRegistory.registApiServer(buildApiServer());
    ApiRegistory.registApi(createApiOfGetCurrentScenarioGroup(_apiServerName, _enumToString(ApiName.getCurrentScenarioGroup)));
    ApiRegistory.registApi(createApiOfGetCurrentScenario(_apiServerName, _enumToString(ApiName.getCurrentScenario)));
    ApiRegistory.registApi(createApiOfGetCurrentTestCase(_apiServerName, _enumToString(ApiName.getCurrentTestCase)));
    ApiRegistory.registApi(createApiOfGetTestPhase(_apiServerName, _enumToString(ApiName.getTestPhase)));
    ApiRegistory.registApi(createApiOfStartScenarioGroup(_apiServerName, _enumToString(ApiName.startScenarioGroup)));
    ApiRegistory.registApi(createApiOfEndScenarioGroup(_apiServerName, _enumToString(ApiName.endScenarioGroup)));
    ApiRegistory.registApi(createApiOfStartScenario(_apiServerName, _enumToString(ApiName.startScenario)));
    ApiRegistory.registApi(createApiOfCancelScenario(_apiServerName, _enumToString(ApiName.cancelScenario)));
    ApiRegistory.registApi(createApiOfEndScenario(_apiServerName, _enumToString(ApiName.endScenario)));
    ApiRegistory.registApi(createApiOfStartTestCase(_apiServerName, _enumToString(ApiName.startTestCase)));
    ApiRegistory.registApi(createApiOfCancelTestCase(_apiServerName, _enumToString(ApiName.cancelTestCase)));
    ApiRegistory.registApi(createApiOfEndTestCase(_apiServerName, _enumToString(ApiName.endTestCase)));
    ApiRegistory.registApi(createApiOfGetTestScenarioGroupStatus(_apiServerName, _enumToString(ApiName.getTestScenarioGroupStatus)));
    ApiRegistory.registApi(createApiOfGetTestScenarioStatus(_apiServerName, _enumToString(ApiName.getTestScenarioStatus)));
    ApiRegistory.registApi(createApiOfGetTestCaseStatus(_apiServerName, _enumToString(ApiName.getTestCaseStatus)));
  }
  
  String get apiServerName => _apiServerName;
  String get host => _host;
  int get port => _port;
  String get scheme => _scheme;
  ApiServerUriBuilder? get uriBuilder => _uriBuilder;

  ApiServer buildApiServer();

  Api<I,O>? _getApi<I,O>(ApiName name){
    return ApiRegistory.getApi<I,O>(_enumToString(name));
  }

  String _enumToString(Object name){
    return name.toString().split('.').last;
  }

  Api<void,Map<String,dynamic>> createApiOfGetCurrentScenarioGroup(String serverName, String apiName);

  Api<void,Map<String,dynamic>> createApiOfGetCurrentScenario(String serverName, String apiName);

  Api<void,Map<String,dynamic>> createApiOfGetCurrentTestCase(String serverName, String apiName);
  
  Api<void,Map<String,dynamic>> createApiOfGetTestPhase(String serverName, String apiName);
  
  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfStartScenarioGroup(String serverName, String apiName);
  
  Api<void,Map<String,dynamic>> createApiOfEndScenarioGroup(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfStartScenario(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfCancelScenario(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfEndScenario(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfStartTestCase(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfCancelTestCase(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfEndTestCase(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfGetTestScenarioGroupStatus(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfGetTestScenarioStatus(String serverName, String apiName);

  Api<Map<String,dynamic>,Map<String,dynamic>> createApiOfGetTestCaseStatus(String serverName, String apiName);

  Future<TestScenarioGroup?> getCurrentScenarioGroup() async{
    Api<void,Map<String,dynamic>>? api = _getApi(ApiName.getCurrentScenarioGroup);
    RequestContext context = RequestContext();
    Map<String,dynamic>? json = await api?.request(null, context);
    return json?['CurrentScenarioGroup'] == null ? null : TestScenarioGroup.from(json!['CurrentScenarioGroup']);
  }

  Future<TestScenario?> getCurrentScenario() async{
    Api<void,Map<String,dynamic>>? api = _getApi(ApiName.getCurrentScenario);
    RequestContext context = RequestContext();
    Map<String,dynamic>? json = await api?.request(null, context);
    return json?['CurrentScenario'] == null ? null : TestScenario.from(json!['CurrentScenario']);
  }

  Future<TestCase?> getCurrentTestCase() async{
    Api<void,Map<String,dynamic>>? api = _getApi(ApiName.getCurrentTestCase);
    RequestContext context = RequestContext();
    Map<String,dynamic>? json = await api?.request(null, context);
    return json?['CurrentTestCase'] == null ? null : TestCase.from(json!['CurrentTestCase']);
  }

  Future<String?> getTestPhase() async{
    Api<void,Map<String,dynamic>>? api = _getApi(ApiName.getTestPhase);
    RequestContext context = RequestContext();
    Map<String,dynamic>? json = await api?.request(null, context);
    return json?['phase'];
  }

  Future<void> startScenarioGroup(String userId, String scenarioGroupId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.startScenarioGroup);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['userId'] = userId;
    input?['scenarioGroupId'] = scenarioGroupId;
    await api?.request(input, context);
  }

  Future<void> endScenarioGroup() async{
    Api<void,Map<String,dynamic>>? api = _getApi(ApiName.endScenarioGroup);
    RequestContext context = RequestContext();
    await api?.request(null, context);
  }

  Future<void> startScenario(String userId, String scenarioId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.startScenario);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['userId'] = userId;
    input?['scenarioId'] = scenarioId;
    await api?.request(input, context);
  }

  Future<void> cancelScenario(String scenarioId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.cancelScenario);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioId'] = scenarioId;
    await api?.request(input, context);
  }

  Future<void> endScenario(String scenarioId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.endScenario);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioId'] = scenarioId;
    await api?.request(input, context);
  }

  Future<void> startTestCase(String userId, String scenarioId, String testcaseId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.startTestCase);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['userId'] = userId;
    input?['scenarioId'] = scenarioId;
    input?['testcaseId'] = testcaseId;
    await api?.request(input, context);
  }

  Future<void> cancelTestCase(String scenarioId, String testcaseId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.cancelTestCase);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioId'] = scenarioId;
    input?['testcaseId'] = testcaseId;
    await api?.request(input, context);
  }

  Future<void> endTestCase(String scenarioId, String testcaseId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.endTestCase);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioId'] = scenarioId;
    input?['testcaseId'] = testcaseId;
    await api?.request(input, context);
  }

  Future<TestScenarioGroupStatus?> getTestScenarioGroupStatus(String scenarioGroupId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.getTestScenarioGroupStatus);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioGroupId'] = scenarioGroupId;
    Map<String,dynamic>? json = await api?.request(input, context);
    return json?['TestScenarioGroupStatus'] == null ? null : TestScenarioGroupStatus.from(json!['TestScenarioGroupStatus']);
  }

  Future<TestScenarioStatus?> getTestScenarioStatus(String scenarioGroupId, String scenarioId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.getTestScenarioStatus);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioGroupId'] = scenarioGroupId;
    input?['scenarioId'] = scenarioId;
    Map<String,dynamic>? json = await api?.request(input, context);
    return json?['TestScenarioStatus'] == null ? null : TestScenarioStatus.from(json!['TestScenarioStatus']);
  }

  Future<TestCaseStatus?> getTestCaseStatus(String scenarioGroupId, String scenarioId, String testcaseId) async{
    Api<Map<String,dynamic>,Map<String,dynamic>>? api = _getApi(ApiName.getTestCaseStatus);
    RequestContext context = RequestContext();
    Map<String,dynamic>? input = api?.getInput(context);
    input?['scenarioGroupId'] = scenarioGroupId;
    input?['scenarioId'] = scenarioId;
    input?['testcaseId'] = testcaseId;
    Map<String,dynamic>? json = await api?.request(input, context);
    return json?['TestCaseStatus'] == null ? null : TestCaseStatus.from(json!['TestCaseStatus']);
  }
}

enum ApiName{
  getCurrentScenarioGroup,
  getCurrentScenario,
  getCurrentTestCase,
  getTestPhase,
  startScenarioGroup,
  endScenarioGroup,
  startScenario,
  cancelScenario,
  endScenario,
  startTestCase,
  cancelTestCase,
  endTestCase,
  getTestScenarioGroupStatus,
  getTestScenarioStatus,
  getTestCaseStatus
}