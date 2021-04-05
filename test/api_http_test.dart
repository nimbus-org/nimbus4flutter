
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus4flutter/nimbus4flutter.dart';

void main() {
  setUp((){
      ApiRegistory.registApiServer(
        ApiServerHttp(
          name : "test",
          host : "localhost",
          requestBuilder: (request, method, input) async{
            switch(method){
            case HttpMethod.POST:
            case HttpMethod.PATCH:
            case HttpMethod.PUT:
              DataSet ds = input as DataSet;
              request.headers["Content-Type"] = "application/json; charset=utf-8";
              (request as Request).body = JsonEncoder().convert(ds.toMap(toJsonType: true));
              break;
            default:
              break;
            }
          },
          responseParser: (response, method, output) async{
            if(response.statusCode != 200){
              throw new Exception("error status = ${response.statusCode}");
            }
            if(output != null){
              DataSet ds = output as DataSet;
              ds.fromMap(JsonDecoder().convert(await (response as StreamedResponse).stream.transform(Utf8Decoder()).join()));
            }
          },
        )
      );
  });
  tearDown(
    (){
      ApiRegistory.close(force: true);
    }
  );
  group('api test', () {
    test('single api get test', () async{
      String requestedUri = "";
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      httpServer.listen((HttpRequest request) {
          requestedUri = request.requestedUri.toString();
          DataSet ds = responseDs.clone(true);
          ds.getHeader("User")!["name"] = "hoge";
          ds.getHeader("User")!["age"] = 20;
          request.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
          request.response.write(JsonEncoder().convert(ds.toMap(toJsonType: true)));
          request.response.close();
      });
      ApiRegistory.registApi(
        ApiHttp<dynamic,DataSet,Request,StreamedResponse>(
          name:"test/user",
          serverName:"test",
          method:HttpMethod.GET,
          path:"/user",
          outputCreator: (context) => responseDs.clone(true)
        )
      );
      Api? api = ApiRegistory.getApi("test/user");
      DataSet response = await api!.request(null, RequestContext());
      expect(requestedUri, "http://localhost/user");
      expect(response.getHeader("User")?["name"], "hoge");
      expect(response.getHeader("User")?["age"], 20);
      httpServer.close(force: true);
    });
    test('single api get error on connected test', () async{
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      ApiRegistory.registApi(
        ApiHttp<dynamic,DataSet,Request,StreamedResponse>(
          name:"test/user",
          serverName:"test",
          method:HttpMethod.GET,
          path:"/user",
          outputCreator: (context) => responseDs.clone(true),
        )
      );
      Api? api = ApiRegistory.getApi("test/user");
      try{
        await api!.request(null, RequestContext());
        fail("exception can not catch");
      }catch(e){
        expect(e is SocketException, true);
      }
    });
    test('single api get error on reuqest test', () async{
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      ApiRegistory.registApi(
        ApiHttp<dynamic,DataSet,Request,StreamedResponse>(
          name:"test/user",
          serverName:"test",
          method:HttpMethod.GET,
          path:"/user",
          outputCreator: (context) => responseDs.clone(true),
          requestBuilder: (request, input, serverBuilder) {
            throw new Exception("test");
          },
        )
      );
      Api? api = ApiRegistory.getApi("test/user");
      try{
        await api!.request(null, RequestContext());
        fail("exception can not catch");
      }catch(e){
        expect(e.toString(), "Exception: test");
      }
      httpServer.close(force: true);
    });
    test('single api get error on response test', () async{
      String requestedUri = "";
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      httpServer.listen((HttpRequest request) {
          requestedUri = request.requestedUri.toString();
          request.response.statusCode = 404;
          request.response.close();
      });
      ApiRegistory.registApi(
        ApiHttp<dynamic,DataSet,Request,StreamedResponse>(
          name:"test/user",
          serverName:"test",
          method:HttpMethod.GET,
          path:"/user",
          outputCreator: (context) => responseDs.clone(true)
        )
      );
      Api? api = ApiRegistory.getApi("test/user");
      try{
        await api!.request(null, RequestContext());
        fail("exception can not catch");
      }catch(e){
        expect(requestedUri, "http://localhost/user");
        expect(e.toString(), "Exception: error status = 404");
      }
      httpServer.close(force: true);
    });
    test('single api post test', () async{
      String requestedUri = "";
      DataSet? requestedDataSet;
      DataSet requestDs = DataSet("testRequest");
      requestDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name")
          ]
        ),
        "User"
      );
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      httpServer.listen((HttpRequest request) async{
          requestedUri = request.requestedUri.toString();
          requestedDataSet = requestDs.clone();
          requestedDataSet!.fromMap(JsonDecoder().convert(await Utf8Decoder().bind(request).join()));
          DataSet ds = responseDs.clone(true);
          ds.getHeader("User")?["name"] = requestedDataSet!.getHeader("User")?["name"];
          ds.getHeader("User")?["age"] = 20;
          request.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
          request.response.write(JsonEncoder().convert(ds.toMap(toJsonType: true)));
          request.response.close();
      });
      ApiRegistory.registApi(
        ApiHttp<DataSet,DataSet,Request,StreamedResponse>(
          name:"test/user",
          serverName:"test",
          method:HttpMethod.POST,
          path:"/user",
          inputCreator: (context) => requestDs.clone(true),
          outputCreator: (context) => responseDs.clone(true)
        )
      );
      Api? api = ApiRegistory.getApi("test/user");
      RequestContext context = RequestContext();
      DataSet request = api!.getInput(context);
      request.getHeader("User")?["name"] = "hoge";
      DataSet response = await api.request(request, context);
      expect(requestedUri, "http://localhost/user");
      expect(requestedDataSet?.getHeader("User")?["name"], "hoge");
      expect(response.getHeader("User")?["name"], "hoge"); 
      expect(response.getHeader("User")?["age"], 20);
      httpServer.close(force: true);
    });
    test('sequencial api test', () async{
      List<String> requestedUri = [];
      List<DataSet> requestedDataSet = [];
      DataSet requestDs = DataSet("testRequest");
      requestDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name")
          ]
        ),
        "User"
      );
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      httpServer.listen((HttpRequest request) async{
          requestedUri.add(request.requestedUri.toString());
          DataSet reqDs = requestDs.clone();
          reqDs.fromMap(JsonDecoder().convert(await Utf8Decoder().bind(request).join()));
          requestedDataSet.add(reqDs);
          DataSet ds = responseDs.clone(true);
          ds.getHeader("User")?["name"] = reqDs.getHeader("User")?["name"];
          ds.getHeader("User")?["age"] = 20;
          request.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
          request.response.write(JsonEncoder().convert(ds.toMap(toJsonType: true)));
          request.response.close();
      });
      ApiRegistory.registApi(
        SequencialApi<DataSet,List<Object>>(
          name:"test/users",
          apis:[
            ApiHttp<DataSet,DataSet,Request,StreamedResponse>(
              name:"test/user[0]",
              serverName:"test",
              method:HttpMethod.POST,
              path:"/user",
              inputCreator: (context) => requestDs.clone(true),
              outputCreator: (context) => responseDs.clone(true)
            ),
            ApiHttp<DataSet,DataSet,Request,StreamedResponse>(
              name:"test/user[1]",
              serverName:"test",
              method:HttpMethod.POST,
              path:"/user",
              inputCreator: (context){
                DataSet ds = requestDs.clone(true);
                ds.getHeader("User")?["name"] = ((context.getOutput("test/user[0]") as DataSet).getHeader("User")?["name"] as String) + "fuga";
                return ds;
              },
              outputCreator: (context) => responseDs.clone(true)
            ),
            ApiHttp<DataSet,DataSet,Request,StreamedResponse>(
              name:"test/user[2]",
              serverName:"test",
              method:HttpMethod.POST,
              path:"/user",
              inputCreator: (context){
                DataSet ds = requestDs.clone(true);
                ds.getHeader("User")?["name"] = ((context.getOutput("test/user[1]") as DataSet).getHeader("User")?["name"] as String) + "piyo";
                return ds;
              },
              outputCreator: (context) => responseDs.clone(true)
            )
          ]
        )
      );
      Api? api = ApiRegistory.getApi("test/users");
      RequestContext context = RequestContext();
      DataSet request = api?.getInput(context);
      request.getHeader("User")?["name"] = "hoge";
      List<DataSet> response = ((await api?.request(request, context)) as List<Object>).cast();
      expect(requestedUri.length, 3);
      expect(requestedUri[0], "http://localhost/user");
      expect(requestedUri[1], "http://localhost/user");
      expect(requestedUri[2], "http://localhost/user");
      expect(requestedDataSet.length, 3);
      expect(requestedDataSet[0].getHeader("User")?["name"], "hoge");
      expect(requestedDataSet[1].getHeader("User")?["name"], "hogefuga");
      expect(requestedDataSet[2].getHeader("User")?["name"], "hogefugapiyo");
      expect(response.length, 3);
      expect(response[0].getHeader("User")?["name"], "hoge"); 
      expect(response[0].getHeader("User")?["age"], 20);
      expect(response[1].getHeader("User")?["name"], "hogefuga"); 
      expect(response[1].getHeader("User")?["age"], 20);
      expect(response[2].getHeader("User")?["name"], "hogefugapiyo"); 
      expect(response[2].getHeader("User")?["age"], 20);
      httpServer.close(force: true);
    });
    test('parallel api test', () async{
      List<String> requestedUri = [];
      List<DataSet> requestedDataSet = [];
      DataSet requestDs = DataSet("testRequest");
      requestDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name")
          ]
        ),
        "User"
      );
      DataSet responseDs = DataSet("testResponse");
      responseDs.setHeaderSchema(
        RecordSchema(
          [
            FieldSchema<String>("name"),
            FieldSchema<int>("age")
          ]
        ),
        "User"
      );
      HttpServer httpServer = await HttpServer.bind(InternetAddress.anyIPv6, 80);
      httpServer.listen((HttpRequest request) async{
          requestedUri.add(request.requestedUri.toString());
          DataSet reqDs = requestDs.clone();
          reqDs.fromMap(JsonDecoder().convert(await Utf8Decoder().bind(request).join()));
          requestedDataSet.add(reqDs);
          DataSet ds = responseDs.clone(true);
          ds.getHeader("User")?["name"] = reqDs.getHeader("User")?["name"];
          ds.getHeader("User")?["age"] = 20;
          request.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
          request.response.write(JsonEncoder().convert(ds.toMap(toJsonType: true)));
          request.response.close();
      });
      Api templateApi = ApiHttp<DataSet,DataSet,Request,StreamedResponse>(
        name:"test/user",
        serverName:"test",
        method:HttpMethod.POST,
        path:"/user",
        inputCreator: (context) => requestDs.clone(true),
        outputCreator: (context) => responseDs.clone(true)
      );
      ApiRegistory.registApi(
        ParallelApi<List<Object>>(
          name:"test/users",
          apis:[templateApi,templateApi,templateApi]
        )
      );
      Api? api = ApiRegistory.getApi("test/users");
      RequestContext context = RequestContext();
      List<DataSet> request = (api?.getInput(context) as List<Object>).cast();
      request[0].getHeader("User")?["name"] = "hoge";
      request[1].getHeader("User")?["name"] = "fuga";
      request[2].getHeader("User")?["name"] = "piyo";
      List<DataSet> response = ((await api?.request(request, context)) as List<Object>).cast();
      expect(requestedUri.length, 3);
      expect(requestedUri[0], "http://localhost/user");
      expect(requestedUri[1], "http://localhost/user");
      expect(requestedUri[2], "http://localhost/user");
      expect(requestedDataSet.length, 3);
      expect(requestedDataSet.map((e) => e.getHeader("User")?["name"]).toSet().containsAll(["hoge", "fuga", "piyo"]), true);
      expect(response.length, 3);
      expect(response[0].getHeader("User")?["name"], "hoge"); 
      expect(response[0].getHeader("User")?["age"], 20);
      expect(response[1].getHeader("User")?["name"], "fuga"); 
      expect(response[1].getHeader("User")?["age"], 20);
      expect(response[2].getHeader("User")?["name"], "piyo"); 
      expect(response[2].getHeader("User")?["age"], 20);
      httpServer.close(force: true);
    });
  });
}
